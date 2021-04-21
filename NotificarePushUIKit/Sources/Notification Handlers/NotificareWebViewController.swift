//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit
import WebKit

public class NotificareWebViewController: NotificareBaseNotificationViewController {
    private var webView: WKWebView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        configureWebView()
        setupContent()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFinishPresentingNotification: notification)
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

        // Clear cache.
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
                                                modifiedSince: Date(timeIntervalSince1970: 0),
                                                completionHandler: {})
    }

    private func setupContent() {
        guard let content = notification.content.first else {
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToPresentNotification: notification)
            return
        }

        let html = content.data as! String
        webView.loadHTMLString(html, baseURL: URL(string: ""))

        NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didPresentNotification: notification)

        // Check if we should show any possible actions
        if html.contains("notificareOpenAction") || html.contains("notificareOpenActions") {
            isActionsButtonEnabled = false
        }
    }
}

extension NotificareWebViewController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToPresentNotification: notification)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if let scheme = url.scheme, Notificare.shared.options!.urlSchemes.contains(scheme) {
            handleNotificareQueryParameters(for: url)
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didClickURL: url, in: notification)
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
        let alert = UIAlertController(title: NotificareUtils.applicationName,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(
            UIAlertAction(title: NotificareLocalizable.string(resource: .ok), style: .default, handler: { _ in
                completionHandler()
            })
        )

        present(alert, animated: true, completion: nil)
    }

    public func webView(_: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: NotificareUtils.applicationName,
                                      message: message,
                                      preferredStyle: .alert)

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
        let alert = UIAlertController(title: NotificareUtils.applicationName,
                                      message: prompt,
                                      preferredStyle: .alert)

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

extension NotificareWebViewController: NotificareNotificationPresenter {
    func present(in controller: UIViewController) {
        NotificarePushUI.shared.presentController(self, in: controller)
    }
}
