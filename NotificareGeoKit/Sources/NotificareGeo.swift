//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreLocation
import Foundation
import MapKit
import NotificareKit
import UIKit

private let MAX_MONITORED_REGIONS = 10
private let MAX_MONITORED_BEACONS = 10

public class NotificareGeo: NSObject, NotificareModule, CLLocationManagerDelegate {
    public static let shared = NotificareGeo()

    public weak var delegate: NotificareGeoDelegate?

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
            return

        case .restricted, .denied:
            handleLocationServicesUnauthorized()

        case .authorizedWhenInUse:
            handleLocationServicesAuthorized(monitorSignificantLocationChanges: false)

        case .authorizedAlways:
            handleLocationServicesAuthorized(monitorSignificantLocationChanges: true)

        @unknown default:
            NotificareLogger.warning("Unsupported authorization status: \(status)")
            return
        }

        NotificareLogger.info("Location updates enabled.")
    }

    public func disableLocationUpdates() {
        do {
            try checkPrerequisites()
            try checkPlistPrerequisites()
        } catch {
            return
        }

        // Keep track of the location services status.
        LocalStorage.locationServicesEnabled = false

        // Stop any location updates
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()

        if Notificare.shared.options?.visitsApiEnabled == true {
            NotificareLogger.debug("Stopped monitoring visits.")
            locationManager.stopMonitoringVisits()
        }

        if Notificare.shared.options?.headingApiEnabled == true {
            NotificareLogger.debug("Stopped updating heading.")
            locationManager.stopUpdatingHeading()
        }

        clearRegions()
        clearBeacons()

        // TODO: update device

        NotificareLogger.info("Location updates disabled.")
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

        if monitorSignificantLocationChanges, Notificare.shared.options?.visitsApiEnabled == true {
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
        var monitoredRegionsCache = LocalStorage.monitoredRegions

        let monitoredRegions = locationManager.monitoredRegions
            .filter { !($0 is CLBeaconRegion) }

        monitoredRegions
            .filter { clr in !regions.contains(where: { $0.id == clr.identifier }) }
            .forEach { clr in
                NotificareLogger.debug("Stopped monitoring region '\(clr.identifier)'.")
                locationManager.stopMonitoring(for: clr)

                // Make sure we process the region exit appropriately.
                // This should perform the exit trigger, stop the session
                // and stop monitoring for beacons in this region.
                handleRegionExit(clr)

                // Remove the region from the cache.
                monitoredRegionsCache.removeAll { $0.id == clr.identifier }
            }

        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            regions
                .filter { r in !monitoredRegions.contains(where: { $0.identifier == r.id }) }
                .forEach { r in
                    let clr = r.toCLRegion(with: locationManager)
                    clr.notifyOnEntry = true
                    clr.notifyOnExit = true

                    NotificareLogger.debug("Started monitoring region '\(r.name)'.")
                    locationManager.startMonitoring(for: clr)

                    // Add the region to the cache.
                    monitoredRegionsCache.append(r)
                }
        }

        // Persist the update cache to disk.
        LocalStorage.monitoredRegions = monitoredRegionsCache

        // Check the monitoring status.
        checkMonitoringStatus()
    }

    private func checkMonitoringStatus() {
        let monitoredRegions = locationManager.monitoredRegions
        NotificareLogger.debug("Location manager monitoring \(monitoredRegions.count) regions.")

        let monitoredRegionsCache = LocalStorage.monitoredRegions
        NotificareLogger.debug("Cached \(monitoredRegionsCache.count) regions for monitoring.")

        let monitoredBeaconsCache = LocalStorage.monitoredBeacons
        NotificareLogger.debug("Cached \(monitoredBeaconsCache.count) beacons for monitoring.")

        monitoredRegions.forEach { clr in
            // TODO: exclude fake beacon

            if clr is CLBeaconRegion {
                if let beacon = monitoredBeaconsCache.first(where: { $0.id == clr.identifier }) {
                    NotificareLogger.debug("Monitoring for beacon '\(beacon.name)'.")
                } else {
                    NotificareLogger.debug("Monitoring for non-cached beacon '\(clr.identifier)'.")
                }
            } else {
                if let region = monitoredRegionsCache.first(where: { $0.id == clr.identifier }) {
                    NotificareLogger.debug("Monitoring for region '\(region.name)'.")
                } else {
                    NotificareLogger.debug("Monitoring for non-cached region '\(clr.identifier)'.")
                }
            }

            // Check if we are inside this region.
            locationManager.requestState(for: clr)
        }
    }

    private func clearRegions() {
        // Remove the cached regions.
        LocalStorage.enteredRegions = []
        LocalStorage.monitoredRegions = []
        LocalStorage.regionSessions = []

        // Stop monitoring all regions.
        locationManager.monitoredRegions
            .filter { !($0 is CLBeaconRegion) }
            .forEach { locationManager.stopMonitoring(for: $0) }
    }

    private func clearBeacons() {
        // Remove the cached beacons.
        LocalStorage.enteredBeacons = []
        LocalStorage.monitoredBeacons = []
        LocalStorage.beaconSessions = []

        // Stop monitoring all beacons.
        locationManager.monitoredRegions
            .filter { $0 is CLBeaconRegion }
            .forEach { locationManager.stopMonitoring(for: $0) }
    }

    private func handleRegionEnter(_ clr: CLRegion) {
        if let clr = clr as? CLBeaconRegion {
            guard let beacon = LocalStorage.monitoredBeacons.first(where: { $0.id == clr.identifier }) else {
                NotificareLogger.warning("Received an enter event for non-cached beacon '\(clr.identifier)'.")
                return
            }

            // If the region contains both major and minor, then it's an actual beacon.
            if clr.major != nil, clr.minor != nil {
                // Make sure we're not inside the beacon.
                if !LocalStorage.enteredBeacons.contains(beacon.id) {
                    triggerBeaconEnter(beacon)
                }
            } else {
                // When there's no major or minor, this is the main beacon region.
                // We should start ranging for beacons in this region.

                guard CLLocationManager.isRangingAvailable() else {
                    return
                }

                if #available(iOS 13.0, *) {
                    locationManager.startRangingBeacons(satisfying: clr.beaconIdentityConstraint)
                } else {
                    locationManager.startRangingBeacons(in: clr)
                }

                // TODO: self.ranging = true
                startBeaconSession(beacon)
            }
        } else {
            guard let region = LocalStorage.monitoredRegions.first(where: { $0.id == clr.identifier }) else {
                NotificareLogger.warning("Received an enter event for non-cached region '\(clr.identifier)'.")
                return
            }

            if region.isPolygon, let polygon = MKPolygon(region: region) {
                // This region is a polygon. Proceed if we are inside the polygon boundaries.
                guard let location = locationManager.location, polygon.contains(location.coordinate) else {
                    NotificareLogger.debug("Triggered a region enter but we are not inside the polygon boundaries.")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        NotificareLogger.debug("Requesting state for polygon region.")
                        self.locationManager.requestState(for: clr)
                    }

                    NotificareLogger.debug("Requesting some background time.")
                    keepAlive()

                    return
                }
            }

            // Make sure we're not inside the region.
            if !LocalStorage.enteredRegions.contains(region.id) {
                triggerRegionEnter(region)
                startRegionSession(region)
            }

            // Start monitoring for beacons in this region.
            startMonitoringBeacons(in: region)
        }
    }

    private func handleRegionExit(_ clr: CLRegion) {
        if let clr = clr as? CLBeaconRegion {
            guard let beacon = LocalStorage.monitoredBeacons.first(where: { $0.id == clr.identifier }) else {
                NotificareLogger.warning("Received an exit event for non-cached beacon '\(clr.identifier)'.")
                return
            }

            // If the region contains both major and minor, then it's an actual beacon.
            if clr.major != nil, clr.minor != nil {
                // Make sure we're inside the beacon.
                if LocalStorage.enteredBeacons.contains(beacon.id) {
                    triggerBeaconExit(beacon)
                }
            } else {
                // When there's no major or minor, this is the main beacon region.
                // We should stop ranging for beacons in this region.

                guard CLLocationManager.isRangingAvailable() else {
                    return
                }

                if #available(iOS 13.0, *) {
                    locationManager.stopRangingBeacons(satisfying: clr.beaconIdentityConstraint)
                } else {
                    locationManager.stopRangingBeacons(in: clr)
                }

                // TODO: self.ranging = false
                stopBeaconSession(beacon)
            }
        } else {
            guard let region = LocalStorage.monitoredRegions.first(where: { $0.id == clr.identifier }) else {
                NotificareLogger.warning("Received an exit event for non-cached region '\(clr.identifier)'.")
                return
            }

            // Make sure we're inside the region.
            if LocalStorage.enteredRegions.contains(region.id) {
                triggerRegionExit(region)
                stopRegionSession(region)
            }

            // Stop monitoring for beacons in this region.
            stopMonitoringBeacons(in: region)
        }
    }

    private func triggerRegionEnter(_ region: NotificareRegion) {
        guard let device = Notificare.shared.deviceManager.currentDevice else {
            NotificareLogger.warning("Cannot process region enter trigger without a device.")
            return
        }

        let payload = NotificareInternals.PushAPI.Payloads.RegionTrigger(
            deviceID: device.id,
            region: region.id
        )

        NotificareRequest.Builder()
            .post("trigger/re.notifica.trigger.region.Enter", body: payload)
            .response { result in
                switch result {
                case .success:
                    LocalStorage.enteredRegions = LocalStorage.enteredRegions.appending(region.id)

                    NotificareLogger.debug("Triggered region enter.")
                case let .failure(error):
                    NotificareLogger.error("Failed to trigger a region enter.\n\(error)")
                }
            }
    }

    private func triggerRegionExit(_ region: NotificareRegion) {
        guard let device = Notificare.shared.deviceManager.currentDevice else {
            NotificareLogger.warning("Cannot process region exit trigger without a device.")
            return
        }

        let payload = NotificareInternals.PushAPI.Payloads.RegionTrigger(
            deviceID: device.id,
            region: region.id
        )

        NotificareRequest.Builder()
            .post("trigger/re.notifica.trigger.region.Exit", body: payload)
            .response { result in
                switch result {
                case .success:
                    LocalStorage.enteredRegions = LocalStorage.enteredRegions.removing(region.id)

                    NotificareLogger.debug("Triggered region exit.")
                case let .failure(error):
                    NotificareLogger.error("Failed to trigger a region exit.\n\(error)")
                }
            }
    }

    private func triggerBeaconEnter(_ beacon: NotificareBeacon) {
        guard let device = Notificare.shared.deviceManager.currentDevice else {
            NotificareLogger.warning("Cannot process beacon enter trigger without a device.")
            return
        }

        let payload = NotificareInternals.PushAPI.Payloads.BeaconTrigger(
            deviceID: device.id,
            beacon: beacon.id
        )

        NotificareRequest.Builder()
            .post("trigger/re.notifica.trigger.beacon.Enter", body: payload)
            .response { result in
                switch result {
                case .success:
                    LocalStorage.enteredBeacons = LocalStorage.enteredBeacons.appending(beacon.id)

                    NotificareLogger.debug("Triggered beacon enter.")
                case let .failure(error):
                    NotificareLogger.error("Failed to trigger a beacon enter.\n\(error)")
                }
            }
    }

    private func triggerBeaconExit(_ beacon: NotificareBeacon) {
        guard let device = Notificare.shared.deviceManager.currentDevice else {
            NotificareLogger.warning("Cannot process beacon exit trigger without a device.")
            return
        }

        let payload = NotificareInternals.PushAPI.Payloads.BeaconTrigger(
            deviceID: device.id,
            beacon: beacon.id
        )

        NotificareRequest.Builder()
            .post("trigger/re.notifica.trigger.beacon.Exit", body: payload)
            .response { result in
                switch result {
                case .success:
                    LocalStorage.enteredBeacons = LocalStorage.enteredBeacons.removing(beacon.id)

                    NotificareLogger.debug("Triggered beacon exit.")
                case let .failure(error):
                    NotificareLogger.error("Failed to trigger a beacon exit.\n\(error)")
                }
            }
    }

    private func startRegionSession(_ region: NotificareRegion) {
        NotificareLogger.debug("Starting session for region '\(region.name)'.")

        var sessions = LocalStorage.regionSessions

        guard !sessions.contains(where: { $0.regionId == region.id }) else {
            NotificareLogger.debug("Skipping region session start since it already exists for region '\(region.name)'.")
            return
        }

        let location = locationManager.location.flatMap { location in
            NotificareRegionSession.Location(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                altitude: location.altitude,
                course: location.course,
                speed: location.speed,
                horizontalAccuracy: location.horizontalAccuracy,
                verticalAccuracy: location.verticalAccuracy,
                timestamp: location.timestamp
            )
        }

        let session = NotificareRegionSession(
            regionId: region.id,
            start: Date(),
            end: nil,
            locations: location.map { [$0] } ?? []
        )

        sessions.append(session)
        LocalStorage.regionSessions = sessions
    }

    private func updateRegionSession(_ location: CLLocation) {
        NotificareLogger.debug("Updating region sessions.")

        LocalStorage.regionSessions = LocalStorage.regionSessions.map { session in
            guard let region = LocalStorage.monitoredRegions.first(where: { $0.id == session.regionId }),
                  let clr = region.toCLRegion(with: locationManager) as? CLCircularRegion,
                  clr.contains(location.coordinate)
            else {
                return session
            }

            NotificareLogger.debug("Updating region '\(region.name)' session.")

            var locations = session.locations
            locations.append(
                NotificareRegionSession.Location(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    altitude: location.altitude,
                    course: location.course,
                    speed: location.speed,
                    horizontalAccuracy: location.horizontalAccuracy,
                    verticalAccuracy: location.verticalAccuracy,
                    timestamp: location.timestamp
                )
            )

            return NotificareRegionSession(
                regionId: session.regionId,
                start: session.start,
                end: session.end,
                locations: locations
            )
        }
    }

    private func stopRegionSession(_ region: NotificareRegion) {
        NotificareLogger.debug("Stopping session for region '\(region.name)'.")

        var sessions = LocalStorage.regionSessions

        guard let session = sessions.first(where: { $0.regionId == region.id }) else {
            NotificareLogger.debug("Skipping region session end since no session exists for region '\(region.name)'.")
            return
        }

        Notificare.shared.eventsManager.logRegionSession(session) { result in
            switch result {
            case .success:
                NotificareLogger.debug("Region session logged.")

                sessions.removeAll(where: { $0.regionId == region.id })
                LocalStorage.regionSessions = sessions
            case let .failure(error):
                NotificareLogger.error("Failed to log the region session.\n\(error)")
            }
        }
    }

    private func startBeaconSession(_ beacon: NotificareBeacon) {
        guard let region = LocalStorage.monitoredRegions.first(where: { $0.id == beacon.id }) else {
            NotificareLogger.warning("Cannot start the session for beacon '\(beacon.name)' since the corresponding region is not being monitored.")
            return
        }

        NotificareLogger.debug("Starting session for beacon '\(beacon.name)'.")

        guard !LocalStorage.beaconSessions.contains(where: { $0.regionId == region.id }) else {
            NotificareLogger.debug("Skipping beacon session start since it already exists for region '\(region.name)'.")
            return
        }

        LocalStorage.beaconSessions = LocalStorage.beaconSessions.appending(
            NotificareBeaconSession(
                regionId: region.id,
                start: Date(),
                end: nil,
                beacons: []
            )
        )
    }

    private func updateBeaconSession(_ beacon: CLBeacon) {
        guard let region = LocalStorage.monitoredRegions.first(where: { $0.major == beacon.major.intValue }) else {
            NotificareLogger.warning("Cannot update the session for beacon (major: \(beacon.major), minor: '\(beacon.minor))' since the corresponding region is not being monitored.")
            return
        }

        LocalStorage.beaconSessions = LocalStorage.beaconSessions.map { session in
            guard session.regionId == region.id else {
                return session
            }

            NotificareLogger.debug("Updating beacon session for region '\(region.name)'.")

            return NotificareBeaconSession(
                regionId: session.regionId,
                start: session.start,
                end: session.end,
                beacons: session.beacons.appending(
                    NotificareBeaconSession.Beacon(
                        proximity: beacon.proximity.rawValue,
                        major: beacon.major.intValue,
                        minor: beacon.minor.intValue,
                        location: locationManager.location.flatMap { location in
                            NotificareBeaconSession.Beacon.Location(
                                latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude
                            )
                        },
                        timestamp: Date()
                    )
                )
            )
        }
    }

    private func stopBeaconSession(_ beacon: NotificareBeacon) {
        guard let region = LocalStorage.monitoredRegions.first(where: { $0.id == beacon.id }) else {
            NotificareLogger.warning("Cannot stop the session for beacon '\(beacon.name)' since the corresponding region is not being monitored.")
            return
        }

        guard let session = LocalStorage.beaconSessions.first(where: { $0.regionId == region.id }) else {
            NotificareLogger.debug("Skipping beacon session end since no session exists for region '\(region.name)'.")
            return
        }

        NotificareLogger.debug("Stopping session for beacon '\(beacon.name)'.")

        Notificare.shared.eventsManager.logBeaconSession(session) { result in
            switch result {
            case .success:
                NotificareLogger.debug("Beacon session logged.")

                // Remove the session from local storage.
                LocalStorage.beaconSessions = LocalStorage.beaconSessions.filter { $0.regionId != region.id }
            case let .failure(error):
                NotificareLogger.error("Failed to log the beacon session.\n\(error)")
            }
        }
    }

    private func startMonitoringBeacons(in region: NotificareRegion) {
        NotificareLogger.debug("Starting to monitor beacons in region '\(region.name)'.")

        guard let uuidStr = Notificare.shared.application?.regionConfig?.proximityUUID,
              let uuid = UUID(uuidString: uuidStr)
        else {
            NotificareLogger.warning("The Proximity UUID property has not been configured for this application.")
            return
        }

        guard let major = region.major else {
            NotificareLogger.debug("The region '\(region.name)' has not been assigned a major.")
            return
        }

        //
        // Monitor the whole region.
        //

        let mainBeacon = NotificareBeacon(
            id: region.id,
            name: region.name,
            major: major,
            minor: nil,
            triggers: false
        )

        startMonitoringBeacon(mainBeacon, with: uuid)
        LocalStorage.monitoredBeacons = LocalStorage.monitoredBeacons.appending(mainBeacon)

        NotificareLogger.debug("Started monitoring the region beacon major.")

        //
        // Monitor each beacon in the region.
        //

        NotificareRequest.Builder()
            .get("/beacon/forregion/\(region.id)")
            .responseDecodable(NotificareInternals.PushAPI.Responses.FetchBeacons.self) { result in
                switch result {
                case let .success(response):
                    let beacons = response.beacons
                        .prefix(MAX_MONITORED_BEACONS)
                        .map { $0.toModel() }

                    // Start monitoring every beacon.
                    beacons.forEach { self.startMonitoringBeacon($0, with: uuid) }

                    // Store the beacons in local storage.
                    LocalStorage.monitoredBeacons = LocalStorage.monitoredBeacons.appending(contentsOf: beacons)

                    NotificareLogger.debug("Started monitoring \(beacons.count) individual beacons.")
                case let .failure(error):
                    NotificareLogger.error("Failed to fetch beacons for region '\(region.name)'.\n\(error)")
                }
            }
    }

    private func startMonitoringBeacon(_ beacon: NotificareBeacon, with uuid: UUID) {
        guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else {
            NotificareLogger.warning("Beacon monitoring is not available.")
            return
        }

        let clr: CLBeaconRegion

        if #available(iOS 13.0, *) {
            if let minor = beacon.minor {
                clr = CLBeaconRegion(
                    beaconIdentityConstraint: CLBeaconIdentityConstraint(
                        uuid: uuid,
                        major: UInt16(beacon.major),
                        minor: UInt16(minor)
                    ),
                    identifier: beacon.id
                )
            } else {
                clr = CLBeaconRegion(
                    beaconIdentityConstraint: CLBeaconIdentityConstraint(
                        uuid: uuid,
                        major: UInt16(beacon.major)
                    ),
                    identifier: beacon.id
                )
            }
        } else {
            if let minor = beacon.minor {
                clr = CLBeaconRegion(
                    proximityUUID: uuid,
                    major: UInt16(beacon.major),
                    minor: UInt16(minor),
                    identifier: beacon.id
                )
            } else {
                clr = CLBeaconRegion(
                    proximityUUID: uuid,
                    major: UInt16(beacon.major),
                    identifier: beacon.id
                )
            }
        }

        clr.notifyEntryStateOnDisplay = true
        clr.notifyOnEntry = true
        clr.notifyOnExit = true

        locationManager.startMonitoring(for: clr)
    }

    private func stopMonitoringBeacons(in region: NotificareRegion) {}

    private func keepAlive() {
        guard UIApplication.shared.applicationState != .active else { return }

        NotificareLogger.debug("Requesting location in background.")
        locationManager.requestLocation()
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
                // Add this location to the region session.
                self.updateRegionSession(location)

                // Unlock location updates.
                self.processingLocationUpdate = false
            }
        }
    }

    public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .locationUnknown || error.code == .network {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.enableLocationUpdates()
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // TODO: check if this is the fake beacon

        // Check the state after 2 seconds to avoid colision with other requests.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            manager.requestState(for: region)
        }
    }

    public func locationManager(_: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError _: Error) {
        if let region = region {
            // Retry to monitor this region
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.locationManager.startMonitoring(for: region)
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // Ignore beacon regions.
        guard !(region is CLBeaconRegion) else { return }

        // Ignore polygons.
        guard let r = LocalStorage.monitoredRegions.first(where: { $0.id == region.identifier }), !r.isPolygon else {
            return
        }

        // Trigger a location update in order to update the loaded fences as a side effect.
        manager.requestLocation()
    }

    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // Ignore beacon regions.
        guard !(region is CLBeaconRegion) else { return }

        // Ignore polygons.
        guard let r = LocalStorage.monitoredRegions.first(where: { $0.id == region.identifier }), !r.isPolygon else {
            return
        }

        // Trigger a location update in order to update the loaded fences as a side effect.
        manager.requestLocation()
    }

    public func locationManager(_: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            handleRegionEnter(region)

        case .outside:
            handleRegionExit(region)

        case .unknown:
            break
        }
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
