//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import CoreLocation
import NotificareAssetsKit
import NotificareGeoKit
import NotificareInboxKit
import NotificareKit
import NotificareLoyaltyKit
import NotificareMonetizeKit
import NotificarePushKit
import NotificarePushUIKit
import NotificareScannablesKit
import UIKit

class ViewController: UIViewController {
    private var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        locationManager = CLLocationManager()
        locationManager.delegate = self

        Notificare.shared.scannables().delegate = self
    }

    @IBAction func onLaunchClicked(_: Any) {
        Notificare.shared.launch()
    }

    @IBAction func onUnlaunchClicked(_: Any) {
        Notificare.shared.unlaunch()
    }

    @IBAction private func onEnableRemoteNotificationsClick(_: Any) {
        Notificare.shared.push().enableRemoteNotifications { result in
            switch result {
            case let .success(granted):
                print("-----> User allowed notifications: \(granted)")
            case let .failure(error):
                print("-----> Something went wrong: \(error)")
            }
        }
    }

    @IBAction func onDisableRemoteNotificationsClick(_: Any) {
        Notificare.shared.push().disableRemoteNotifications()
    }

    @IBAction func onSendCustomEventClick(_: Any) {
        let data: NotificareEventData = [
            "color": "blue",
        ]

        Notificare.shared.events().logCustom("test", data: data) { _ in }
    }

    @IBAction func onRegisterWithUserClick(_: Any) {
        Notificare.shared.device().register(userId: "d09f8b8e-2c10-4ae9-82e5-44f1bf627d89", userName: "John Doe") { result in
            switch result {
            case .success:
                print("-----> Device registered with user.")
            case let .failure(error):
                print("-----> Failed to register device with user: \(error)")
            }
        }
    }

    @IBAction func onRegisterAnonymousClick(_: Any) {
        Notificare.shared.device().register(userId: nil, userName: nil) { result in
            switch result {
            case .success:
                print("-----> Device registered anonymously.")
            case let .failure(error):
                print("-----> Failed to register device anonymously: \(error)")
            }
        }
    }

    @IBAction func onFetchUserDataClick(_: Any) {
        Notificare.shared.device().fetchUserData { result in
            switch result {
            case let .success(userData):
                print("-----> User data = \(userData)")

            case let .failure(error):
                print("-----> Failed to fetch user data.\n\(error)")
            }
        }
    }

    // MARK: - Inbox

    @IBAction func onListInboxItemsClick(_: Any) {
        print("-----> Inbox items")
        print(Notificare.shared.inbox().items)
    }

    @IBAction func onRefreshBadgeClick(_: Any) {
        Notificare.shared.inbox().refreshBadge { result in
            switch result {
            case let .success(badge):
                print("-----> Badge: \(badge)")
            case let .failure(error):
                print("-----> Failed to refresh the badge: \(error)")
            }
        }
    }

    // MARK: - Geo

    @IBAction func onEnableLocationUpdatesClicked(_: Any) {
        let authorizationStatus = CLLocationManager.authorizationStatus()

        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            locationManager.requestWhenInUseAuthorization()

            return
        }

        guard authorizationStatus == .authorizedAlways else {
            locationManager.requestAlwaysAuthorization()

            return
        }

        Notificare.shared.geo().enableLocationUpdates()
    }

    @IBAction func onDisableLocationUpdatesClicked(_: Any) {
        Notificare.shared.geo().disableLocationUpdates()
    }

    // MARK: - Assets

    @IBAction func onFetchAssetsClick(_: Any) {
        Notificare.shared.assets().fetch(group: "LANDSCAPES") { result in
            switch result {
            case let .success(assets):
                print("Assets = \(assets)")
            case let .failure(error):
                print("Failed to fetch assets.\n\(error)")
            }
        }
    }

    // MARK: - Scannables

    @IBAction func onStartScannableSessionClick(_: Any) {
        if Notificare.shared.scannables().canStartNfcScannableSession {
            Notificare.shared.scannables().startNfcScannableSession()
        } else {
            Notificare.shared.scannables().startQrCodeScannableSession(controller: navigationController!, modal: true)
        }
    }

    // MARK: - Loyalty

    @IBAction func onFetchPassClick(_: Any) {
        Notificare.shared.loyalty().fetchPass(serial: "2e5cdf49-83f8-4029-b5bb-dc478ff309b9") { result in
            switch result {
            case let .success(pass):
                print("Pass = \(pass)")
                Notificare.shared.loyalty().present(pass: pass, in: self)
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

    @IBAction func onRefreshClicked(_: Any) {
        Notificare.shared.monetize().refresh { result in
            switch result {
            case .success:
                print("Done.")
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

        Notificare.shared.pushUI().presentNotification(notification, in: navigationController!)
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

extension ViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_: CLLocationManager) {
        handleLocationAuthorizationChanges()
    }

    func locationManager(_: CLLocationManager, didChangeAuthorization _: CLAuthorizationStatus) {
        handleLocationAuthorizationChanges()
    }

    private func handleLocationAuthorizationChanges() {
        let status = CLLocationManager.authorizationStatus()

        switch status {
        case .notDetermined:
            print("---> Authorization status = not determined")
        case .restricted:
            print("---> Authorization status = restricted")
        case .denied:
            print("---> Authorization status = denied")
        case .authorizedWhenInUse:
            print("---> Authorization status = when in use")
        case .authorizedAlways:
            print("---> Authorization status = always")
        default:
            print("---> Unhandled authorization status: \(status.rawValue)")
        }

        Notificare.shared.geo().enableLocationUpdates()
    }
}
