//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import StoreKit

private typealias ProductRequestCallback = NotificareCallback<[SKProduct]>

internal class NotificareMonetizeImpl: NSObject, NotificareModule, NotificareMonetize {
    internal static let instance = NotificareMonetizeImpl()

    private let database = MonetizeDatabase()

    private var productsRequest: SKProductsRequest?
    private var productsRequestCallback: ProductRequestCallback?

    private var productsMap: [String: NotificareProduct] = [:]      // where K is the Apple product identifier
    private var productDetailsMap: [String: SKProduct] = [:]        // where K is the Apple product identifier
    private var purchaseEntities: [String: PurchaseEntity] = [:]    // where K is the Apple transaction identifier

    // MARK: Notificare module

    static func configure() {
        instance.database.configure()
        SKPaymentQueue.default().add(instance)
    }

    static func launch(_ completion: @escaping NotificareCallback<Void>) {
        instance.refresh { _ in }

        do {
            let entities = try instance.database.find()
            instance.purchaseEntities = entities.compactAssociateBy { $0.id }

            DispatchQueue.main.async {
                instance.delegate?.notificare(instance, didUpdatePurchases: instance.purchases)
            }
        } catch {
            NotificareLogger.error("Failed to query the local database.", error: error)
        }

        completion(.success(()))
    }

    // MARK: Notificare Monetize

    weak var delegate: NotificareMonetizeDelegate?

    var hasPurchasingCapabilitiesAvailable: Bool {
        SKPaymentQueue.canMakePayments()
    }

    var products: [NotificareProduct] {
        Array(productsMap.values)
    }

    var purchases: [NotificarePurchase] {
        purchaseEntities.values.compactMap { entity in
            do {
                return try entity.toModel()
            } catch {
                NotificareLogger.warning("Failed to decode purchase entity.", error: error)
                return nil
            }
        }
    }

    func refresh(_ completion: @escaping NotificareCallback<Void>) {
        NotificareLogger.debug("Fetching Notificare products.")
        fetchProducts { result in
            switch result {
            case let .success(products):
                let identifiers = Set(products.map(\.identifier))

                NotificareLogger.debug("Fetching AppStore products.")
                self.fetchProductDetails(identifiers: identifiers) { result in
                    switch result {
                    case let .success(productDetails):
                        let models: [NotificareProduct] = products.map { product in
                            let details = productDetails.first(where: { $0.productIdentifier == product.identifier })
                            return NotificareProduct(ncProduct: product, skProduct: details)
                        }

                        self.productsMap = models.associateBy { $0.identifier }
                        self.productDetailsMap = productDetails.associateBy { $0.productIdentifier }

                        do {
                            let entities = try self.database.find()
                            self.purchaseEntities = entities.compactAssociateBy { $0.id }
                        } catch {
                            NotificareLogger.error("Failed to query the local database.", error: error)
                        }

                        DispatchQueue.main.async {
                            self.delegate?.notificare(self, didUpdateProducts: self.products)
                            self.delegate?.notificare(self, didUpdatePurchases: self.purchases)
                        }

                        completion(.success(()))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    @available(iOS 13.0, *)
    func refresh() async throws {
        try await withCheckedThrowingContinuation { continuation in
            refresh { result in
                continuation.resume(with: result)
            }
        }
    }

    func startPurchaseFlow(for product: NotificareProduct) {
        guard let details = productDetailsMap[product.identifier] else {
            NotificareLogger.warning("Unable to start a purchase flow when the product is not cached.")
            return
        }

        let payment = SKPayment(product: details)
        SKPaymentQueue.default().add(payment)

        NotificareLogger.info("Purchase flow launched.")
    }

    // MARK: - Internal API

    private func fetchProducts(_ completion: @escaping NotificareCallback<[NotificareInternals.PushAPI.Models.Product]>) {
        NotificareRequest.Builder()
            .get("/product/active")
            .responseDecodable(NotificareInternals.PushAPI.Responses.FetchProducts.self) { result in
                switch result {
                case let .success(response):
                    let products = response.products.filter { $0.stores.contains("AppStore") }
                    completion(.success(products))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    private func fetchProductDetails(identifiers: Set<String>, _ completion: @escaping NotificareCallback<[SKProduct]>) {
        productsRequest = SKProductsRequest(productIdentifiers: identifiers)
        productsRequestCallback = completion

        productsRequest!.delegate = self
        productsRequest!.start()
    }

    private func processPurchases(_ transactions: [SKPaymentTransaction]) {
        guard let transaction = transactions.first else {
            NotificareLogger.debug("Finished processing the transactions.")
            return
        }

        switch transaction.transactionState {
        case .purchased, .restored:
            if transaction.transactionState == .purchased, transaction.original == nil {
                NotificareLogger.debug("Processing transaction (purchased).")
            } else {
                NotificareLogger.debug("Processing transaction (restored).")
            }

            processPurchase(transaction) { result in
                switch result {
                case let .success(receipt):
                    if let transactionIdentifier = transaction.original?.transactionIdentifier ?? transaction.transactionIdentifier,
                       let transactionDate = transaction.original?.transactionDate ?? transaction.transactionDate
                    {
                        let productIdentifier = transaction.original?.payment.productIdentifier ?? transaction.payment.productIdentifier

                        let purchase = NotificarePurchase(
                            id: transactionIdentifier,
                            productIdentifier: productIdentifier,
                            time: transactionDate,
                            receipt: receipt
                        )

                        if transaction.transactionState == .restored || transaction.original != nil {
                            DispatchQueue.main.async {
                                self.delegate?.notificare(self, didRestorePurchase: purchase)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.delegate?.notificare(self, didFinishPurchase: purchase)
                            }
                        }

                        do {
                            NotificareLogger.debug("Saving the purchase into the database.")
                            let entity = try self.database.add(purchase)

                            if let id = entity.id {
                                self.purchaseEntities[id] = entity
                            } else {
                                NotificareLogger.warning("Purchase entity created without an identifier.")
                            }
                        } catch {
                            NotificareLogger.error("Failed to save the purchase into the database.", error: error)
                        }

                        DispatchQueue.main.async {
                            self.delegate?.notificare(self, didUpdatePurchases: self.purchases)
                        }

                        NotificareLogger.info("Purchase successfully finished.")
                    } else {
                        NotificareLogger.warning("Unable to process transaction with missing information.")
                    }

                    SKPaymentQueue.default().finishTransaction(transaction)

                case let .failure(error):
                    DispatchQueue.main.async {
                        self.delegate?.notificare(self, didFailToPurchase: error)
                    }
                }

                SKPaymentQueue.default().finishTransaction(transaction)

                DispatchQueue.main.async {
                    self.delegate?.notificare(self, processTransaction: transaction)
                }

                // Recursivelly call processPurchases until there are no more items in the list.
                self.processPurchases(Array(transactions.dropFirst()))
            }

            return
        case .failed:
            NotificareLogger.debug("Processing transaction (failed).")
            SKPaymentQueue.default().finishTransaction(transaction)

            if let error = transaction.error {
                DispatchQueue.main.async {
                    self.delegate?.notificare(self, didFailToPurchase: error)
                }
            }
        case .deferred:
            break
        case .purchasing:
            break
        @unknown default:
            NotificareLogger.warning("Unhandled transaction state '\(transaction.transactionState)'.")
        }

        DispatchQueue.main.async {
            self.delegate?.notificare(self, processTransaction: transaction)
        }

        // Recursivelly call processPurchases until there are no more items in the list.
        processPurchases(Array(transactions.dropFirst()))
    }

    private func processPurchase(_ transaction: SKPaymentTransaction, _ completion: @escaping NotificareCallback<String>) {
        guard let details = productDetailsMap[transaction.payment.productIdentifier] else {
            NotificareLogger.warning("Unable to process a purchase when the product is not cached.")
            completion(.failure(NotificareMonetizeError.missingProduct))
            return
        }

        guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
            NotificareLogger.warning("Unable to process a purchase without its receipt.")
            completion(.failure(NotificareMonetizeError.missingReceipt))
            return
        }

        let receipt: String

        do {
            let data = try Data(contentsOf: receiptUrl)
            receipt = data.base64EncodedString()
        } catch {
            NotificareLogger.warning("Failed to parse the purchase receipt.")
            completion(.failure(error))
            return
        }

        let purchaseVerification = NotificareInternals.PushAPI.Payloads.PurchaseVerification(
            receipt: receipt,
            price: details.price.doubleValue,
            currency: details.priceLocale.currencyCode ?? "EUR"
        )

        verifyPurchase(purchaseVerification) { result in
            switch result {
            case .success:
                completion(.success(receipt))
            case let .failure(error):
                NotificareLogger.error("Failed to verify the purchase.", error: error)
                completion(.failure(error))
            }
        }
    }

    private func verifyPurchase(_ purchase: NotificareInternals.PushAPI.Payloads.PurchaseVerification, _ completion: @escaping NotificareCallback<Void>) {
        guard let device = Notificare.shared.device().currentDevice else {
            completion(.failure(NotificareError.deviceUnavailable))
            return
        }

        NotificareRequest.Builder()
            .post("/purchase/fordevice/\(device.id)", body: purchase)
            .response { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
}

extension NotificareMonetizeImpl: SKProductsRequestDelegate {
    func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
        NotificareLogger.debug("Received products request response.")
        productsRequestCallback?(.success(response.products))

        productsRequest = nil
        productsRequestCallback = nil
    }

    func request(_: SKRequest, didFailWithError error: Error) {
        NotificareLogger.error("Failed to fetch the product details.", error: error)
        productsRequestCallback?(.failure(error))

        productsRequest = nil
        productsRequestCallback = nil
    }
}

extension NotificareMonetizeImpl: SKPaymentTransactionObserver {
    func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        NotificareLogger.info("Processing purchases event.")
        NotificareLogger.debug("\(transactions.filter { $0.transactionState == .purchased }.count) purchased transactions.")
        NotificareLogger.debug("\(transactions.filter { $0.transactionState == .restored }.count) restored transactions.")
        NotificareLogger.debug("\(transactions.filter { $0.transactionState == .failed }.count) failed transactions.")
        NotificareLogger.debug("\(transactions.filter { $0.transactionState == .deferred }.count) deferred transactions.")
        NotificareLogger.debug("\(transactions.filter { $0.transactionState == .purchasing }.count) purchasing transactions.")

        processPurchases(transactions)
    }
}
