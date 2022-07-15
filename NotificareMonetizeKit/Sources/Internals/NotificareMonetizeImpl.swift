//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import StoreKit

private typealias ProductRequestCallback = NotificareCallback<[SKProduct]>

internal class NotificareMonetizeImpl: NSObject, NotificareModule, NotificareMonetize {
    internal static let instance = NotificareMonetizeImpl()

    private var productsRequest: SKProductsRequest?
    private var productsRequestCallback: ProductRequestCallback?

    private var productsMap: [String: NotificareProduct] = [:]
    private var productDetailsMap: [String: SKProduct] = [:]

    // MARK: Notificare module

    static func configure() {
        SKPaymentQueue.default().add(instance)
    }

    static func launch(_ completion: @escaping NotificareCallback<Void>) {
        instance.refresh { _ in }

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
        [] // TODO: implement purchases
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

                        DispatchQueue.main.async {
                            self.delegate?.notificare(self, didUpdateProducts: models)
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

    private func processPurchase(_ transaction: SKPaymentTransaction) {
        guard let details = productDetailsMap[transaction.payment.productIdentifier] else {
            NotificareLogger.warning("Unable to process a purchase when the product is not cached.")
            return // TODO: completion handler
        }

        guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
            NotificareLogger.warning("Unable to process a purchase without its receipt.")
            return // TODO: completion handler
        }

        let receipt: String

        do {
            let data = try Data(contentsOf: receiptUrl)
            receipt = data.base64EncodedString()
        } catch {
            NotificareLogger.warning("Failed to parse the purchase receipt.")
            return // TODO: completion handler
        }

        let purchaseVerification = NotificareInternals.PushAPI.Payloads.PurchaseVerification(
            receipt: receipt,
            price: details.price.doubleValue,
            currency: details.priceLocale.currencyCode ?? "EUR"
        )

        verifyPurchase(purchaseVerification) { result in
            switch result {
            case .success:
                if !transaction.downloads.isEmpty {
                    // TODO: start the downloads
                }

                if transaction.transactionState == .restored {
                    // TODO: handle restored transaction
                }

                SKPaymentQueue.default().finishTransaction(transaction)
                NotificareLogger.info("Purchase successfully finished.")
            case let .failure(error):
                _ = error
                // TODO: completion handler
            }
        }
    }

    private func processPurchaseFailure(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)

        if let error = transaction.error {
            // TODO: notify the listeners
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

        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                NotificareLogger.debug("Processing transaction (purchased).")
                processPurchase(transaction)
            case .restored:
                NotificareLogger.debug("Processing transaction (restored).")
                processPurchase(transaction)
            case .failed:
                NotificareLogger.debug("Processing transaction (failed).")
                processPurchaseFailure(transaction)
            case .deferred:
                break
            case .purchasing:
                break
            @unknown default:
                NotificareLogger.warning("Unhandled transaction state '\(transaction.transactionState)'.")
            }
        }
    }
}
