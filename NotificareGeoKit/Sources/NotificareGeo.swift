//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreLocation
import Foundation
import NotificareKit
import UIKit

private let MAX_MONITORED_REGIONS = 10

public class NotificareGeo: NSObject, NotificareModule, CLLocationManagerDelegate {
    public static let shared = NotificareGeo()

    private var locationManager: CLLocationManager!
    private var processingLocationUpdate = false

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

        // Listen to application did become active events.
        NotificationCenter.default.addObserver(NotificareGeo.shared,
                                               selector: #selector(onApplicationDidBecomeActiveNotification(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        // Listen to application will resign active events.
        NotificationCenter.default.addObserver(NotificareGeo.shared,
                                               selector: #selector(onApplicationWillResignActiveNotification(_:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }

    public static func launch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    public static func unlaunch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    // MARK: - Public API

    public var locationServicesEnabled: Bool {
        LocalStorage.locationServicesEnabled && CLLocationManager.locationServicesEnabled()
    }

    public func enableLocationUpdates() {
        do {
            try checkPrerequisites()
            try checkPlistPrerequisites()
        } catch {
            return
        }

        // Keep track of the location services status.
        LocalStorage.locationServicesEnabled = true

        let status = CLLocationManager.authorizationStatus()

        switch status {
        case .notDetermined:
            NotificareLogger.warning("Location permission not determined. You must request permissions before enabling location updates.")

        case .restricted, .denied:
            handleLocationServicesUnauthorized()

        case .authorizedWhenInUse:
            handleLocationServicesAuthorized(monitorSignificantLocationChanges: false)

        case .authorizedAlways:
            handleLocationServicesAuthorized(monitorSignificantLocationChanges: true)

        @unknown default:
            NotificareLogger.warning("Unsupported authorization status: \(status)")
        }
    }

    public func disableLocationUpdates() {
        do {
            try checkPrerequisites()
            try checkPlistPrerequisites()
        } catch {
            return
        }

        // Keep track of the location services status.
        LocalStorage.locationServicesEnabled = true

        //
    }

    // MARK: - Private API

    private func checkPrerequisites() throws {
        if !Notificare.shared.isReady {
            NotificareLogger.warning("Notificare is not ready yet.")
            throw NotificareError.notReady
        }

        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application is not yet available.")
            throw NotificareError.applicationUnavailable
        }

        guard application.services["locationServices"] == true else {
            NotificareLogger.warning("Notificare location functionality is not enabled.")
            throw NotificareError.serviceUnavailable(module: "locationServices")
        }
    }

    private func checkPlistPrerequisites() throws {
        guard
            Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") != nil,
            Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") != nil,
            Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil
        else {
            NotificareLogger.warning("/==================================================================================/")
            NotificareLogger.warning("We've detected that you did not add mandatory Info.plist entries for location services.")
            NotificareLogger.warning("Please add a text explaning why you need location updates in \"NSLocationAlwaysAndWhenInUseUsageDescription\", \"NSLocationAlwaysUsageDescription\" and \"NSLocationWhenInUseUsageDescription\" entries of your app's Info.plist before proceeding.")
            NotificareLogger.warning("/==================================================================================/")

            throw NotificareGeoError.missingPlistEntries
        }
    }

    private func handleLocationServicesUnauthorized() {
        // TODO: handleLocationServicesUnauthorized()

        // NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        // [settings setObject:@"none" forKey:kNotificareLocationServicesAuthStatus];
        // [settings setBool:NO forKey:kNotificareAllowedLocationServices];
        // if ( [settings synchronize] ) {
        //     [[[NotificareDeviceManager shared] device] setAllowedLocationServices:NO];
        //     [[[NotificareDeviceManager shared] device] setLocationServicesAuthStatus:@"none"];
        //     //No authorization or restricted, let's save this in the device
        //     [[NotificareDeviceManager shared] clearDeviceLocation:^(NotificareDevice * _Nonnull response) {
        //         [[NotificareLogging shared] nLog:@"Notificare: Device Location cleared"];
        //     } errorHandler:^(NSError * _Nonnull response) {
        //         [[NotificareLogging shared] nLog:@"Notificare: Failed to clear Device Location"];
        //     }];
        // }
    }

    private func handleLocationServicesAuthorized(monitorSignificantLocationChanges: Bool) {
        NotificareLogger.debug("Requesting user location. This might take a while. Please wait...")
        locationManager.requestLocation()

        if monitorSignificantLocationChanges, CLLocationManager.significantLocationChangeMonitoringAvailable() {
            NotificareLogger.debug("Started monitoring significant location changes.")
            locationManager.startMonitoringSignificantLocationChanges()
        }

        if monitorSignificantLocationChanges, Notificare.shared.options?.visitsApiEnabled == true, CLLocationManager.headingAvailable() {
            NotificareLogger.debug("Started monitoring visits.")
            locationManager.startMonitoringVisits()
        }

        if Notificare.shared.options?.headingApiEnabled == true, CLLocationManager.headingAvailable() {
            NotificareLogger.debug("Started updating heading.")
            locationManager.startUpdatingHeading()
        }

        // TODO: checkBluetoothEnabled()
    }

    private func saveLocation(_ location: CLLocation, _ completion: @escaping () -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                NotificareLogger.warning("Failed to reverse geocode location.\n\(error)")
                completion()
                return
            }

            guard let placemark = placemarks?.first,
                  let device = Notificare.shared.deviceManager.currentDevice
            else {
                completion()
                return
            }

            let payload = NotificareInternals.PushAPI.Payloads.UpdateDeviceLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                altitude: location.altitude,
                locationAccuracy: location.horizontalAccuracy >= 0 ? location.horizontalAccuracy : nil,
                speed: location.speed >= 0 ? location.speed : nil,
                course: location.course >= 0 ? location.course : nil,
                country: placemark.isoCountryCode,
                floor: location.floor?.level,
                locationServicesAuthStatus: self.authorizationMode,
                locationServicesAccuracyAuth: self.accuracyMode
            )

            NotificareRequest.Builder()
                .put("/device/\(device.id)", body: payload)
                .response { result in
                    switch result {
                    case .success:
                        NotificareLogger.info("Updated location to \(placemark.name ?? "---").")
                    case let .failure(error):
                        NotificareLogger.error("Failed to save location to \(placemark.name ?? "---").\n\(error)")
                    }

                    completion()
                }
        }
    }

    private func loadNearestRegions(_ location: CLLocation, _ completion: @escaping () -> Void) {
        NotificareRequest.Builder()
            .get("region/bylocation/\(location.coordinate.latitude)/\(location.coordinate.longitude)")
            .responseDecodable(NotificareInternals.PushAPI.Responses.FetchRegions.self) { result in
                switch result {
                case let .success(response):
                    let regions = response.regions
                        .prefix(MAX_MONITORED_REGIONS)
                        .map { $0.toModel() }

                    self.monitorRegions(regions)
                case let .failure(error):
                    NotificareLogger.error("Failed to load nearest regions.\n\(error)")
                }

                completion()
            }
    }

    private func monitorRegions(_ regions: [NotificareRegion]) {
        locationManager.monitoredRegions.forEach { monitoredRegion in
            NotificareLogger.info("Monitored region = \(monitoredRegion.identifier)")

            if !regions.contains(where: { $0.id == monitoredRegion.identifier }) {
                NotificareLogger.info("Stopped monitoring region '\(monitoredRegion.identifier)'.")
                locationManager.stopMonitoring(for: monitoredRegion)
            }
        }

        regions.forEach { region in
            if !locationManager.monitoredRegions.contains(where: { $0.identifier == region.id }) {
                NotificareLogger.info("Started monitoring region '\(region.name)'.")
                locationManager.startMonitoring(for: region.toCLRegion(with: locationManager))
            }
        }
    }

    // MARK: - NotificationCenter events

    @objc private func onApplicationDidBecomeActiveNotification(_: Notification) {
        guard locationServicesEnabled else { return }

        do {
            try checkPrerequisites()
            try checkPlistPrerequisites()
        } catch {
            return
        }

        // Request user location when we're only authorized while in use
        // or when the background updates are not available.
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            UIApplication.shared.backgroundRefreshStatus == .denied ||
            UIApplication.shared.backgroundRefreshStatus == .restricted ||
            !CLLocationManager.significantLocationChangeMonitoringAvailable()
        {
            NotificareLogger.debug("Requesting user location. This might take a while. Please wait...")
            locationManager.requestLocation()
        }

        if Notificare.shared.options?.headingApiEnabled == true && CLLocationManager.headingAvailable() {
            NotificareLogger.debug("Started updating heading.")
            locationManager.startUpdatingHeading()
        }

        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            // TODO: checkBluetoothEnabled()
        }
    }

    @objc private func onApplicationWillResignActiveNotification(_: Notification) {
        guard locationServicesEnabled else { return }

        do {
            try checkPrerequisites()
            try checkPlistPrerequisites()
        } catch {
            return
        }

        if Notificare.shared.options?.headingApiEnabled == true, CLLocationManager.headingAvailable() {
            NotificareLogger.debug("Stopped updating heading.")
            locationManager.stopUpdatingHeading()
        }
    }

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
        guard !processingLocationUpdate, let location = locations.last else {
            return
        }

        NotificareLogger.info("Received a location update. Processing...")
        processingLocationUpdate = true

        saveLocation(location) {
            if #available(iOS 14.0, *) {
                // Do not monitor regions unless we have full accuracy and always auth.
                guard manager.accuracyAuthorization == .fullAccuracy, manager.authorizationStatus == .authorizedAlways else {
                    // Unlock location updates.
                    self.processingLocationUpdate = false

                    return
                }
            }

            // Load the nearest regions.
            self.loadNearestRegions(location) {
                // Unlock location updates.
                self.processingLocationUpdate = false
            }

            // Add this location to the region session.
            // [self updateRegionSessionLocations:location];
        }
    }

    public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .locationUnknown || error.code == .network {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.enableLocationUpdates()
            }
        }
    }

    public func locationManager(_: CLLocationManager, didEnterRegion region: CLRegion) {
        NotificareLogger.info("--> Region enter = \(region.identifier)")

        let content = UNMutableNotificationContent()
        content.title = "Region enter"
        content.body = region.identifier
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: region.identifier,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        UNUserNotificationCenter.current().add(request) { _ in }
    }

    public func locationManager(_: CLLocationManager, didExitRegion region: CLRegion) {
        NotificareLogger.info("--> Region exit = \(region.identifier)")

        let content = UNMutableNotificationContent()
        content.title = "Region exit"
        content.body = region.identifier
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: region.identifier,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        UNUserNotificationCenter.current().add(request) { _ in }
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

public enum NotificareGeoError: Error {
    case missingPlistEntries
}
