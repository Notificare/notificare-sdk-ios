//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import AVFoundation
import CoreGraphics
import CoreMedia
import MobileCoreServices
import NotificareCore
import NotificareKit
import UIKit

public class NotificareCallbackActionHandler: NotificareBaseActionHandler {
    private let response: NotificareNotification.ResponseData?
    private let sourceViewController: UIViewController

    private var theme: NotificareOptions.Theme?

    private var navigationController: UINavigationController!
    private var viewController: UIViewController!
    private var placeholderView: UIView!
    private var imageView: UIImageView!
    private var activityIndicatorView: UIActivityIndicatorView!
    private var toolbar: UIToolbar!
    private var closeButton: UIBarButtonItem!
    private var sendButton: UIBarButtonItem!
    private var imagePickerController: UIImagePickerController!
    private var messageView: UITextView?
    private var messageField: UITextField?

    private var keyboardHeight: CGFloat = 0.0

    private var imageData: Data?
    private var videoData: Data?

    private var message: String? {
        response?.userText ?? messageField?.text ?? messageView?.text
    }

    private var mediaUrl: String?
    private var mediaMimeType: String?

    init(notification: NotificareNotification, action: NotificareNotification.Action, response: NotificareNotification.ResponseData?, sourceViewController: UIViewController) {
        self.response = response
        self.sourceViewController = sourceViewController
        super.init(notification: notification, action: action)

        viewController = UIViewController()
        navigationController = UINavigationController(rootViewController: viewController)
        theme = Notificare.shared.options!.theme(for: viewController)

        placeholderView = UIView(frame: CGRect(x: 0, y: 0, width: viewController.view.frame.width, height: viewController.view.frame.height))
        placeholderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let colorStr = theme?.backgroundColor {
            placeholderView.backgroundColor = UIColor(hexString: colorStr)
        }

        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewController.view.frame.width, height: viewController.view.frame.height))
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let colorStr = theme?.backgroundColor {
            imageView.tintColor = UIColor(hexString: colorStr)
        }

        if let image = NotificareLocalizable.image(resource: .close) {
            closeButton = UIBarButtonItem(image: image,
                                          style: .plain,
                                          target: self,
                                          action: #selector(onCloseClicked))

            if let colorStr = theme?.actionButtonTextColor {
                closeButton.tintColor = UIColor(hexString: colorStr)
            }
        } else {
            closeButton = UIBarButtonItem(title: NotificareLocalizable.string(resource: .closeButton),
                                          style: .plain,
                                          target: self,
                                          action: #selector(onCloseClicked))

            if let colorStr = theme?.actionButtonTextColor {
                closeButton.tintColor = UIColor(hexString: colorStr)
            }
        }

        if let image = NotificareLocalizable.image(resource: .send) {
            sendButton = UIBarButtonItem(image: image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(onSendClicked))

            if let colorStr = theme?.buttonTextColor {
                sendButton.tintColor = UIColor(hexString: colorStr)
            }
        } else {
            sendButton = UIBarButtonItem(title: NotificareLocalizable.string(resource: .sendButton),
                                         style: .plain,
                                         target: self,
                                         action: #selector(onSendClicked))

            if let colorStr = theme?.buttonTextColor {
                sendButton.tintColor = UIColor(hexString: colorStr)
            }
        }

        activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.hidesWhenStopped = true
        if let colorStr = theme?.activityIndicatorColor {
            activityIndicatorView.tintColor = UIColor(hexString: colorStr)
        }

        viewController.title = notification.title ?? NotificareUtils.applicationName
        viewController.navigationItem.leftBarButtonItem = closeButton
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }

    override func execute() {
        if action.camera, action.keyboard {
            // First get the camera going, then get the message.
            openCamera()
            return
        }

        if action.keyboard {
            if response?.userText != nil {
                send()
            } else {
                openKeyboard()
            }

            return
        }

        if action.camera {
            openCamera()
            return
        }

        // No properties. Just send an empty reply.
        send()
    }

    @objc private func onCloseClicked() {
        NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didNotExecuteAction: action, for: notification)
        dismiss()
    }

    @objc private func onSendClicked() {
        sendButton.isEnabled = false
        activityIndicatorView.startAnimating()

        if let imageData = imageData {
            Notificare.shared.uploadNotificationReplyAsset(imageData, contentType: "image/jpeg") { result in
                switch result {
                case let .success(url):
                    self.mediaUrl = url
                    self.mediaMimeType = "image/jpeg"
                    self.send()
                case let .failure(error):
                    NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: self.action, for: self.notification, error: error)
                    self.dismiss()
                }
            }
        } else if let videoData = videoData {
            Notificare.shared.uploadNotificationReplyAsset(videoData, contentType: "video/quicktime") { result in
                switch result {
                case let .success(url):
                    self.mediaUrl = url
                    self.mediaMimeType = "video/quicktime"
                    self.send()
                case let .failure(error):
                    NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: self.action, for: self.notification, error: error)
                    self.dismiss()
                }
            }
        } else if message != nil {
            send()
        }
    }

    private func openCamera() {
        guard Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryUsageDescription") != nil,
              Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil,
              Bundle.main.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription") != nil
        else {
            NotificareLogger.warning("Missing camera, microphone or photo library permissions. Skipping...")
            return
        }

        imagePickerController = UIImagePickerController()

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            imagePickerController.allowsEditing = true
            imagePickerController.videoMaximumDuration = 10
        } else {
            imagePickerController.sourceType = .photoLibrary
        }

        imagePickerController.delegate = self

        NotificarePushUI.shared.presentController(imagePickerController, in: sourceViewController)
    }

    private func openKeyboard() {
        let messageView = UITextView(frame: CGRect(x: 0, y: 0, width: viewController.view.frame.width, height: viewController.view.frame.height - keyboardHeight))
        messageView.font = UIFont.systemFont(ofSize: 16)
        messageView.autocorrectionType = .default
        messageView.keyboardType = .default
        messageView.returnKeyType = .default

        self.messageView = messageView
        if let colorStr = theme?.textFieldBackgroundColor {
            messageView.backgroundColor = UIColor(hexString: colorStr)
        }
        if let colorStr = theme?.textFieldTextColor {
            messageView.textColor = UIColor(hexString: colorStr)
        }

        toolbar = UIToolbar(frame: CGRect(x: 0, y: viewController.view.frame.height - keyboardHeight, width: viewController.view.frame.width, height: 42))
        if let colorStr = theme?.toolbarBackgroundColor {
            toolbar.barTintColor = UIColor(hexString: colorStr)
        }

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, sendButton], animated: false)

        placeholderView.addSubview(messageView)
        placeholderView.addSubview(toolbar)
        messageView.becomeFirstResponder()

        viewController.view = placeholderView

        NotificarePushUI.shared.presentController(navigationController, in: sourceViewController)
    }

    private func showMedia(_ image: UIImage?) {
        // Use a square to display the image, this makes sure the image is in the right ratio.
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewController.view.frame.width, height: viewController.view.frame.width))
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        placeholderView.addSubview(imageView)

        if action.keyboard {
            let messageField = UITextField(frame: CGRect(x: 10, y: 10, width: viewController.view.frame.width - 65, height: 32))
            messageField.placeholder = NotificareLocalizable.string(resource: .actionsInputPlaceholder)
            messageField.borderStyle = .none
            if let colorStr = theme?.textFieldBackgroundColor {
                messageField.backgroundColor = UIColor(hexString: colorStr)
            }
            if let colorStr = theme?.textFieldTextColor {
                messageField.textColor = UIColor(hexString: colorStr)
            }
            messageField.font = UIFont.systemFont(ofSize: 14)
            messageField.autocorrectionType = .default
            messageField.keyboardType = .default
            messageField.returnKeyType = .default
            messageField.clearButtonMode = .whileEditing
            messageField.contentVerticalAlignment = .center
            messageField.becomeFirstResponder()

            self.messageField = messageField

            toolbar = UIToolbar(frame: CGRect(x: 0, y: viewController.view.frame.height - keyboardHeight, width: viewController.view.frame.width, height: 52))
            if let colorStr = theme?.toolbarBackgroundColor {
                toolbar.barTintColor = UIColor(hexString: colorStr)
            }

            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbar.setItems([flexibleSpace, sendButton], animated: false)
            toolbar.addSubview(messageField)

            placeholderView.addSubview(toolbar)
        } else {
            viewController.navigationItem.rightBarButtonItem = sendButton
        }

        viewController.view = placeholderView

        NotificarePushUI.shared.presentController(navigationController, in: sourceViewController)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }

        keyboardHeight = keyboardRect.height + toolbar.bounds.height

        toolbar.frame = CGRect(x: 0,
                               y: viewController.view.frame.height - keyboardHeight,
                               width: viewController.view.frame.width,
                               height: toolbar.bounds.height)

        imageView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: viewController.view.frame.width,
                                 height: viewController.view.frame.height - keyboardHeight)
    }

    private func dismiss() {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController, rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: true, completion: nil)
        } else {
            if sourceViewController is UIAlertController {
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            } else {
                sourceViewController.dismiss(animated: true) {
                    self.sourceViewController.becomeFirstResponder()
                }
            }
        }
    }

    private func send() {
        dismiss()

        guard let target = action.target, let url = URL(string: target), url.scheme != nil, url.host != nil else {
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didExecuteAction: action, for: notification)
            logAction()

            return
        }

        var params = [
            "label": action.label,
            "notificationID": notification.id,
        ]

        if let message = message {
            params["message"] = message
        }

        if let mediaUrl = mediaUrl {
            params["media"] = mediaUrl
        }

        if let mimeType = mediaMimeType {
            params["mimeType"] = mimeType
        }

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.queryItems?.forEach { item in
                params[item.name] = item.value
            }
        }

        let data: Data
        do {
            data = try NotificareUtils.jsonEncoder.encode(params)
        } catch {
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: action, for: notification, error: error)
            return
        }

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setMethod("POST", payload: data)

        URLSession.shared.perform(request) { result in
            switch result {
            case .success:
                NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didExecuteAction: self.action, for: self.notification)
            case let .failure(error):
                NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: self.action, for: self.notification, error: error)
            }

            self.logAction()
        }
    }

    private func logAction() {
        Notificare.shared.createNotificationReply(action, for: notification, message: message, media: mediaUrl, mimeType: mediaMimeType) { _ in }
    }
}

extension NotificareCallbackActionHandler: UIImagePickerControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if info[.mediaType] as? String == kUTTypeImage as String {
            if let image = info[.originalImage] as? UIImage {
                imageData = image.fixedOrientation()?.jpegData(compressionQuality: 0.9)

                picker.dismiss(animated: true) {
                    let thumbnail = UIImage(data: self.imageData!)!
                    self.showMedia(thumbnail)
                }
            }
        } else if info[.mediaType] as? String == kUTTypeVideo as String || info[.mediaType] as? String == kUTTypeMovie as String {
            if let url = info[.mediaURL] as? URL {
                videoData = try? Data(contentsOf: url)

                picker.dismiss(animated: true) {
                    let thumbnail = UIImage.renderVideoThumbnail(for: url)
                    self.showMedia(thumbnail)
                }
            }
        }
    }

    public func imagePickerControllerDidCancel(_: UIImagePickerController) {
        NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didNotExecuteAction: action, for: notification)
        dismiss()
    }
}

extension NotificareCallbackActionHandler: UINavigationControllerDelegate {}

extension UIImage {
    func fixedOrientation() -> UIImage? {
        // No-op if the orientation is already correct
        guard imageOrientation != .up else {
            return copy() as? UIImage
        }

        guard let cgImage = self.cgImage,
              let colorSpace = cgImage.colorSpace,
              let context = CGContext(data: nil,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: cgImage.bitsPerComponent,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: cgImage.bitmapInfo.rawValue)
        else {
            return nil
        }

        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.

        var transform: CGAffineTransform = .identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: .pi / -2.0)
        default:
            break
        }

        // Flip image one more time if needed to, this is to prevent flipped image.
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }

        context.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }

        guard let newCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage, scale: 1, orientation: .up)
    }

    static func renderVideoThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        avAssetImageGenerator.appliesPreferredTrackTransform = true
        let thumnailTime = CMTimeMake(value: 1, timescale: 2)

        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
            return UIImage(cgImage: cgThumbImage)
        } catch {
            return nil
        }
    }
}
