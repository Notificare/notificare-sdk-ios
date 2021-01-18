//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import AVFoundation
import CoreGraphics
import CoreMedia
import MobileCoreServices
import NotificareCore
import NotificareKit
import NotificarePushKit
import UIKit

class NotificareCallbackActionHandler: NotificareBaseActionHandler {
    private let response: NotificareNotification.ResponseData?
    private let sourceViewController: UIViewController

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
    private var mediaUrl: String?
    private var message: String? {
        response?.userText ?? messageField?.text ?? messageView?.text
    }

    init(notification: NotificareNotification, action: NotificareNotification.Action, response: NotificareNotification.ResponseData?, sourceViewController: UIViewController) {
        self.response = response
        self.sourceViewController = sourceViewController
        super.init(notification: notification, action: action)

        viewController = UIViewController()
        navigationController = UINavigationController(rootViewController: viewController)

        // TODO: [self setTheme:[[NotificareAppConfig shared] themeForController:[self controller]]];

        placeholderView = UIView(frame: CGRect(x: 0, y: 0, width: viewController.view.frame.width, height: viewController.view.frame.height))
        placeholderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // TODO: [[self placeholderView] setBackgroundColor:[UIColor colorWithHexString:[[self theme] objectForKey:@"BACKGROUND_COLOR"]]];

        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewController.view.frame.width, height: viewController.view.frame.height))
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // TODO: [[self imageView] setTintColor:[UIColor colorWithHexString:[[self theme] objectForKey:@"BACKGROUND_COLOR"]]];

        if let image = NotificareLocalizable.image(resource: .close) {
            closeButton = UIBarButtonItem(image: image,
                                          style: .plain,
                                          target: self,
                                          action: #selector(onCloseClicked))

            // TODO: [[self closeButton] setTintColor:[UIColor colorWithHexString:[[self theme] objectForKey:@"ACTION_BUTTON_TEXT_COLOR"]]];
        } else {
            closeButton = UIBarButtonItem(title: NotificareLocalizable.string(resource: .closeButton),
                                          style: .plain,
                                          target: self,
                                          action: #selector(onCloseClicked))
        }

        if let image = NotificareLocalizable.image(resource: .send) {
            sendButton = UIBarButtonItem(image: image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(onSendClicked))

            // TODO: [[self sendButton] setTintColor:[UIColor colorWithHexString:[[self theme] objectForKey:@"BUTTONS_TEXT_COLOR"]]];
        } else {
            sendButton = UIBarButtonItem(title: NotificareLocalizable.string(resource: .sendButton),
                                         style: .plain,
                                         target: self,
                                         action: #selector(onSendClicked))
        }

        activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.hidesWhenStopped = true
        // TODO: [[self activityIndicator] setTintColor:[UIColor colorWithHexString:[[self theme] objectForKey:@"ACTIVITY_INDICATOR_COLOR"]]];

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
        // [[self delegate] actionType:self didNotExecuteAction:[self action]];
        dismiss()
    }

    @objc private func onSendClicked() {
        sendButton.isEnabled = false
        activityIndicatorView.startAnimating()

        if let imageData = imageData {
            NotificarePush.shared.uploadNotificationActionReplyAsset(imageData, contentType: "image/jpeg") { result in
                switch result {
                case let .success(url):
                    self.mediaUrl = url
                    self.send()
                case .failure:
                    // [[self delegate] actionType:self didFailToExecuteAction:[self action] withError:error];
                    // self.sendButton.isEnabled = true
                    self.dismiss()
                }
            }
        } else if let videoData = videoData {
            //
        } else if message != nil {
            send()
        }
    }

    private func openCamera() {
        guard Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryUsageDescription") != nil,
              Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil
        else {
            NotificareLogger.warning("Missing camera and photo library permissions. Skipping...")
            return
        }

        imagePickerController = UIImagePickerController()

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera

            // Uncomment the following line to allow images and movies.
            // imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]

            // For now only images - comment out when introducing video
            imagePickerController.mediaTypes = [kUTTypeImage as String]

            imagePickerController.allowsEditing = true
            // imagePickerController.videoMaximumDuration = 10
        } else {
            imagePickerController.sourceType = .photoLibrary
        }

        imagePickerController.delegate = self

        NotificarePushUI.presentController(imagePickerController, in: sourceViewController)
    }

    private func openKeyboard() {
        let messageView = UITextView(frame: CGRect(x: 0, y: 0, width: viewController.view.frame.width, height: viewController.view.frame.height - keyboardHeight))
        messageView.font = UIFont.systemFont(ofSize: 16)
        messageView.autocorrectionType = .default
        messageView.keyboardType = .default
        messageView.returnKeyType = .default

        self.messageView = messageView

        // [[self messageView] setBackgroundColor:[UIColor colorWithHexString:[[self theme] objectForKey:@"TEXTFIELD_BACKGROUND_COLOR"]]];
        // [[self messageView] setTextColor:[UIColor colorWithHexString:[[self theme] objectForKey:@"TEXTFIELD_TEXT_COLOR"]]];

        toolbar = UIToolbar(frame: CGRect(x: 0, y: viewController.view.frame.height - keyboardHeight, width: viewController.view.frame.width, height: 42))
        // [[self toolBar] setBarTintColor:[UIColor colorWithHexString:[[self theme] objectForKey:@"TOOLBAR_COLOR"]]];

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, sendButton], animated: false)

        placeholderView.addSubview(messageView)
        placeholderView.addSubview(toolbar)
        messageView.becomeFirstResponder()

        viewController.view = placeholderView

        NotificarePushUI.presentController(navigationController, in: sourceViewController)
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
            // [[self messageField] setBackgroundColor:[UIColor colorWithHexString:[[self theme] objectForKey:@"TEXTFIELD_BACKGROUND_COLOR"]]];
            // [[self messageField] setTextColor:[UIColor colorWithHexString:[[self theme] objectForKey:@"TEXTFIELD_TEXT_COLOR"]]];
            messageField.font = UIFont.systemFont(ofSize: 14)
            messageField.autocorrectionType = .default
            messageField.keyboardType = .default
            messageField.returnKeyType = .default
            messageField.clearButtonMode = .whileEditing
            messageField.contentVerticalAlignment = .center
            messageField.becomeFirstResponder()

            self.messageField = messageField

            toolbar = UIToolbar(frame: CGRect(x: 0, y: viewController.view.frame.height - keyboardHeight, width: viewController.view.frame.width, height: 42))
            // [[self toolBar] setBarTintColor:[UIColor colorWithHexString:[[self theme] objectForKey:@"TOOLBAR_COLOR"]]];

            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbar.setItems([flexibleSpace, sendButton], animated: false)
            toolbar.addSubview(messageField)

            placeholderView.addSubview(toolbar)
        } else {
            viewController.navigationItem.rightBarButtonItem = sendButton
        }

        viewController.view = placeholderView

        NotificarePushUI.presentController(navigationController, in: sourceViewController)
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
            // [[self delegate] actionType:self didExecuteAction:[self action]];
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

        guard let data = try? NotificareUtils.jsonEncoder.encode(params) else {
            // [[self delegate] actionType:self didFailToExecuteAction:[self action] withError:error];
            return
        }

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.queryItems?.forEach { item in
                params[item.name] = item.value
            }
        }

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setMethod("POST", payload: data)

        URLSession.shared.perform(request) { result in
            switch result {
            case .success:
                // [[self delegate] actionType:self didExecuteAction:[self action]];
                break
            case let .failure(error):
                // [[self delegate] actionType:self didFailToExecuteAction:[self action] withError:error];
                break
            }

            self.logAction()
        }
    }

    private func logAction() {
        NotificarePush.shared.submitNotificationActionReply(action, for: notification, message: message, media: mediaUrl) { _ in }
    }
}

extension NotificareCallbackActionHandler: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if info[.mediaType] as? String == kUTTypeImage as String {
            if let image = info[.originalImage] as? UIImage {
                imageData = image.fixedOrientation()?.jpegData(compressionQuality: 0.9)

                picker.dismiss(animated: true) {
                    let thumbnail = UIImage(data: self.imageData!)!
                    self.showMedia(thumbnail)
                }
            }
        } else if info[.mediaType] as? String == kUTTypeVideo as String {
            if let url = info[.mediaURL] as? URL {
                videoData = try? Data(contentsOf: url)

                picker.dismiss(animated: true) {
                    let thumbnail = UIImage.renderVideoThumbnail(for: url)
                    self.showMedia(thumbnail)
                }
            }
        }
    }

    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        // [[self delegate] actionType:self didNotExecuteAction:[self action]];
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
