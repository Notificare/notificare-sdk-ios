//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificarePushKit
import UIKit
import WebKit

public class NotificareWebViewController: UIViewController {
    var notification: NotificareNotification!

    private var webView: WKWebView!

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
            //         TODO: check if there's a custom icon
            //            if([UIImage imageFromBundle:@"actionsIcon"]){
            //                [self setActionsButton:[[UIBarButtonItem alloc]
            //                                        initWithImage:[UIImage imageFromBundle:@"actionsIcon"]
            //                                        style:UIBarButtonItemStylePlain
            //                                        target:self
            //                                        action:@selector(openActions)]];
            //
            //                if ([[self theme] objectForKey:@"ACTION_BUTTON_TEXT_COLOR"]) {
            //                    [[self actionsButton] setTintColor:[UIColor colorWithHexString:[[self theme] objectForKey:@"ACTION_BUTTON_TEXT_COLOR"]]];
            //                }

            let actionButton = UIBarButtonItem(title: "Actions",
                                               style: .plain,
                                               target: self,
                                               action: #selector(showActions))

            navigationItem.rightBarButtonItem = actionButton
        }
    }

    @objc private func showActions() {
        let alert = UIAlertController(title: nil, message: notification.message, preferredStyle: .actionSheet)

        notification.actions.forEach { action in
            let button = UIAlertAction(title: action.label, style: .default) { _ in
                // TODO: handle action
            }

            alert.addAction(button)
        }

        // alert.addAction(UIAlertAction(title: <#T##String?#>, style: <#T##UIAlertAction.Style#>, handler: <#T##((UIAlertAction) -> Void)?##((UIAlertAction) -> Void)?##(UIAlertAction) -> Void#>))

        present(alert, animated: true, completion: nil)

        //        UIAlertController * alert = [UIAlertController
        //                                      alertControllerWithTitle:[NSString appName]
        //                                      message:[[self notification] notificationMessage]
        //                                      preferredStyle:UIAlertControllerStyleActionSheet];
        //
        //
        //        for (NotificareAction * action in [[self notification] notificationActions]) {
        //
        //            UIAlertAction* button = [UIAlertAction
        //                                     actionWithTitle:([NSString stringFromBundle:[action actionLabel]])? [NSString stringFromBundle:[action actionLabel]] :[action actionLabel]
        //                                     style:UIAlertActionStyleDefault
        //                                     handler:^(UIAlertAction * actionAlert)
        //                                     {
        //                                         [[self notificareActions] setRootViewController:self];
        //                                         [[self notificareActions] setNotification:[self notification]];
        //                                         [[self notificareActions] handleAction:action];
        //
        //                                     }];
        //
        //            [alert addAction:button];
        //
        //
        //        }
        //
        //
        //        UIAlertAction* cancel = [UIAlertAction
        //                                 actionWithTitle:([NSString stringFromBundle:@"cancel"])?[NSString stringFromBundle:@"cancel"]:@"cancel"
        //                                 style:UIAlertActionStyleCancel
        //                                 handler:^(UIAlertAction * action)
        //                                 {
        //
        //
        //                                 }];
        //        [alert addAction:cancel];
        //
        //
        //        if ( IS_IPAD ) {
        //            [alert setModalPresentationStyle:UIModalPresentationPopover];
        //            UIPopoverPresentationController *popPresenter = [alert
        //                                                             popoverPresentationController];
        //
        //            [popPresenter setBarButtonItem:[self actionsButton]];
        //
        //        } else {
        //
        //            [alert setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        //        }
        //
        //        [[self navigationController] presentViewController:alert animated:YES completion:^{
        //
        //        }];
    }
}

extension NotificareWebViewController: WKNavigationDelegate {}

extension NotificareWebViewController: WKUIDelegate {}
