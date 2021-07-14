//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreNFC
import NotificareKit
import UIKit

public class NotificareScannables: NSObject, NotificareModule {
    public static let shared = NotificareScannables()

    public weak var delegate: NotificareScannablesDelegate?

    // MARK: Notificare module

    public static func configure() {}

    public static func launch(_ completion: @escaping NotificareCallback<Void>) {
        completion(.success(()))
    }

    public static func unlaunch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    // MARK: - Public API

    public var canStartNfcScannableSession: Bool {
        if #available(iOS 11.0, *) {
            return NFCNDEFReaderSession.readingAvailable
        }

        return false
    }

    public func startNfcScannableSession() {
        if #available(iOS 11.0, *), canStartNfcScannableSession {
            let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
            session.begin()
        } else {
            NotificareLogger.warning("NFC scanning is not available. Please start a QR Code scannable session instead.")
        }
    }

    public func startQrCodeScannableSession(controller: UIViewController, modal: Bool = false) {
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
        let encodedTag = tag.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)!

        NotificareRequest.Builder()
            .get("/scannable/tag/\(encodedTag)")
            .query(name: "deviceID", value: Notificare.shared.deviceManager.currentDevice?.id)
            .query(name: "userID", value: Notificare.shared.deviceManager.currentDevice?.userId)
            .responseDecodable(NotificareInternals.PushAPI.Responses.Scannable.self) { result in
                switch result {
                case let .success(response):
                    let scannable = response.scannable.toModel()
                    self.delegate?.notificare(self, didDetectScannable: scannable)

                case let .failure(error):
                    self.delegate?.notificare(self, didInvalidateScannerSession: error)
                }
            }
    }
}

@available(iOS 11.0, *)
extension NotificareScannables: NFCNDEFReaderSessionDelegate {
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
                    self.delegate?.notificare(self, didInvalidateScannerSession: NotificareScannablesError.scannableNotSupported)
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

public enum NotificareScannablesError: Error {
    case scannableNotSupported
}
