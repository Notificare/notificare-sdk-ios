//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import AVFoundation
import CoreGraphics
import CoreMedia
import MobileCoreServices
import NotificareKit
import NotificareUtilitiesKit
import UIKit

public class NotificareCallbackActionHandler: NotificareBaseActionHandler {
    private let sourceViewController: UIViewController

    private var theme: NotificareOptions.Theme?

    private var navigationController: UINavigationController!
    private var viewController: UIViewController!
    private var imageView: UIImageView!
    private var activityIndicatorView: UIActivityIndicatorView!
    private var toolbar: UIToolbar!
    private var closeButton: UIBarButtonItem!
    private var sendButton: UIBarButtonItem!
    private var imagePickerController: UIImagePickerController!
    private var messageView: UITextView?
    private var messageField: UITextField?

    private var toolbarBottomConstraint: NSLayoutConstraint?

    private var imageData: Data?
    private var videoData: Data?

    private var message: String? {
        messageField?.text ?? messageView?.text
    }

    private var mediaUrl: String?
    private var mediaMimeType: String?

    internal init(notification: NotificareNotification, action: NotificareNotification.Action, sourceViewController: UIViewController) {
        self.sourceViewController = sourceViewController
        super.init(notification: notification, action: action)

        viewController = UIViewController()
        navigationController = UINavigationController(rootViewController: viewController)

        theme = Notificare.shared.options!.theme(for: viewController)
        if let colorStr = theme?.backgroundColor {
            viewController.view.backgroundColor = UIColor(hexString: colorStr)
        } else {
            if #available(iOS 13.0, *) {
                viewController.view.backgroundColor = .systemBackground
            } else {
                viewController.view.backgroundColor = .white
            }
        }

        viewController.title = notification.title ?? Bundle.main.applicationName
        setupNavigationActions()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillAppear(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillDisappear(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    private func setupNavigationActions() {
        if Notificare.shared.options?.legacyNotificationsUserInterfaceEnabled == true {
            setupLegacyNavigationActions()
        } else {
            setupModernNavigationActions()
        }

        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.hidesWhenStopped = true
        if let colorStr = theme?.activityIndicatorColor {
            activityIndicatorView.tintColor = UIColor(hexString: colorStr)
        }

        viewController.navigationItem.leftBarButtonItem = closeButton
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
    }

    private func setupLegacyNavigationActions() {
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
    }

    private func setupModernNavigationActions() {
        closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(onCloseClicked)
        )

        sendButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.right"),
            style: .plain,
            target: self,
            action: #selector(onSendClicked)
        )

        if let colorStr = theme?.buttonTextColor {
            sendButton.tintColor = UIColor(hexString: colorStr)
        }
    }

    internal override func execute() {
        if action.camera, action.keyboard {
            // First get the camera going, then get the message.
            openCamera()
            return
        }

        if action.keyboard {
            openKeyboard()
            return
        }

        if action.camera {
            openCamera()
            return
        }

        // No properties. Just send an empty reply.
        Task {
            await send()
        }
    }

    @objc private func onCloseClicked() {
        DispatchQueue.main.async {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didNotExecuteAction: self.action, for: self.notification)
        }

        dismiss()
    }

    @objc private func onSendClicked() {
        sendButton.isEnabled = false
        activityIndicatorView.startAnimating()

        Task {
            if let imageData = imageData {
                do {
                    let url = try await Notificare.shared.uploadNotificationReplyAsset(imageData, contentType: "image/jpeg")

                    mediaUrl = url
                    mediaMimeType = "image/jpeg"

                    await send()
                } catch {
                    await MainActor.run {
                        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: error)
                    }

                    dismiss()
                }
            } else  if let videoData = videoData {
                do {
                    let url = try await Notificare.shared.uploadNotificationReplyAsset(videoData, contentType: "video/quicktime")

                    mediaUrl = url
                    mediaMimeType = "video/quicktime"

                    await send()
                } catch {
                    await MainActor.run {
                        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: error)
                    }

                    dismiss()
                }
            } else if message != nil {
                await send()
            }
        }
    }

    private func openCamera() {
        guard Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryUsageDescription") != nil,
              Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil,
              Bundle.main.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription") != nil
        else {
            logger.warning("Missing camera, microphone or photo library permissions. Skipping...")
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

        sourceViewController.presentOrPush(imagePickerController)
    }

    private func openKeyboard() {
        let messageView = UITextView()
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.font = UIFont.systemFont(ofSize: 16)
        messageView.autocorrectionType = .default
        messageView.keyboardType = .default
        messageView.returnKeyType = .default
        messageView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        self.messageView = messageView
        if let colorStr = theme?.textFieldBackgroundColor {
            messageView.backgroundColor = UIColor(hexString: colorStr)
        }
        if let colorStr = theme?.textFieldTextColor {
            messageView.textColor = UIColor(hexString: colorStr)
        }

        toolbar = UIToolbar(frame: .zero)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .vertical)
        toolbar.setContentHuggingPriority(UILayoutPriority(rawValue: 751), for: .vertical)
        if let colorStr = theme?.toolbarBackgroundColor {
            toolbar.barTintColor = UIColor(hexString: colorStr)
        }

        toolbar.setItems(
            [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                sendButton,
            ],
            animated: false
        )

        viewController.view.addSubview(messageView)
        viewController.view.addSubview(toolbar)

        let toolbarBottomConstraint = toolbar.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        self.toolbarBottomConstraint = toolbarBottomConstraint

        NSLayoutConstraint.activate([
            // Message view
            messageView.topAnchor.constraint(equalTo: viewController.view.ncSafeAreaLayoutGuide.topAnchor),
            messageView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            messageView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            // Toolbar
            toolbar.topAnchor.constraint(equalTo: messageView.bottomAnchor),
            toolbarBottomConstraint,
            toolbar.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
        ])

        messageView.becomeFirstResponder()

        sourceViewController.presentOrPush(navigationController)
    }

    private func showMedia(_ image: UIImage?) {
        // Use a square to display the image, this makes sure the image is in the right ratio.
        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = image
        viewController.view.addSubview(imageView)

        if action.keyboard {
            let messageField = UITextField()
            messageField.translatesAutoresizingMaskIntoConstraints = false
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

            toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: viewController.view.frame.width, height: 44))
            toolbar.translatesAutoresizingMaskIntoConstraints = false
            toolbar.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .vertical)
            toolbar.setContentHuggingPriority(UILayoutPriority(rawValue: 751), for: .vertical)
            if let colorStr = theme?.toolbarBackgroundColor {
                toolbar.barTintColor = UIColor(hexString: colorStr)
            }

            toolbar.setItems(
                [
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                    sendButton,
                ],
                animated: false
            )

            toolbar.addSubview(messageField)
            NSLayoutConstraint.activate([
                messageField.topAnchor.constraint(equalTo: toolbar.topAnchor),
                messageField.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor),
                messageField.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 16),
                messageField.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -16 - 44),
            ])

            let toolbarBottomConstraint = toolbar.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
            self.toolbarBottomConstraint = toolbarBottomConstraint

            viewController.view.addSubview(toolbar)
            NSLayoutConstraint.activate([
                // Image view: available space
                imageView.topAnchor.constraint(equalTo: viewController.view.ncSafeAreaLayoutGuide.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: viewController.view.ncSafeAreaLayoutGuide.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: viewController.view.ncSafeAreaLayoutGuide.trailingAnchor),
                // Toolbar
                toolbar.topAnchor.constraint(equalTo: imageView.bottomAnchor),
                toolbarBottomConstraint,
                toolbar.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
                toolbar.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                // Image view: square
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
                imageView.topAnchor.constraint(equalTo: viewController.view.ncSafeAreaLayoutGuide.topAnchor),
                imageView.bottomAnchor.constraint(lessThanOrEqualTo: viewController.view.ncSafeAreaLayoutGuide.bottomAnchor),
                imageView.leadingAnchor.constraint(equalTo: viewController.view.ncSafeAreaLayoutGuide.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: viewController.view.ncSafeAreaLayoutGuide.trailingAnchor),
            ])

            viewController.navigationItem.rightBarButtonItem = sendButton
        }

        sourceViewController.presentOrPush(navigationController)
    }

    @objc private func keyboardWillAppear(_ notification: Notification) {
        guard UIDevice.current.userInterfaceIdiom != .pad else {
            return
        }

        guard let userInfo = notification.userInfo,
              let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }

        toolbarBottomConstraint?.constant = -keyboardRect.height
    }

    @objc private func keyboardWillDisappear(_ notification: Notification) {
        toolbarBottomConstraint?.constant = 0
    }

    private func dismiss() {
        if let rootViewController = UIApplication.shared.rootViewController, rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: true, completion: nil)
        } else {
            if sourceViewController is UIAlertController {
                UIApplication.shared.rootViewController?.dismiss(animated: true, completion: nil)
            } else {
                sourceViewController.dismiss(animated: true) {
                    self.sourceViewController.becomeFirstResponder()
                }
            }
        }
    }

    @MainActor
    private func send() {
        dismiss()

        guard let target = action.target, let url = URL(string: target), url.scheme != nil, url.host != nil else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
            }

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
            data = try JSONEncoder.notificare.encode(params)
        } catch {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: error)
            }

            return
        }

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setMethod("POST", payload: data)

        URLSession.shared.perform(request) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: error)
                }
            }

            self.logAction()
        }
    }

    private func logAction() {
        Task {
            try? await Notificare.shared.createNotificationReply(notification: notification, action: action, message: message, media: mediaUrl, mimeType: mediaMimeType)
        }
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
        DispatchQueue.main.async {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didNotExecuteAction: self.action, for: self.notification)
        }

        dismiss()
    }
}

extension NotificareCallbackActionHandler: UINavigationControllerDelegate {}

extension UIImage {
    internal func fixedOrientation() -> UIImage? {
        // No-op if the orientation is already correct
        guard imageOrientation != .up else {
            return copy() as? UIImage
        }

        guard let cgImage = cgImage,
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

    internal static func renderVideoThumbnail(for url: URL) -> UIImage? {
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
