//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreNFC
import NotificareKit
import UIKit

internal class NotificareScannablesImpl: NSObject, NotificareModule, NotificareScannables {
    // MARK: - Notificare Module

    static let instance = NotificareScannablesImpl()

    // MARK: - Notificare Scannables

    weak var delegate: NotificareScannablesDelegate?

    var canStartNfcScannableSession: Bool {
        if #available(iOS 11.0, *) {
            return NFCNDEFReaderSession.readingAvailable
        }

        return false
    }

    func startScannableSession(controller: UIViewController) {
        if canStartNfcScannableSession {
            startNfcScannableSession()
        } else {
            startQrCodeScannableSession(controller: controller)
        }
    }

    func startNfcScannableSession() {
        if #available(iOS 11.0, *), canStartNfcScannableSession {
            let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
            session.begin()
        } else {
            NotificareLogger.warning("NFC scanning is not available. Please start a QR Code scannable session instead.")
        }
    }

    func startQrCodeScannableSession(controller: UIViewController, modal: Bool = false) {
        let qrCodeScanner = NotificareQrCodeScannerViewController()
        qrCodeScanner.onQrCodeDetected = { qrCode in

            DispatchQueue.main.async {
                if let controller = controller as? UINavigationController, !modal {
                    controller.popViewController(animated: true)
                } else {
                    controller.dismiss(animated: true)
                }
            }

            self.handleScannableTag(qrCode)
        }

        if let controller = controller as? UINavigationController, !modal {
            controller.pushViewController(qrCodeScanner, animated: true)
        } else {
            if controller.presentedViewController != nil {
                controller.dismiss(animated: true) {
                    controller.present(qrCodeScanner, animated: true)
                }
            } else {
                controller.present(qrCodeScanner, animated: true)
            }
        }
    }

    func fetch(tag: String, _ completion: @escaping NotificareCallback<NotificareScannable>) {
        guard let encodedTag = tag.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) else {
            completion(.failure(NotificareError.invalidArgument(message: "Invalid tag value.")))
            return
        }

        NotificareRequest.Builder()
            .get("/scannable/tag/\(encodedTag)")
            .query(name: "deviceID", value: Notificare.shared.device().currentDevice?.id)
            .query(name: "userID", value: Notificare.shared.device().currentDevice?.userId)
            .responseDecodable(NotificareInternals.PushAPI.Responses.Scannable.self) { result in
                switch result {
                case let .success(response):
                    let scannable = response.scannable.toModel()
                    completion(.success(scannable))

                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func fetch(tag: String) async throws -> NotificareScannable {
        try await withCheckedThrowingContinuation { continuation in
            fetch(tag: tag) { result in
                continuation.resume(with: result)
            }
        }
    }

    // MARK: - Private API

    @available(iOS 11.0, *)
    private func parseScannableTag(_ record: NFCNDEFPayload) -> String? {
        if #available(iOS 13.0, *) {
            return record.wellKnownTypeURIPayload()?.absoluteString
        }

        let bytes: [UInt8] = record.payload.map { $0 }

        let code = UInt8(bytes[0])
        guard let text = String(bytes: bytes.suffix(bytes.count - 1), encoding: .utf8) else {
            return nil
        }

        switch code {
        case 0x00:
            return text
        case 0x01:
            return "http://www.\(text)"
        case 0x02:
            return "https://www.\(text)"
        case 0x03:
            return "http://\(text)"
        case 0x04:
            return "https://\(text)"
        case 0x05:
            return "tel:\(text)"
        case 0x06:
            return "mailto:\(text)"
        case 0x07:
            return "ftp://anonymous:anonymous@\(text)"
        case 0x08:
            return "ftp://ftp.\(text)"
        case 0x09:
            return "ftps://\(text)"
        case 0x0A:
            return "sftp://\(text)"
        case 0x0B:
            return "smb://\(text)"
        case 0x0C:
            return "nfs://\(text)"
        case 0x0D:
            return "ftp://\(text)"
        case 0x0E:
            return "dav://\(text)"
        case 0x0F:
            return "news:\(text)"
        case 0x10:
            return "telnet://\(text)"
        case 0x11:
            return "imap:\(text)"
        case 0x12:
            return "rtsp://\(text)"
        case 0x13:
            return "urn:\(text)"
        case 0x14:
            return "pop:\(text)"
        case 0x15:
            return "sip:\(text)"
        case 0x16:
            return "sips:\(text)"
        case 0x17:
            return "tftp:\(text)"
        case 0x18:
            return "btspp://\(text)"
        case 0x19:
            return "btl2cap://\(text)"
        case 0x1A:
            return "btgoep://\(text)"
        case 0x1B:
            return "tcpobex://\(text)"
        case 0x1C:
            return "irdaobex://\(text)"
        case 0x1D:
            return "file://\(text)"
        case 0x1E:
            return "urn:epc:id:\(text)"
        case 0x1F:
            return "urn:epc:tag:\(text)"
        case 0x20:
            return "urn:epc:pat:\(text)"
        case 0x21:
            return "urn:epc:raw:\(text)"
        case 0x22:
            return "urn:epc:\(text)"
        case 0x23:
            return "urn:nfc:\(text)"
        default:
            return nil
        }
    }

    private func handleScannableTag(_ tag: String) {
        fetch(tag: tag) { result in
            switch result {
            case let .success(scannable):
                DispatchQueue.main.async {
                    self.delegate?.notificare(self, didDetectScannable: scannable)
                }

            case let .failure(error):
                DispatchQueue.main.async {
                    self.delegate?.notificare(self, didInvalidateScannerSession: error)
                }
            }
        }
    }
}

@available(iOS 11.0, *)
extension NotificareScannablesImpl: NFCNDEFReaderSessionDelegate {
    public func readerSession(_: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        messages.forEach { message in
            message.records.forEach { record in
                if record.typeNameFormat == .nfcWellKnown,
                   let type = String(data: record.type, encoding: .utf8),
                   type == "U", // only supports URL payloads
                   let tag = parseScannableTag(record)
                {
                    handleScannableTag(tag)
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.notificare(self, didInvalidateScannerSession: NotificareScannablesError.unsupportedScannable)
                    }
                }
            }
        }
    }

    public func readerSession(_: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // When invalidateAfterFirstRead is YES, the reader session automatically terminates after the first NFC tag is successfully read.
        // In this scenario, the delegate receives the NFCReaderSessionInvalidationErrorFirstNDEFTagRead status.
        if let error = error as? NFCReaderError, error.code == .readerSessionInvalidationErrorFirstNDEFTagRead {
            return
        }

        DispatchQueue.main.async {
            self.delegate?.notificare(self, didInvalidateScannerSession: error)
        }
    }
}
