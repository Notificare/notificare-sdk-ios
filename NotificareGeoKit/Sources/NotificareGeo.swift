//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreLocation
import Foundation
import NotificareKit
import UIKit

public class NotificareGeo: NSObject, NotificareModule, CLLocationManagerDelegate {
    public static let shared = NotificareGeo()

    private var locationManager: CLLocationManager!

    private var hasReducedAccuracy: Bool {
        if #available(iOS 14.0, *) {
            return locationManager.accuracyAuthorization == .reducedAccuracy
        }

        return false
    }

    private var authorizationMode: AuthorizationMode {
        let status = CLLocationManager.authorizationStatus()

        switch status {
        case .authorizedAlways:
            return .always
        case .authorizedWhenInUse:
            return .use
        default:
            return .none
        }
    }

    private var accuracyMode: AccuracyMode {
        hasReducedAccuracy ? .reduced : .full
    }

    // MARK: - Notificare Module

    public static func migrate() {}

    public static func configure() {
        NotificareGeo.shared.locationManager = CLLocationManager()
        NotificareGeo.shared.locationManager?.delegate = NotificareGeo.shared
        NotificareGeo.shared.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        if let backgroundModes = Bundle.main.infoDictionary?["UIBackgroundModes"] as? [String], backgroundModes.contains("location") {
            NotificareLogger.debug("Using Background Location Updates background mode.")
            NotificareGeo.shared.locationManager.allowsBackgroundLocationUpdates = true
        }
    }

    public static func launch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    public static func unlaunch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    // MARK: - Public API

    public var locationServicesEnabled: Bool {
        false
    }

    public func enableLocationUpdates() {}

    public func disableLocationUpdates() {}

    // MARK: - Private API

    private func checkPrerequisites() throws {}

    private func checkPlistPrerequisites() throws {}

    private func handleLocationServicesUnauthorized() {}

    private func handleLocationServicesAuthorized(monitorSignificantLocationChanges _: Bool) {}

    // MARK: - NotificationCenter events

    @objc private func onApplicationDidBecomeActiveNotification(_: Notification) {}

    @objc private func onApplicationWillResignActiveNotification(_: Notification) {}

    // MARK: - CLLocationManagerDelegate

    // In iOS 14 this delegate is called whenever there's changes to auth or accuracy states
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        _ = manager
    }

    // Prior to iOS 14, this delegate gets called instead
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        _ = manager
        _ = status
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _ = manager
        _ = locations
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        _ = manager
        _ = error
    }

    // MARK: - Internals

    internal enum AuthorizationMode: String, Codable {
        case none
        case use
        case always
    }

    internal enum AccuracyMode: String, Codable {
        case reduced
        case full
    }
}

public enum NotificareGeoError: Error {}
