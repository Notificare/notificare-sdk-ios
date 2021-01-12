//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificarePushKit
import UIKit
import WebKit

public class NotificareVideoViewController: NotificareBaseNotificationViewController {
    private var webView: WKWebView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        setupContent()
    }

    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

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
            NotificarePush.shared.delegate?.notificare(NotificarePush.shared, didFailToOpenNotification: notification)
            return
        }

        switch content.type {
        case "re.notifica.content.YouTube":
            let htmlTemplate = "<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"https://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { autoplay: 1, width:'%0.0f', height:'%0.0f', videoId:'%@', events: { 'onReady': onPlayerReady } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>"

            let htmlStr = String(format: htmlTemplate, view.frame.width, view.frame.height, content.data as! String)
            webView.loadHTMLString(htmlStr, baseURL: Bundle.main.resourceURL)

        case "re.notifica.content.Vimeo":
            let htmlTemplate = "<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head><body><iframe src='https://player.vimeo.com/video/%@?autoplay=1' width='%0.0f' height='%0.0f' frameborder='0' webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe></body> </html>"

            let htmlStr = String(format: htmlTemplate, content.data as! String, view.frame.width, view.frame.height)
            webView.loadHTMLString(htmlStr, baseURL: Bundle.main.resourceURL)

        case "re.notifica.content.HTML5Video":
            let htmlTemplate = "<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head><body><video id='html5player' width='%0.0f' height='%0.0f' autoplay controls preload><source src='%@' type='video/mp4'></video></body></html>"

            let htmlStr = String(format: htmlTemplate, view.frame.width, view.frame.height, content.data as! String)
            webView.loadHTMLString(htmlStr, baseURL: Bundle.main.resourceURL)

        default:
            NotificarePush.shared.delegate?.notificare(NotificarePush.shared, didFailToOpenNotification: notification)
        }
    }
}

extension NotificareVideoViewController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlSchemes = NotificareUtils.getConfiguration()?.options?.urlSchemes,
           let url = navigationAction.request.url,
           let scheme = url.scheme,
           urlSchemes.contains(scheme)
        {
            NotificarePush.shared.delegate?.notificare(NotificarePush.shared, didClickURL: url, in: notification)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    public func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        NotificarePush.shared.delegate?.notificare(NotificarePush.shared, didFailToOpenNotification: notification)
    }
}
