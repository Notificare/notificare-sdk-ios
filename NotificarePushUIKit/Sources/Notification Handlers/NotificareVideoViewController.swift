//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit
import WebKit

public class NotificareVideoViewController: NotificareBaseNotificationViewController {
    private var webView: WKWebView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        // setupContent()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // NOTE: we're setting up the content when the view loads because,
        // at the moment, we need the correct height of the safe area.
        // We should improve the HTML template to be responsive.
        setupContent()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // NOTE: Loading a blank view to prevent the videos from continuing
        // playing after dismissing the view controller.
        webView.load(URLRequest(url: URL(string: "about:blank")!))

        DispatchQueue.main.async {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: self.notification)
        }
    }

    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        // View setup.
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        webView.uiDelegate = self

        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        // Clear cache.
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
                                                modifiedSince: Date(timeIntervalSince1970: 0),
                                                completionHandler: {})
    }

    private func setupContent() {
        guard let content = notification.content.first else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        switch content.type {
        case "re.notifica.content.YouTube":
            renderYouTubeVideo(content.data as! String)

        case "re.notifica.content.Vimeo":
            renderVimeoVideo(content.data as! String)

        case "re.notifica.content.HTML5Video":
            renderHtml5Video(content.data as! String)

        default:
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        DispatchQueue.main.async {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didPresentNotification: self.notification)
        }
    }

    private func renderYouTubeVideo(_ videoId: String) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="initial-scale=1, maximum-scale=1">
          <style>
            body {
              margin: 0;
            }

            #player {
              width: 100vw;
              height: 100vh;
            }
          </style>
        </head>
        <body>
          <iframe src="https://www.youtube-nocookie.com/embed/\(videoId)?enablejsapi=1"
                  id="player"
                  frameborder="0"
                  webkitallowfullscreen
                  mozallowfullscreen
                  allowfullscreen></iframe>

          <script type="text/javascript">
            var tag = document.createElement('script');
            tag.src = 'https://www.youtube.com/iframe_api';

            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

            var player;
            function onYouTubeIframeAPIReady() {
              player = new YT.Player('player', {
                events: {
                  'onReady': onPlayerReady,
                }
              });
            }

            function onPlayerReady(event) {
              event.target.playVideo();
            }
          </script>
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
    }

    private func renderVimeoVideo(_ videoId: String) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="initial-scale=1, maximum-scale=1">
          <style>
            body {
              margin: 0;
            }

            #player {
              width: 100vw;
              height: 100vh;
            }
          </style>
        </head>
        <body>
          <iframe src="https://player.vimeo.com/video/\(videoId)?autoplay=1"
                  id="player"
                  frameborder="0"
                  webkitallowfullscreen
                  mozallowfullscreen
                  allowfullscreen
          ></iframe>
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
    }

    private func renderHtml5Video(_ videoSource: String) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="initial-scale=1, maximum-scale=1">
          <style>
            body {
              margin: 0;
            }

            #player {
              width: 100vw;
              height: 100vh;
            }
          </style>
        </head>
        <body>
          <video id="player" autoplay controls preload>
            <source src="\(videoSource)" type="video/mp4">
          </video>
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
    }
}

extension NotificareVideoViewController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
           let scheme = url.scheme,
           Notificare.shared.options!.urlSchemes.contains(scheme)
        {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didClickURL: url, in: self.notification)
            }

            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    public func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        DispatchQueue.main.async {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
        }
    }
}

extension NotificareVideoViewController: NotificareNotificationPresenter {
    func present(in controller: UIViewController) {
        controller.presentOrPush(self)
    }
}
