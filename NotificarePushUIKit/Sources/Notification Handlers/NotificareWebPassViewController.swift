//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit
import WebKit

public class NotificareWebPassViewController: NotificareBaseNotificationViewController {
    private var webView: WKWebView!
    private var loadingView: UIView!
    private var progressView: UIProgressView!
    private var brightness: CGFloat = 0

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupContent()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: WKWebView.estimatedProgress)), options: .new, context: nil)

        brightness = UIScreen.main.brightness
        UIScreen.main.brightness = 1
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: WKWebView.estimatedProgress)))

        UIScreen.main.brightness = brightness

        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: notification)
    }

    private func setupViews() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        // View setup.
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)

        // Clear cache.
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
                                                modifiedSince: Date(timeIntervalSince1970: 0),
                                                completionHandler: {})

        // WebView constraints
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

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
              let passUrlStr = content.data as? String,
              let host = Notificare.shared.servicesInfo?.services.pushHost
        else {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: notification)
            return
        }

        let components = passUrlStr.components(separatedBy: "/")
        let id = components[components.count - 1]

        guard let url = URL(string: "\(host)/pass/web/\(id)?showWebVersion=1") else {
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

extension NotificareWebPassViewController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    public func webView(_: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if navigationResponse.response.mimeType == "application/vnd.apple.pkpass", let url = navigationResponse.response.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
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
}

extension NotificareWebPassViewController: NotificareNotificationPresenter {
    func present(in controller: UIViewController) {
        controller.presentOrPush(self)
    }
}
