//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificarePushKit
import UIKit
import WebKit

public class NotificareWebViewController: UIViewController {
    var notification: NotificareNotification!

    private var webView: WKWebView!
    private var actionsButton: UIBarButtonItem?

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Update the view controller's title.
        title = notification.title

        // Set the theme options.
        // TODO:

        configureWebView()
        clearCache()
        setupContent()
    }

    private func configureWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = [.video, .audio]

        let metaTag = "var meta = document.createElement('meta');meta.name = 'viewport';meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';var head = document.getElementsByTagName('head')[0];head.appendChild(meta);"
        let metaScript = WKUserScript(source: metaTag, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(metaScript)

        // View setup.
        webView = WKWebView(frame: view.frame, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        webView.uiDelegate = self

        view.addSubview(webView)
    }

    private func clearCache() {
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
                                                modifiedSince: Date(timeIntervalSince1970: 0),
                                                completionHandler: {})
    }

    private func setupContent() {
        guard let content = notification.content.first else {
            // didFailToOpenNotification
            return
        }

        let html = content.data as! String
        webView.loadHTMLString(html, baseURL: URL(string: ""))

        // Check if we should show any possible actions
        if !html.contains("notificareOpenAction"), !html.contains("notificareOpenActions"), !notification.actions.isEmpty {
            if let image = NotificareLocalizable.image(resource: .actions) {
                actionsButton = UIBarButtonItem(image: image,
                                                style: .plain,
                                                target: self,
                                                action: #selector(showActions))
            } else {
                actionsButton = UIBarButtonItem(title: NotificareLocalizable.string(resource: .actions),
                                                style: .plain,
                                                target: self,
                                                action: #selector(showActions))
            }

            navigationItem.rightBarButtonItem = actionsButton
        }
    }

    @objc private func showActions() {
        let alert = UIAlertController(title: nil, message: notification.message, preferredStyle: .actionSheet)

        notification.actions.forEach { action in
            alert.addAction(
                UIAlertAction(title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
                              style: .default,
                              handler: { _ in
//                                NotificarePush.shared.delegate?.notificare(NotificarePush.shared,
//                                                                           didOpenAction: action,
//                                                                           for: notification,
//                                                                           with: NotificareNotification.ActionData)
                              })
            )
        }

        alert.addAction(
            UIAlertAction(title: NotificareLocalizable.string(resource: .cancel),
                          style: .cancel,
                          handler: nil)
        )

        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.modalPresentationStyle = .popover
            alert.popoverPresentationController?.barButtonItem = actionsButton
        } else {
            alert.modalPresentationStyle = .currentContext
        }

        present(alert, animated: true, completion: nil)
    }
}

extension NotificareWebViewController: WKNavigationDelegate {}

extension NotificareWebViewController: WKUIDelegate {}
