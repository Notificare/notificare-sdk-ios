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
            NotificarePush.shared.delegate?.notificare(NotificarePush.shared, didFailToOpenNotification: notification)
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
                              handler: { _ in self.handleAction(action) })
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

    private func hasNotificareQueryParameters(in url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }

        guard let queryItems = components.queryItems else {
            return false
        }

        return queryItems.contains { (item) -> Bool in
            // TODO: Handle custom close_window_query_parameter.
            if item.name == "notificareCloseWindow" { // || ([[[NotificareAppConfig shared] options] objectForKey:@"CLOSE_WINDOW_QUERY_PARAMETER"] && [[item name] isEqualToString:[[[NotificareAppConfig shared] options] objectForKey:@"CLOSE_WINDOW_QUERY_PARAMETER"]])
                return true
            } else if item.name == "notificareOpenActions", item.value == "1" || item.value == "true" {
                return true
            } else if item.name == "notificareOpenAction" {
                return true
            }

            return false
        }
    }

    private func handleNotificareQueryParameters(for url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        guard let queryItems = components.queryItems else {
            return
        }

        queryItems.forEach { item in
            // TODO: Handle custom close_window_query_parameter.
            if item.name == "notificareCloseWindow" { // || ([[[NotificareAppConfig shared] options] objectForKey:@"CLOSE_WINDOW_QUERY_PARAMETER"] && [[item name] isEqualToString:[[[NotificareAppConfig shared] options] objectForKey:@"CLOSE_WINDOW_QUERY_PARAMETER"]])
                if item.value == "1" || item.value == "true" {
                    if let rootViewController = UIApplication.shared.keyWindow?.rootViewController, rootViewController.presentedViewController != nil {
                        rootViewController.dismiss(animated: true, completion: nil)
                    } else {
                        navigationController?.popViewController(animated: true)
                    }
                }
            } else if item.name == "notificareOpenActions", item.value == "1" || item.value == "true" {
                showActions()
            } else if item.name == "notificareOpenAction" {
                // A query param to open a single action is present, let's loop over the actins and match the label.
                notification.actions.forEach { action in
                    if action.label == item.value {
                        handleAction(action)
                    }
                }
            }
        }
    }

    private func handleAction(_: NotificareNotification.Action) {
        // TODO: Handle action clicked / wants to execute. Should present the according UI.

        // Label found, handle single action.
//                        [[self notificareActions] setRootViewController:self];
//                        [[self notificareActions] setNotification:[self notification]];
//                        [[self notificareActions] handleAction:action];
    }
}

extension NotificareWebViewController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        NotificarePush.shared.delegate?.notificare(NotificarePush.shared, didFailToOpenNotification: notification)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // TODO: parse from the configuration file
        let urlSchemes: [String]? = nil

        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if let urlSchemes = urlSchemes, let scheme = url.scheme, urlSchemes.contains(scheme) {
            handleNotificareQueryParameters(for: url)
            NotificarePush.shared.delegate?.notificare(NotificarePush.shared, didClickURL: url, in: notification)
            decisionHandler(.cancel)
        } else if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
            decisionHandler(.allow)
        } else {
            handleNotificareQueryParameters(for: url)

            // Let's handle custom URLs if not http or https.
            if let url = navigationAction.request.url,
               let scheme = url.scheme,
               scheme != "http", scheme != "https",
               UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.open(url, options: [:]) { _ in
                    decisionHandler(.cancel)
                }

                return
            }

            if hasNotificareQueryParameters(in: url) {
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }

    public func webView(_: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alert.addAction(
            UIAlertAction(title: NotificareLocalizable.string(resource: .ok), style: .default, handler: { _ in
                completionHandler()
            })
        )

        present(alert, animated: true, completion: nil)
    }

    public func webView(_: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alert.addAction(
            UIAlertAction(title: NotificareLocalizable.string(resource: .ok), style: .default, handler: { _ in
                completionHandler(true)
            })
        )

        alert.addAction(
            UIAlertAction(title: NotificareLocalizable.string(resource: .cancel), style: .cancel, handler: { _ in
                completionHandler(false)
            })
        )

        present(alert, animated: true, completion: nil)
    }

    public func webView(_: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.text = defaultText
        }

        alert.addAction(
            UIAlertAction(title: NotificareLocalizable.string(resource: .ok), style: .default, handler: { _ in
                if let text = alert.textFields?.first?.text, !text.isEmpty {
                    completionHandler(text)
                } else {
                    completionHandler(defaultText)
                }
            })
        )

        alert.addAction(
            UIAlertAction(title: NotificareLocalizable.string(resource: .cancel), style: .cancel, handler: { _ in
                completionHandler(nil)
            })
        )

        present(alert, animated: true, completion: nil)
    }
}
