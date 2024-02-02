//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreGraphics
import Foundation
import MobileCoreServices
import UserNotifications

public class NotificareNotificationServiceExtension {
    private init() {}

    public static func handleNotificationRequest(_ request: UNNotificationRequest, _ completion: @escaping (Result<UNNotificationContent, Swift.Error>) -> Void) {
        Task {
            do {
                let result = try await handleNotificationRequest(request)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public static func handleNotificationRequest(_ request: UNNotificationRequest) async throws -> UNNotificationContent {
        let content = request.content.mutableCopy() as! UNMutableNotificationContent

        let attachment = try await fetchAttachment(for: request)

        if let attachment = attachment {
            content.attachments = [attachment]
        }

        return content
    }

    private static func fetchAttachment(for request: UNNotificationRequest, _ completion: @escaping (Result<UNNotificationAttachment?, Swift.Error>) -> Void) {
        Task {
            do {
                let result = try await fetchAttachment(for: request)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private static func fetchAttachment(for request: UNNotificationRequest) async throws -> UNNotificationAttachment? {
        guard let attachment = request.content.userInfo["attachment"] as? [String: Any],
              let uri = attachment["uri"] as? String
        else {
            // NotificareLogger.debug("Could not find an attachment URI. Please ensure you're calling this method with the correct payload.")
            return nil
        }

        guard let url = URL(string: uri) else {
            // NotificareLogger.warning("Invalid attachment URI. Please ensure it's a valid URL.")
            throw NotificareNotificationServiceExtension.Error.invalidUrl
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)[0]
        let fileName = url.pathComponents.last!
        let filePath = URL(fileURLWithPath: documentsPath).appendingPathComponent(fileName)

        do {
            try data.write(to: filePath, options: .atomic)
        } catch {
            throw NotificareNotificationServiceExtension.Error.downloadFailed
        }

        do {
            var options: [AnyHashable: Any] = [
                UNNotificationAttachmentOptionsThumbnailClippingRectKey: CGRect(x: 0, y: 0, width: 1, height: 1),
            ]

            if let mimeType = response.mimeType,
               let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)
            {
                options[UNNotificationAttachmentOptionsTypeHintKey] = uti.takeRetainedValue()
            }

            let attachment = try UNNotificationAttachment(identifier: "file_\(fileName)", url: filePath, options: options)
            return attachment
        } catch {
            throw NotificareNotificationServiceExtension.Error.downloadFailed
        }
    }

    public enum Error: Swift.Error {
        case invalidUrl
        case downloadFailed
    }
}
