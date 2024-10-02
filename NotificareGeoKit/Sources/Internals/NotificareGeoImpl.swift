//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreLocation
import Foundation
import MapKit
import NotificareKit
import UIKit

private let DEFAULT_MONITORED_REGIONS_LIMIT = 10
private let MAX_MONITORED_REGIONS_LIMIT = 20
private let MAX_MONITORED_BEACONS_LIMIT = 10
private let FAKE_BEACON_IDENTIFIER = "NotificareFakeBeacon"
private let SMALLEST_DISPLACEMENT_METERS = 100.0
private let MAX_REGION_SESSION_LOCATIONS = 100

internal class NotificareGeoImpl: NSObject, NotificareModule, NotificareGeo, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager!
    private var lastKnownLocation: CLLocation?
    private var processingLocationUpdate = false
    private let fakeBeaconUUID = UUID()

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

    private var monitoredRegionsLimit: Int {
        guard let options = Notificare.shared.options else {
            logger.warning("Notificare is not configured. Using the default limit for geofences.")
            return DEFAULT_MONITORED_REGIONS_LIMIT
        }

        guard let limit = options.monitoredRegionsLimit else {
            return DEFAULT_MONITORED_REGIONS_LIMIT
        }

        guard limit > 0 else {
            logger.warning("The monitored regions limit needs to be a positive number. Using the default limit for geofences.")
            return DEFAULT_MONITORED_REGIONS_LIMIT
        }

        guard limit <= MAX_MONITORED_REGIONS_LIMIT else {
            logger.warning("The monitored regions limit cannot exceed the OS limit of \(MAX_MONITORED_REGIONS_LIMIT). Using the OS limit for geofences.")
            return MAX_MONITORED_REGIONS_LIMIT
        }

        return limit
    }

    private var monitoredBeaconsLimit: Int {
        // The fixed -1 is to reserve for the fake beacon (bluetooth check).
        max(0, MAX_MONITORED_REGIONS_LIMIT - monitoredRegionsLimit - 1)
    }

    // MARK: - Notificare Module

    internal static let instance = NotificareGeoImpl()

    internal func migrate() {
        LocalStorage.locationServicesEnabled = UserDefaults.standard.bool(forKey: "notificareAllowedLocationServices")
        LocalStorage.bluetoothEnabled = UserDefaults.standard.bool(forKey: "notificareBluetoothON")
    }

    internal func configure() {
        logger.hasDebugLoggingEnabled = Notificare.shared.options?.debugLoggingEnabled ?? false

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        if let backgroundModes = Bundle.main.infoDictionary?["UIBackgroundModes"] as? [String], backgroundModes.contains("location") {
            logger.debug("Using Background Location Updates background mode.")
            locationManager.allowsBackgroundLocationUpdates = true
        }

        // Listen to application did become active events.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationDidBecomeActiveNotification(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        // Listen to application will resign active events.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationWillResignActiveNotification(_:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }

    internal func clearStorage() async throws {
        stopMonitoringLocationUpdates()
        stopMonitoringGeofences()

        LocalStorage.clear()
    }

    internal func postLaunch() async throws {
        if hasLocationServicesEnabled {
            logger.debug("Enabling locations updates automatically.")
            enableLocationUpdates()
        }
    }

    internal func unlaunch() async throws {
        LocalStorage.locationServicesEnabled = false

        stopMonitoringGeofences()
        stopMonitoringLocationUpdates()

        try await clearDeviceLocation()
    }

    // MARK: - Notificare Geo

    public weak var delegate: NotificareGeoDelegate?

    public private(set) var hasBluetoothEnabled: Bool {
        get { LocalStorage.bluetoothEnabled && LocalStorage.locationServicesEnabled }
        set { LocalStorage.bluetoothEnabled = newValue }
    }

    public var hasLocationServicesEnabled: Bool {
        LocalStorage.locationServicesEnabled
    }

    public var monitoredRegions: [NotificareRegion] {
        LocalStorage.monitoredRegions
    }

    public var enteredRegions: [NotificareRegion] {
        let monitoredRegions = LocalStorage.monitoredRegions

        return LocalStorage.enteredRegions.compactMap { id in
            monitoredRegions.first { region in
                region.id == id
            }
        }
    }

    public func enableLocationUpdates() {
        do {
            try checkPrerequisites()
            try checkPlistPrerequisites()
        } catch {
            return
        }

        hasLocationServicesEnabled { enabled in
            guard enabled else {
                logger.warning("Location functionality is disabled by the user.")
                return
            }

            // Keep track of the location services status.
            LocalStorage.locationServicesEnabled = true

            let status = CLLocationManager.authorizationStatus()

            switch status {
            case .notDetermined:
                logger.warning("Location permission not determined. You must request permissions before enabling location updates.")
                return

            case .restricted, .denied:
                self.handleLocationServicesUnauthorized()

            case .authorizedWhenInUse:
                self.handleLocationServicesAuthorized(monitorSignificantLocationChanges: false)

            case .authorizedAlways:
                self.handleLocationServicesAuthorized(monitorSignificantLocationChanges: true)

            @unknown default:
                logger.warning("Unsupported authorization status: \(status)")
                return
            }

            logger.info("Location updates enabled.")
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
        LocalStorage.locationServicesEnabled = false

        handleLocationServicesUnauthorized()

        logger.info("Location updates disabled.")
    }

    // MARK: - Private API

    private func checkPrerequisites() throws {
        if !Notificare.shared.isReady {
            logger.warning("Notificare is not ready yet.")
            throw NotificareError.notReady
        }

        guard let application = Notificare.shared.application else {
            logger.warning("Notificare application is not yet available.")
            throw NotificareError.applicationUnavailable
        }

        guard application.services[NotificareApplication.ServiceKey.locationServices.rawValue] == true else {
            logger.warning("Notificare location functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.locationServices.rawValue)
        }
    }

    private func checkPlistPrerequisites() throws {
        guard
            Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") != nil,
            Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil
        else {
            logger.warning("/==================================================================================/")
            logger.warning("We've detected that you did not add mandatory Info.plist entries for location services.")
            logger.warning("Please add a text explaining why you need location updates in \"NSLocationAlwaysAndWhenInUseUsageDescription\" and \"NSLocationWhenInUseUsageDescription\" entries of your app's Info.plist before proceeding.")
            logger.warning("/==================================================================================/")

            throw NotificareGeoError.permissionEntriesMissing
        }
    }

    private func hasLocationServicesEnabled(_ completion: @escaping (_ enabled: Bool) -> Void) {
        DispatchQueue.global().async {
            let enabled = CLLocationManager.locationServicesEnabled()
            DispatchQueue.main.async {
                completion(enabled)
            }
        }
    }

    private func handleLocationServicesUnauthorized() {
        stopMonitoringGeofences()
        stopMonitoringLocationUpdates()

        Task {
            try? await clearDeviceLocation()
        }
    }

    private func handleLocationServicesAuthorized(monitorSignificantLocationChanges: Bool) {
        logger.debug("Requesting user location. This might take a while. Please wait...")
        locationManager.requestLocation()

        if monitorSignificantLocationChanges, CLLocationManager.significantLocationChangeMonitoringAvailable() {
            logger.debug("Started monitoring significant location changes.")
            locationManager.startMonitoringSignificantLocationChanges()
        }

        if monitorSignificantLocationChanges, Notificare.shared.options?.visitsApiEnabled == true {
            logger.debug("Started monitoring visits.")
            locationManager.startMonitoringVisits()
        }

        if Notificare.shared.options?.headingApiEnabled == true, CLLocationManager.headingAvailable() {
            logger.debug("Started updating heading.")
            locationManager.startUpdatingHeading()
        }

        checkBluetoothEnabled()
    }

    private func handleLocationUpdate(_ location: CLLocation) {
        guard shouldUpdateLocation(location) else {
            logger.debug("Received a location update. Skipping due to smallest displacement constraints...")
            return
        }

        guard !processingLocationUpdate else {
            logger.debug("Received a location update. Skipping due to concurrent location update...")
            return
        }

        logger.info("Received a location update. Processing...")
        processingLocationUpdate = true

        // Keep a reference to the last known location.
        lastKnownLocation = location

        // Add this location to the region session.
        updateRegionSession(location)

        Task {
            await saveLocation(location)

            if #available(iOS 14.0, *) {
                // Do not monitor regions unless we have full accuracy and always auth.
                guard self.locationManager.accuracyAuthorization == .fullAccuracy, self.locationManager.authorizationStatus == .authorizedAlways else {
                    // Unlock location updates.
                    self.processingLocationUpdate = false

                    return
                }
            }

            // Load the nearest regions.
            await loadNearestRegions(location)

            // Unlock location updates.
            self.processingLocationUpdate = false
        }
    }

    private func handlePolygonSessions(for location: CLLocation) {
        for region in LocalStorage.monitoredRegions.filter({ $0.isPolygon }) {
            let hasEntered = LocalStorage.enteredRegions.contains(region.id)
            let isInside = region.contains(location.coordinate)

            if !hasEntered && isInside {
                triggerRegionEnter(region)
                startRegionSession(region)
                startMonitoringBeacons(in: region)

                DispatchQueue.main.async {
                    self.delegate?.notificare(self, didEnter: region)
                }
            } else if hasEntered && !isInside {
                triggerRegionExit(region)
                stopRegionSession(region)
                stopMonitoringBeacons(in: region)

                DispatchQueue.main.async {
                    self.delegate?.notificare(self, didExit: region)
                }
            }
        }
    }

    private func shouldUpdateLocation(_ location: CLLocation) -> Bool {
        guard let lastKnownLocation else { return true }

        if lastKnownLocation.distance(from: location) >= SMALLEST_DISPLACEMENT_METERS {
            return true
        }

        // Update the location when we can monitor geofences but no fences were loaded yet.
        // This typically happens when tracking the user's location and later upgrading to background permission.
        if #available(iOS 14.0, *) {
            if locationManager.authorizationStatus == .authorizedAlways, locationManager.accuracyAuthorization == .fullAccuracy, LocalStorage.monitoredRegions.isEmpty {
                return true
            }
        }

        return false
    }

    private func saveLocation(_ location: CLLocation) async {
        let placemarks: [CLPlacemark]

        do {
            let geocoder = CLGeocoder()
            placemarks = try await geocoder.reverseGeocodeLocation(location)
        } catch {
            logger.warning("Failed to reverse geocode location.", error: error)
            return
        }

        guard let placemark = placemarks.first,
                let device = Notificare.shared.device().currentDevice
        else {
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

        do {
            try await NotificareRequest.Builder()
                .put("/push/\(device.id)", body: payload)
                .response()

            logger.info("Updated location to '\(placemark.name ?? "unknown")'.")
        } catch {
            logger.error("Failed to save location to '\(placemark.name ?? "unknown")'.", error: error)
        }
    }

    private func loadNearestRegions(_ location: CLLocation) async {
        do {
            let response = try await NotificareRequest.Builder()
                .get("region/bylocation/\(location.coordinate.latitude)/\(location.coordinate.longitude)")
                .query(name: "limit", value: String(monitoredRegionsLimit))
                .responseDecodable(NotificareInternals.PushAPI.Responses.FetchRegions.self)

            let regions = response.regions
                .map { $0.toModel() }

            monitorRegions(regions)
        } catch {
            logger.error("Failed to load nearest regions.", error: error)
        }
    }

    private func monitorRegions(_ regions: [NotificareRegion]) {
        var monitoredRegionsCache = LocalStorage.monitoredRegions

        let monitoredRegions = locationManager.monitoredRegions
            .filter { !($0 is CLBeaconRegion) }

        monitoredRegions
            .filter { clr in !regions.contains(where: { $0.id == clr.identifier }) }
            .forEach { clr in
                logger.debug("Stopped monitoring region '\(clr.identifier)'.")
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

                    logger.debug("Started monitoring region '\(r.name)'.")
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
        logger.debug("Location manager monitoring \(monitoredRegions.count) regions.")

        let monitoredRegionsCache = LocalStorage.monitoredRegions
        logger.debug("Cached \(monitoredRegionsCache.count) regions for monitoring.")

        let monitoredBeaconsCache = LocalStorage.monitoredBeacons
        logger.debug("Cached \(monitoredBeaconsCache.count) beacons for monitoring.")

        monitoredRegions.forEach { clr in
            // Ignore the fake beacon region.
            guard clr.identifier != FAKE_BEACON_IDENTIFIER else { return }

            if clr is CLBeaconRegion {
                if let beacon = monitoredBeaconsCache.first(where: { $0.id == clr.identifier }) {
                    logger.debug("Monitoring for beacon '\(beacon.name)'.")
                } else {
                    logger.debug("Monitoring for non-cached beacon '\(clr.identifier)'.")
                }
            } else {
                if let region = monitoredRegionsCache.first(where: { $0.id == clr.identifier }) {
                    logger.debug("Monitoring for region '\(region.name)'.")
                } else {
                    logger.debug("Monitoring for non-cached region '\(clr.identifier)'.")
                }
            }

            // Check if we are inside this region.
            locationManager.requestState(for: clr)
        }
    }

    private func stopMonitoringLocationUpdates() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()

        if Notificare.shared.options?.visitsApiEnabled == true {
            logger.debug("Stopped monitoring visits.")
            locationManager.stopMonitoringVisits()
        }

        if Notificare.shared.options?.headingApiEnabled == true {
            logger.debug("Stopped updating heading.")
            locationManager.stopUpdatingHeading()
        }
    }

    private func stopMonitoringGeofences() {
        clearRegions()
        clearBeacons()
    }

    private func clearDeviceLocation() async throws {
        guard let device = Notificare.shared.device().currentDevice else {
            logger.warning("Cannot update location authorization state without a device.")
            throw NotificareError.deviceUnavailable
        }

        let payload = NotificareInternals.PushAPI.Payloads.UpdateDeviceLocation(
            latitude: nil,
            longitude: nil,
            altitude: nil,
            locationAccuracy: nil,
            speed: nil,
            course: nil,
            country: nil,
            floor: nil,
            locationServicesAuthStatus: nil,
            locationServicesAccuracyAuth: nil
        )

        do {
            try await NotificareRequest.Builder()
                .put("/push/\(device.id)", body: payload)
                .response()

            logger.debug("Device location cleared.")
        } catch {
            logger.error("Failed to clear the device location.", error: error)
            throw error
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
                logger.warning("Received an enter event for non-cached beacon '\(clr.identifier)'.")
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
                logger.warning("Received an enter event for non-cached region '\(clr.identifier)'.")
                return
            }

            if region.isPolygon {
                // This region is a polygon. Proceed if we are inside the polygon boundaries.
                guard let location = locationManager.location, region.contains(location.coordinate) else {
                    logger.debug("Triggered a region enter but we are not inside the polygon boundaries.")
                    locationManager.requestLocation()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        logger.debug("Requesting state for polygon region.")
                        self.locationManager.requestState(for: clr)
                    }

                    return
                }
            }

            // Make sure we're not inside the region.
            if !LocalStorage.enteredRegions.contains(region.id) {
                triggerRegionEnter(region)
                startRegionSession(region)

                // Circular regions emit the didEnterRegion in the corresponding CLLocationManagerDelegate event.
                if region.isPolygon {
                    DispatchQueue.main.async {
                        self.delegate?.notificare(self, didEnter: region)
                    }
                }
            }

            if region.isPolygon, let location = locationManager.location, region.contains(location.coordinate) {
                // Start monitoring for beacons in this region.
                startMonitoringBeacons(in: region)
            } else if !region.isPolygon {
                // Start monitoring for beacons in this region.
                startMonitoringBeacons(in: region)
            }
        }
    }

    private func handleRegionExit(_ clr: CLRegion) {
        if let clr = clr as? CLBeaconRegion {
            guard let beacon = LocalStorage.monitoredBeacons.first(where: { $0.id == clr.identifier }) else {
                logger.warning("Received an exit event for non-cached beacon '\(clr.identifier)'.")
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
                logger.warning("Received an exit event for non-cached region '\(clr.identifier)'.")
                return
            }

            // Make sure we're inside the region.
            if LocalStorage.enteredRegions.contains(region.id) {
                triggerRegionExit(region)
                stopRegionSession(region)

                // Circular regions emit the didExitRegion in the corresponding CLLocationManagerDelegate event.
                if region.isPolygon {
                    DispatchQueue.main.async {
                        self.delegate?.notificare(self, didExit: region)
                    }
                }
            }

            // Stop monitoring for beacons in this region.
            stopMonitoringBeacons(in: region)
        }
    }

    private func triggerRegionEnter(_ region: NotificareRegion) {
        guard let device = Notificare.shared.device().currentDevice else {
            logger.warning("Cannot process region enter trigger without a device.")
            return
        }

        LocalStorage.enteredRegions = LocalStorage.enteredRegions.appending(region.id)

        let payload = NotificareInternals.PushAPI.Payloads.RegionTrigger(
            deviceID: device.id,
            region: region.id
        )

        Task {
            do {
                try await NotificareRequest.Builder()
                    .post("trigger/re.notifica.trigger.region.Enter", body: payload)
                    .response()

                logger.debug("Triggered region enter.")

            } catch {
                logger.error("Failed to trigger a region enter.", error: error)

            }
        }
    }

    private func triggerRegionExit(_ region: NotificareRegion) {
        guard let device = Notificare.shared.device().currentDevice else {
            logger.warning("Cannot process region exit trigger without a device.")
            return
        }

        LocalStorage.enteredRegions = LocalStorage.enteredRegions.removing(region.id)

        let payload = NotificareInternals.PushAPI.Payloads.RegionTrigger(
            deviceID: device.id,
            region: region.id
        )

        Task {
            do {
                try await NotificareRequest.Builder()
                    .post("trigger/re.notifica.trigger.region.Exit", body: payload)
                    .response()

                logger.debug("Triggered region exit.")
            } catch {
                logger.error("Failed to trigger a region exit.", error: error)
            }
        }
    }

    private func triggerBeaconEnter(_ beacon: NotificareBeacon) {
        guard let device = Notificare.shared.device().currentDevice else {
            logger.warning("Cannot process beacon enter trigger without a device.")
            return
        }

        LocalStorage.enteredBeacons = LocalStorage.enteredBeacons.appending(beacon.id)

        let payload = NotificareInternals.PushAPI.Payloads.BeaconTrigger(
            deviceID: device.id,
            beacon: beacon.id
        )

        Task {
            do {
                try await NotificareRequest.Builder()
                    .post("trigger/re.notifica.trigger.beacon.Enter", body: payload)
                    .response()

                logger.debug("Triggered beacon enter.")
            } catch {
                logger.error("Failed to trigger a beacon enter.", error: error)
            }
        }
    }

    private func triggerBeaconExit(_ beacon: NotificareBeacon) {
        guard let device = Notificare.shared.device().currentDevice else {
            logger.warning("Cannot process beacon exit trigger without a device.")
            return
        }

        LocalStorage.enteredBeacons = LocalStorage.enteredBeacons.removing(beacon.id)

        let payload = NotificareInternals.PushAPI.Payloads.BeaconTrigger(
            deviceID: device.id,
            beacon: beacon.id
        )

        Task {
            do {
                try await NotificareRequest.Builder()
                    .post("trigger/re.notifica.trigger.beacon.Exit", body: payload)
                    .response()

                logger.debug("Triggered beacon exit.")
            } catch {
                logger.error("Failed to trigger a beacon exit.", error: error)
            }
        }
    }

    private func startRegionSession(_ region: NotificareRegion) {
        logger.debug("Starting session for region '\(region.name)'.")

        var sessions = LocalStorage.regionSessions

        guard !sessions.contains(where: { $0.regionId == region.id }) else {
            logger.debug("Skipping region session start since it already exists for region '\(region.name)'.")
            return
        }

        let location = locationManager.location.flatMap { NotificareLocation(cl: $0) }

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
        logger.debug("Updating region sessions.")

        LocalStorage.regionSessions = LocalStorage.regionSessions.map { session in
            guard let region = LocalStorage.monitoredRegions.first(where: { $0.id == session.regionId }),
                  let clr = region.toCLRegion(with: locationManager) as? CLCircularRegion,
                  clr.contains(location.coordinate)
            else {
                return session
            }

            logger.debug("Updating region '\(region.name)' session.")

            return NotificareRegionSession(
                regionId: session.regionId,
                start: session.start,
                end: session.end,
                locations: session.locations.appending(NotificareLocation(cl: location))
            )
        }
    }

    private func stopRegionSession(_ region: NotificareRegion) {
        logger.debug("Stopping session for region '\(region.name)'.")

        Task {
            var sessions = LocalStorage.regionSessions

            guard var session = sessions.first(where: { $0.regionId == region.id }) else {
                logger.debug("Skipping region session end since no session exists for region '\(region.name)'.")
                return
            }

            sessions.removeAll(where: { $0.regionId == region.id })
            LocalStorage.regionSessions = sessions

            if session.locations.count > MAX_REGION_SESSION_LOCATIONS {
                session = NotificareRegionSession(
                    regionId: session.regionId,
                    start: session.start,
                    end: session.end,
                    locations: session.locations.takeEvenlySpaced(MAX_REGION_SESSION_LOCATIONS)
                )
            }

            do {
                try await Notificare.shared.events().logRegionSession(session)

                logger.debug("Region session logged.")
            } catch {
                logger.error("Failed to log the region session.", error: error)

            }
        }
    }

    private func startBeaconSession(_ beacon: NotificareBeacon) {
        guard let region = LocalStorage.monitoredRegions.first(where: { $0.id == beacon.id }) else {
            logger.warning("Cannot start the session for beacon '\(beacon.name)' since the corresponding region is not being monitored.")
            return
        }

        logger.debug("Starting session for beacon '\(beacon.name)'.")

        guard !LocalStorage.beaconSessions.contains(where: { $0.regionId == region.id }) else {
            logger.debug("Skipping beacon session start since it already exists for region '\(region.name)'.")
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
            logger.warning("Cannot update the session for beacon (major: \(beacon.major), minor: '\(beacon.minor))' since the corresponding region is not being monitored.")
            return
        }

        LocalStorage.beaconSessions = LocalStorage.beaconSessions.map { session in
            guard session.regionId == region.id, session.canInsertBeacon(beacon) else {
                return session
            }

            logger.debug("Updating beacon session for region '\(region.name)'.")

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
            logger.warning("Cannot stop the session for beacon '\(beacon.name)' since the corresponding region is not being monitored.")
            return
        }

        guard let session = LocalStorage.beaconSessions.first(where: { $0.regionId == region.id }) else {
            logger.debug("Skipping beacon session end since no session exists for region '\(region.name)'.")
            return
        }

        logger.debug("Stopping session for beacon '\(beacon.name)'.")
        LocalStorage.beaconSessions = LocalStorage.beaconSessions.filter { $0.regionId != region.id }

        Task {
            do {
                try await Notificare.shared.events().logBeaconSession(session)

                logger.debug("Beacon session logged.")
            } catch {
                logger.error("Failed to log the beacon session.", error: error)
            }
        }
    }

    private func startMonitoringBeacons(in region: NotificareRegion) {
        guard monitoredBeaconsLimit > 0 else {
            logger.debug("Maximum monitored regions reached. Cannot monitor beacons.")
            return
        }

        logger.debug("Starting to monitor beacons in region '\(region.name)'.")

        guard let uuidStr = Notificare.shared.application?.regionConfig?.proximityUUID,
              let uuid = UUID(uuidString: uuidStr)
        else {
            logger.warning("The Proximity UUID property has not been configured for this application.")
            return
        }

        guard let major = region.major else {
            logger.debug("The region '\(region.name)' has not been assigned a major.")
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

        logger.debug("Started monitoring the region beacon major.")

        //
        // Monitor each beacon in the region.
        //

        Task {
            do {
                let response = try await NotificareRequest.Builder()
                    .get("/beacon/forregion/\(region.id)")
                    .query(name: "limit", value: String(monitoredBeaconsLimit))
                    .responseDecodable(NotificareInternals.PushAPI.Responses.FetchBeacons.self)

                let beacons = response.beacons
                    .map { $0.toModel() }

                // Start monitoring every beacon.
                beacons.forEach { self.startMonitoringBeacon($0, with: uuid) }

                // Store the beacons in local storage.
                LocalStorage.monitoredBeacons = LocalStorage.monitoredBeacons.appending(contentsOf: beacons)

                logger.debug("Started monitoring \(beacons.count) individual beacons.")
            } catch {
                logger.error("Failed to fetch beacons for region '\(region.name)'.", error: error)
            }
        }
    }

    private func startMonitoringBeacon(_ beacon: NotificareBeacon, with uuid: UUID) {
        guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else {
            logger.warning("Beacon monitoring is not available.")
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

    private func stopMonitoringBeacons(in region: NotificareRegion) {
        // Stop monitoring all beacon regions with the same major.
        locationManager.monitoredRegions
            .compactMap { $0 as? CLBeaconRegion }
            .filter { $0.major?.intValue == region.major }
            .forEach { clr in
                // Make sure we stop monitoring it, it will start again on a region enter.
                locationManager.stopMonitoring(for: clr)

                guard let beacon = LocalStorage.monitoredBeacons.first(where: { $0.id == clr.identifier }) else {
                    //
                    return
                }

                if clr.minor != nil {
                    //
                    // This is an actual beacon region.
                    //

                    if LocalStorage.enteredBeacons.contains(clr.identifier) {
                        triggerBeaconExit(beacon)
                    }
                } else {
                    //
                    // This is the main beacon region.
                    //

                    if #available(iOS 13.0, *) {
                        locationManager.stopRangingBeacons(satisfying: clr.beaconIdentityConstraint)
                        locationManager(locationManager, didRange: [], satisfying: clr.beaconIdentityConstraint)
                    } else {
                        locationManager.stopRangingBeacons(in: clr)
                        locationManager(locationManager, didRangeBeacons: [], in: clr)
                    }

                    stopBeaconSession(beacon)
                }
            }

        // Remove all monitored beacons with this region's major.
        LocalStorage.monitoredBeacons = LocalStorage.monitoredBeacons.filter { $0.major != region.major }
    }

    private func handleRangingBeacons(_ clBeacons: [CLBeacon], in clr: CLBeaconRegion) {
        guard clr.identifier != FAKE_BEACON_IDENTIFIER else {
            locationManager.stopMonitoring(for: clr)

            if #available(iOS 13.0, *) {
                locationManager.stopRangingBeacons(satisfying: clr.beaconIdentityConstraint)
            } else {
                locationManager.stopRangingBeacons(in: clr)
            }

            updateBluetoothState(enabled: true)

            return
        }

        guard let region = LocalStorage.monitoredRegions.first(where: { $0.id == clr.identifier }) else {
            logger.warning("Received a beacon ranging event for non-cached region '\(clr.identifier)'.")
            return
        }

        guard LocalStorage.enteredRegions.contains(region.id) else {
            logger.warning("Received a beacon ranging event for non-entered region '\(region.name)'.")
            return
        }

        var beacons = [NotificareBeacon]()

        clBeacons
            .filter { $0.proximity != .unknown }
            .forEach { clb in
                if var beacon = LocalStorage.monitoredBeacons.first(where: { $0.major == clb.major.intValue && $0.minor == clb.minor.intValue }) {
                    // Expose the proximity for the developers.
                    beacon.proximity = NotificareBeacon.Proximity(clb.proximity) ?? .unknown
                    beacons.append(beacon)

                    // Update beacon session.
                    updateBeaconSession(clb)
                }
            }

        DispatchQueue.main.async {
            // Notify the delegate.
            self.delegate?.notificare(self, didRange: beacons, in: region)
        }
    }

    private func handleRangingBeaconsError(_ error: Error, for clr: CLBeaconRegion) {
        guard clr.identifier == FAKE_BEACON_IDENTIFIER else {
            guard let region = LocalStorage.monitoredRegions.first(where: { $0.id == clr.identifier }) else {
                logger.debug("Received an event (didFailRangingFor) for non-cached region '\(clr.identifier)'.")
                return
            }

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didFailRangingFor: region, with: error)
            }

            return
        }

        locationManager.stopMonitoring(for: clr)

        if #available(iOS 13.0, *) {
            locationManager.stopRangingBeacons(satisfying: clr.beaconIdentityConstraint)
        } else {
            locationManager.stopRangingBeacons(in: clr)
        }

        updateBluetoothState(enabled: false)
    }

    private func checkBluetoothEnabled() {
        logger.debug("Checking bluetooth service state.")

        let clr: CLBeaconRegion

        if #available(iOS 13.0, *) {
            clr = CLBeaconRegion(
                beaconIdentityConstraint: CLBeaconIdentityConstraint(uuid: fakeBeaconUUID),
                identifier: FAKE_BEACON_IDENTIFIER
            )
        } else {
            clr = CLBeaconRegion(
                proximityUUID: fakeBeaconUUID,
                identifier: FAKE_BEACON_IDENTIFIER
            )
        }

        clr.notifyEntryStateOnDisplay = false
        clr.notifyOnEntry = false
        clr.notifyOnExit = false

        locationManager.startMonitoring(for: clr)
    }

    private func updateBluetoothState(enabled: Bool) {
        guard let device = Notificare.shared.device().currentDevice else {
            logger.warning("Cannot update bluetooth state when no device is configured.")
            return
        }

        if hasBluetoothEnabled != enabled {
            let payload = NotificareInternals.PushAPI.Payloads.BluetoothStateUpdate(
                bluetoothEnabled: enabled
            )

            Task {
                do {
                    try await NotificareRequest.Builder()
                        .put("/push/\(device.id)", body: payload)
                        .response()

                    logger.debug("Bluetooth state updated.")
                    self.hasBluetoothEnabled = enabled
                } catch {
                    logger.error("Failed to update the bluetooth state.", error: error)
                }
            }
        } else {
            logger.debug("Skipped bluetooth state update, nothing changed.")
        }
    }

    // MARK: - NotificationCenter events

    @objc private func onApplicationDidBecomeActiveNotification(_: Notification) {
        guard hasLocationServicesEnabled else { return }

        guard Notificare.shared.isReady else { return }

        do {
            try checkPrerequisites()
            try checkPlistPrerequisites()
        } catch {
            return
        }

        // Request user location when we're only authorized while in use
        // or when the background updates are not available.
        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            UIApplication.shared.backgroundRefreshStatus == .denied ||
            UIApplication.shared.backgroundRefreshStatus == .restricted ||
            !CLLocationManager.significantLocationChangeMonitoringAvailable()
        {
            logger.debug("Requesting user location. This might take a while. Please wait...")
            locationManager.requestLocation()
        }

        if Notificare.shared.options?.headingApiEnabled == true && CLLocationManager.headingAvailable() {
            logger.debug("Started updating heading.")
            locationManager.startUpdatingHeading()
        }

        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            checkBluetoothEnabled()
        }
    }

    @objc private func onApplicationWillResignActiveNotification(_: Notification) {
        guard hasLocationServicesEnabled else { return }

        do {
            try checkPrerequisites()
            try checkPlistPrerequisites()
        } catch {
            return
        }

        if Notificare.shared.options?.headingApiEnabled == true, CLLocationManager.headingAvailable() {
            logger.debug("Stopped updating heading.")
            locationManager.stopUpdatingHeading()
        }
    }

    // MARK: - CLLocationManagerDelegate

    // Prior to iOS 14, this delegate gets called instead
    public func locationManager(_: CLLocationManager, didChangeAuthorization _: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
            handleLocationServicesUnauthorized()
        }
    }

    @available(iOS 14.0, *)
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            handleLocationServicesUnauthorized()
            return
        }

        if manager.accuracyAuthorization == .reducedAccuracy {
            logger.debug("Location accuracy authorization set to reduced. Removing regions and beacons.")
            stopMonitoringGeofences()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            DispatchQueue.main.async {
                // Notify the delegate regardless of the decision to process the location.
                self.delegate?.notificare(self, didUpdateLocations: locations.map { NotificareLocation(cl: $0) })
            }

            return
        }

        handlePolygonSessions(for: location)
        handleLocationUpdate(location)

        DispatchQueue.main.async {
            self.delegate?.notificare(self, didUpdateLocations: locations.map { NotificareLocation(cl: $0) })
        }
    }

    public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .locationUnknown || error.code == .network {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.enableLocationUpdates()
            }
        }

        DispatchQueue.main.async {
            self.delegate?.notificare(self, didFailWith: error)
        }
    }

    public func locationManager(_: CLLocationManager, didStartMonitoringFor clr: CLRegion) {
        if clr.identifier == FAKE_BEACON_IDENTIFIER, let clr = clr as? CLBeaconRegion {
            if #available(iOS 13.0, *) {
                locationManager.startRangingBeacons(satisfying: clr.beaconIdentityConstraint)
            } else {
                locationManager.startRangingBeacons(in: clr)
            }

            return
        }

        // Removing this request for state since we already request it right after starting
        // to monitor a region. This causes two state requests for newly monitored regions.
        //
        // // Check the state after 2 seconds to avoid colision with other requests.
        // DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        //     manager.requestState(for: region)
        // }

        if clr is CLBeaconRegion {
            guard let beacon = LocalStorage.monitoredBeacons.first(where: { $0.id == clr.identifier }) else {
                logger.debug("Received an event (didStartMonitoringFor) for non-cached beacon '\(clr.identifier)'.")
                return
            }

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didStartMonitoringFor: beacon)
            }
        } else {
            guard let region = LocalStorage.monitoredRegions.first(where: { $0.id == clr.identifier }) else {
                logger.debug("Received an event (didStartMonitoringFor) for non-cached region '\(clr.identifier)'.")
                return
            }

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didStartMonitoringFor: region)
            }
        }
    }

    public func locationManager(_: CLLocationManager, monitoringDidFailFor clr: CLRegion?, withError error: Error) {
        guard let clr = clr else { return }

        // Retry to monitor this region
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.locationManager.startMonitoring(for: clr)
        }

        if clr is CLBeaconRegion {
            guard let beacon = LocalStorage.monitoredBeacons.first(where: { $0.id == clr.identifier }) else {
                logger.debug("Received an event (monitoringDidFailFor) for non-cached beacon '\(clr.identifier)'.")
                return
            }

            DispatchQueue.main.async {
                self.delegate?.notificare(self, monitoringDidFailFor: beacon, with: error)
            }
        } else {
            guard let region = LocalStorage.monitoredRegions.first(where: { $0.id == clr.identifier }) else {
                logger.debug("Received an event (monitoringDidFailFor) for non-cached region '\(clr.identifier)'.")
                return
            }

            DispatchQueue.main.async {
                self.delegate?.notificare(self, monitoringDidFailFor: region, with: error)
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion clr: CLRegion) {
        if clr is CLBeaconRegion {
            guard let beacon = LocalStorage.monitoredBeacons.first(where: { $0.id == clr.identifier }) else {
                logger.debug("Received an event (didEnterRegion) for non-cached beacon '\(clr.identifier)'.")
                return
            }

            // Prevent calling the delegate method for the main region.
            guard beacon.minor != nil else { return }

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didEnter: beacon)
            }
        } else {
            guard let region = LocalStorage.monitoredRegions.first(where: { $0.id == clr.identifier }) else {
                logger.debug("Received an event (didEnterRegion) for non-cached region '\(clr.identifier)'.")
                return
            }

            // Ignore polygons.
            // Location is requested by the keep alive mechanism.
            if !region.isPolygon {
                // Trigger a location update in order to update the loaded fences as a side effect.
                manager.requestLocation()
            }

            // Prevent the didEnterRegion for polygons.
            // Entering the circular region is no guarantee we entered the polygon.
            if !region.isPolygon {
                DispatchQueue.main.async {
                    self.delegate?.notificare(self, didEnter: region)
                }
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didExitRegion clr: CLRegion) {
        if clr is CLBeaconRegion {
            guard let beacon = LocalStorage.monitoredBeacons.first(where: { $0.id == clr.identifier }) else {
                logger.debug("Received an event (didExitRegion) for non-cached beacon '\(clr.identifier)'.")
                return
            }

            // Prevent calling the delegate method for the main region.
            guard beacon.minor != nil else { return }

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didExit: beacon)
            }
        } else {
            // Trigger a location update in order to update the loaded fences as a side effect.
            manager.requestLocation()

            guard let region = LocalStorage.monitoredRegions.first(where: { $0.id == clr.identifier }) else {
                logger.debug("Received an event (didExitRegion) for non-cached region '\(clr.identifier)'.")
                return
            }

            // Prevent the didExitRegion for polygons.
            // Although leaving the circular region guarantees we exit the polygon, we don't want to emit multiple
            // events. A location update will process the exit event instead.
            if !region.isPolygon {
                DispatchQueue.main.async {
                    self.delegate?.notificare(self, didExit: region)
                }
            }
        }
    }

    public func locationManager(_: CLLocationManager, didDetermineState state: CLRegionState, for clr: CLRegion) {
        switch state {
        case .inside:
            handleRegionEnter(clr)

        case .outside:
            handleRegionExit(clr)

        case .unknown:
            break
        }

        if clr is CLBeaconRegion {
            guard let beacon = LocalStorage.monitoredBeacons.first(where: { $0.id == clr.identifier }) else {
                logger.debug("Received an event (didDetermineState) for non-cached beacon '\(clr.identifier)'.")
                return
            }

            // Prevent calling the delegate method for the main region.
            guard beacon.minor != nil else { return }

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didDetermineState: state, for: beacon)
            }
        } else {
            guard let region = LocalStorage.monitoredRegions.first(where: { $0.id == clr.identifier }) else {
                logger.debug("Received an event (didDetermineState) for non-cached region '\(clr.identifier)'.")
                return
            }

            if
                region.isPolygon,
                state == .inside || state == .outside
            {
                let newState: CLRegionState = LocalStorage.enteredRegions.contains(region.id) ? .inside : .outside

                DispatchQueue.main.async {
                    self.delegate?.notificare(self, didDetermineState: newState, for: region)
                }

                return
            }

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didDetermineState: state, for: region)
            }
        }
    }

    public func locationManager(_: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        handleRangingBeacons(beacons, in: region)
    }

    @available(iOS 13.0, *)
    public func locationManager(_: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        let region = locationManager.monitoredRegions
            .compactMap { $0 as? CLBeaconRegion }
            .first { $0.beaconIdentityConstraint == beaconConstraint }

        guard let region = region else { return }

        handleRangingBeacons(beacons, in: region)
    }

    public func locationManager(_: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        handleRangingBeaconsError(error, for: region)
    }

    @available(iOS 13.0, *)
    public func locationManager(_: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        let region = locationManager.monitoredRegions
            .compactMap { $0 as? CLBeaconRegion }
            .first { $0.beaconIdentityConstraint == beaconConstraint }

        guard let region = region else { return }

        handleRangingBeaconsError(error, for: region)
    }

    public func locationManager(_: CLLocationManager, didVisit visit: CLVisit) {
        guard visit.departureDate != Date.distantFuture else { return }

        let visit = NotificareVisit(
            departureDate: visit.departureDate,
            arrivalDate: visit.arrivalDate,
            latitude: visit.coordinate.latitude,
            longitude: visit.coordinate.longitude
        )

        Task {
            do {
                try await Notificare.shared.events().logVisit(visit)
                logger.debug("Visit event successfully registered.")
            } catch {
                logger.error("Failed to register a visit event.", error: error)
            }
        }

        DispatchQueue.main.async {
            self.delegate?.notificare(self, didVisit: visit)
        }
    }

    public func locationManager(_: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let heading = NotificareHeading(
            magneticHeading: newHeading.magneticHeading,
            trueHeading: newHeading.trueHeading,
            headingAccuracy: newHeading.headingAccuracy,
            x: newHeading.x,
            y: newHeading.y,
            z: newHeading.z,
            timestamp: newHeading.timestamp
        )

        DispatchQueue.main.async {
            self.delegate?.notificare(self, didUpdateHeading: heading)
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
