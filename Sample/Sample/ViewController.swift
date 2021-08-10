//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareAssetsKit
import NotificareAuthenticationKit
import NotificareInboxKit
import NotificareKit
import NotificareLoyaltyKit
import NotificarePushKit
import NotificarePushUIKit
import NotificareScannablesKit
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        NotificareScannables.shared.delegate = self
    }

    @IBAction func onLaunchClicked(_: Any) {
        Notificare.shared.launch()
    }

    @IBAction func onUnlaunchClicked(_: Any) {
        Notificare.shared.unlaunch()
    }

    @IBAction private func onEnableRemoteNotificationsClick(_: Any) {
        NotificarePush.shared.enableRemoteNotifications { result in
            switch result {
            case let .success(granted):
                print("-----> User allowed notifications: \(granted)")
            case let .failure(error):
                print("-----> Something went wrong: \(error)")
            }
        }
    }

    @IBAction func onDisableRemoteNotificationsClick(_: Any) {
        NotificarePush.shared.disableRemoteNotifications()
    }

    @IBAction func onSendCustomEventClick(_: Any) {
        let data: NotificareEventData = [
            "color": "blue",
        ]

        Notificare.shared.eventsManager.logCustom("test", data: data) { _ in
        }
    }

    @IBAction func onRegisterWithUserClick(_: Any) {
        Notificare.shared.deviceManager.register(userId: "d09f8b8e-2c10-4ae9-82e5-44f1bf627d89", userName: "John Doe") { result in
            switch result {
            case .success:
                print("Device registered with user.")
            case let .failure(error):
                print("Failed to register device with user: \(error)")
            }
        }
    }

    @IBAction func onRegisterAnonymousClick(_: Any) {
        Notificare.shared.deviceManager.register(userId: nil, userName: nil) { result in
            switch result {
            case .success:
                print("Device registered anonymously.")
            case let .failure(error):
                print("Failed to register device anonymously: \(error)")
            }
        }
    }

    @IBAction func onFetchUserDataClick(_: Any) {
        Notificare.shared.deviceManager.fetchUserData { result in
            switch result {
            case let .success(userData):
                NotificareLogger.info("User data = \(userData)")

            case let .failure(error):
                NotificareLogger.error("Failed to fetch user data.\n\(error)")
            }
        }
    }

    @IBAction func onListInboxItemsClick(_: Any) {
        print("-----> Inbox items")
        print(NotificareInbox.shared.items)
    }

    @IBAction func onRefreshBadgeClick(_: Any) {
        NotificareInbox.shared.refreshBadge { result in
            switch result {
            case let .success(badge):
                print("-----> Badge: \(badge)")
            case let .failure(error):
                print("-----> Failed to refresh the badge: \(error)")
            }
        }
    }

    @IBAction func onFetchAssetsClick(_: Any) {
        NotificareAssets.shared.fetchAssets(for: "LANDSCAPES") { result in
            switch result {
            case let .success(assets):
                print("Assets = \(assets)")
            case let .failure(error):
                print("Failed to fetch assets.\n\(error)")
            }
        }
    }

    @IBAction func onStartScannableSessionClick(_: Any) {
        if NotificareScannables.shared.canStartNfcScannableSession {
            NotificareScannables.shared.startNfcScannableSession()
        } else {
            NotificareScannables.shared.startQrCodeScannableSession(controller: navigationController!, modal: true)
        }
    }

    @IBAction func onFetchPassClick(_: Any) {
        NotificareLoyalty.shared.fetchPass(serial: "2e5cdf49-83f8-4029-b5bb-dc478ff309b9") { result in
            switch result {
            case let .success(pass):
                print("Pass = \(pass)")
            case let .failure(error):
                print("Failed to fetch pass.\n\(error)")
            }
        }

//        NotificareLoyalty.shared.fetchPass(barcode: "2e5cdf49-83f8-4029-b5bb-dc478ff309b9") { result in
//            switch result {
//            case let .success(pass):
//                print("Pass = \(pass)")
//            case let .failure(error):
//                print("Failed to fetch pass.\n\(error)")
//            }
//        }
    }

    @IBAction func onLoginClicked(_: Any) {
        NotificareAuthentication.shared.login(
            email: "helder@notifica.re",
            password: "123456"
        ) { result in
            switch result {
            case .success:
                print("Done.")
            case let .failure(error):
                print("Failed to login.\n\(error)")
            }
        }
    }

    @IBAction func onLogoutClicked(_: Any) {
        NotificareAuthentication.shared.logout { result in
            switch result {
            case .success:
                print("Done.")
            case let .failure(error):
                print("Failed to logout.\n\(error)")
            }
        }
    }

    @IBAction func onFetchUserDetailsClicked(_: Any) {
        NotificareAuthentication.shared.fetchUserDetails { result in
            switch result {
            case let .success(user):
                print("User details = \(user)")
            case let .failure(error):
                print("Failed to login.\n\(error)")
            }
        }

        NotificareAuthentication.shared.fetchUserDetails { result in
            switch result {
            case let .success(user):
                print("User details = \(user)")
            case let .failure(error):
                print("Failed to login.\n\(error)")
            }
        }

        NotificareAuthentication.shared.fetchUserDetails { result in
            switch result {
            case let .success(user):
                print("User details = \(user)")
            case let .failure(error):
                print("Failed to login.\n\(error)")
            }
        }

        NotificareAuthentication.shared.fetchUserDetails { result in
            switch result {
            case let .success(user):
                print("User details = \(user)")
            case let .failure(error):
                print("Failed to login.\n\(error)")
            }
        }

        NotificareAuthentication.shared.fetchUserDetails { result in
            switch result {
            case let .success(user):
                print("User details = \(user)")
            case let .failure(error):
                print("Failed to login.\n\(error)")
            }
        }
    }

    @IBAction func onFetchUserPreferencesClicked(_: Any) {
        NotificareAuthentication.shared.fetchUserPreferences { result in
            switch result {
            case let .success(preferences):
                print("User preferences = \(preferences)")
            case let .failure(error):
                print("Failed.\n\(error)")
            }
        }
    }

    @IBAction func onFetchUserSegmentsClicked(_: Any) {
        NotificareAuthentication.shared.fetchUserSegments { result in
            switch result {
            case let .success(segments):
                print("User segments = \(segments)")
            case let .failure(error):
                print("Failed.\n\(error)")
            }
        }
    }

    @IBAction func onSendPasswordResetClicked(_: Any) {
        NotificareAuthentication.shared.sendPasswordReset(email: "helder@notifica.re") { result in
            switch result {
            case .success:
                print("Done.")
            case let .failure(error):
                print("Failed.\n\(error)")
            }
        }
    }

    @IBAction func onResetPasswordClicked(_: Any) {
        NotificareAuthentication.shared.resetPassword("123456", token: "---") { result in
            switch result {
            case .success:
                print("Done.")
            case let .failure(error):
                print("Failed.\n\(error)")
            }
        }
    }

    @IBAction func onChangePasswordClicked(_: Any) {
        NotificareAuthentication.shared.changePassword("123456") { result in
            switch result {
            case .success:
                print("Done.")
            case let .failure(error):
                print("Failed.\n\(error)")
            }
        }
    }

    @IBAction func onValidateUserClicked(_: Any) {
        NotificareAuthentication.shared.validateUser(token: "---") { result in
            switch result {
            case .success:
                print("Done.")
            case let .failure(error):
                print("Failed.\n\(error)")
            }
        }
    }

    @IBAction func onGeneratePushEmailClicked(_: Any) {
        NotificareAuthentication.shared.generatePushEmailAddress { result in
            switch result {
            case let .success(user):
                print("User = \(user)")
            case let .failure(error):
                print("Failed.\n\(error)")
            }
        }
    }

    @IBAction func onAddUserSegmentClicked(_: Any) {
        NotificareAuthentication.shared.fetchUserSegments { result in
            switch result {
            case let .success(segments):
                let segment = segments.first!

                NotificareAuthentication.shared.addUserSegment(segment) { result in
                    switch result {
                    case .success:
                        print("Done.")
                    case let .failure(error):
                        print("Failed.\n\(error)")
                    }
                }
            case let .failure(error):
                print("Failed.\n\(error)")
            }
        }
    }

    @IBAction func onRemoveUserSegmentClicked(_: Any) {
        NotificareAuthentication.shared.fetchUserSegments { result in
            switch result {
            case let .success(segments):
                let segment = segments.first!

                NotificareAuthentication.shared.removeUserSegment(segment) { result in
                    switch result {
                    case .success:
                        print("Done.")
                    case let .failure(error):
                        print("Failed.\n\(error)")
                    }
                }
            case let .failure(error):
                print("Failed.\n\(error)")
            }
        }
    }

    @IBAction func onAddUserSegmentToPreferenceClicked(_: Any) {
        NotificareAuthentication.shared.fetchUserPreferences { result in
            switch result {
            case let .success(preferences):
                let preference = preferences.first!
                let option = preference.options.first!

                NotificareAuthentication.shared.addUserSegmentToPreference(option: option, to: preference) { result in
                    switch result {
                    case .success:
                        print("Done.")
                    case let .failure(error):
                        print("Failed.\n\(error)")
                    }
                }
            case let .failure(error):
                print("Failed.\n\(error)")
            }
        }
    }

    @IBAction func onRemoveUserSegmentFromPreferenceClicked(_: Any) {
        NotificareAuthentication.shared.fetchUserPreferences { result in
            switch result {
            case let .success(preferences):
                let preference = preferences.first!
                let option = preference.options.first!

                NotificareAuthentication.shared.removeUserSegmentFromPreference(option: option, from: preference) { result in
                    switch result {
                    case .success:
                        print("Done.")
                    case let .failure(error):
                        print("Failed.\n\(error)")
                    }
                }
            case let .failure(error):
                print("Failed.\n\(error)")
            }
        }
    }
}

extension ViewController: NotificareScannablesDelegate {
    func notificare(_: NotificareScannables, didDetectScannable scannable: NotificareScannable) {
        guard let notification = scannable.notification else {
            let alert = UIAlertController(
                title: "Error",
                message: "This scannable does not contain a notification.",
                preferredStyle: .alert
            )

            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default
                )
            )

            present(alert, animated: true)
            return
        }

        NotificarePushUI.shared.presentNotification(notification, in: navigationController!)
    }

    func notificare(_: NotificareScannables, didInvalidateScannerSession error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(alert, animated: true)
    }
}
