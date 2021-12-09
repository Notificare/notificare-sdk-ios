//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit
import WebKit

public class NotificareUrlViewController: NotificareBaseNotificationViewController {
    private var webView: WKWebView!
    private var loadingView: UIView!
    private var progressView: UIProgressView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupContent()

        // Start as false regardless of available actions.
        // The final decision will be made after loading the HTML content.
        isActionsButtonEnabled = false
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: WKWebView.estimatedProgress)), options: .new, context: nil)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: WKWebView.estimatedProgress)))

        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: notification)
    }

    private func setupViews() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let metaTag = "webkit.messageHandlers.notificareWebViewLoading.postMessage(document.body.innerHTML);"
        let metaScript = WKUserScript(source: metaTag, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(metaScript)
        configuration.userContentController.add(self, name: "notificareWebViewLoading")

        // View setup.
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)

        // WebView constraints
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Clear cache.
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
                                                modifiedSince: Date(timeIntervalSince1970: 0),
                                                completionHandler: {})

        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        if let colorStr = theme?.backgroundColor {
            loadingView.backgroundColor = UIColor(hexString: colorStr)
        } else {
            if #available(iOS 13.0, *) {
                loadingView.backgroundColor = .systemBackground
            } else {
                loadingView.backgroundColor = .white
            }
        }

        view.addSubview(loadingView)

        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)

        // Progress view constraints
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalToConstant: 150),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupContent() {
        guard let content = notification.content.first,
              let url = URL(string: content.data as! String)
        else {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: notification)
            return
        }

        webView.load(URLRequest(url: url))
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == NSStringFromSelector(#selector(getter: WKWebView.estimatedProgress)), object as? WKWebView == webView {
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        } else {
            // Make sure to call the superclass's implementation in case it is also implementing KVO.
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

extension NotificareUrlViewController: WKScriptMessageHandler {
    public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "notificareWebViewLoading" {
            guard let html = message.body as? String else {
                isActionsButtonEnabled = !notification.actions.isEmpty
                return
            }

            isActionsButtonEnabled = !html.contains("notificareOpenAction") && !html.contains("notificareOpenActions") && !notification.actions.isEmpty
        }
    }
}

extension NotificareUrlViewController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if let scheme = url.scheme, Notificare.shared.options!.urlSchemes.contains(scheme) {
            handleNotificareQueryParameters(for: url)
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didClickURL: url, in: notification)
            decisionHandler(.cancel)
        } else if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
            decisionHandler(.allow)
        } else {
            handleNotificareQueryParameters(for: url)

            // Let's handle custom URLs if not http or https.
            if let url = navigationAction.request.url,
               let urlScheme = url.scheme,
               urlScheme != "http", urlScheme != "https",
               NotificareUtils.getSupportedUrlSchemes().contains(urlScheme) || UIApplication.shared.canOpenURL(url)
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

    public func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: notification)

        loadingView.removeFromSuperview()
        progressView.removeFromSuperview()
    }

    public func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: notification)

        loadingView.removeFromSuperview()
        progressView.removeFromSuperview()
    }

    public func webView(_: WKWebView, didFinish _: WKNavigation!) {
        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didPresentNotification: notification)

        loadingView.removeFromSuperview()
        progressView.removeFromSuperview()
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

extension NotificareUrlViewController: NotificareNotificationPresenter {
    func present(in controller: UIViewController) {
        controller.presentOrPush(self)
    }
}
