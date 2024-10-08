//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import MapKit
import NotificareKit
import UIKit

public class NotificareMapViewController: NotificareBaseNotificationViewController {
    internal private(set) var mapView: MKMapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupContent()

        mapView.showAnnotations(mapView.annotations, animated: true)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        DispatchQueue.main.async {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: self.notification)
        }
    }

    private func setupViews() {
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        mapView.delegate = self

        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupContent() {
        var markers = [MapMarker]()

        notification.content
            .filter { $0.type == "re.notifica.content.Marker" }
            .forEach { content in
                if
                    let data = content.data as? [String: Any],
                    let latitude = data["latitude"] as? Double,
                    let longitude = data["longitude"] as? Double
                {
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let marker = MapMarker(title: data["title"] as? String,
                                           subtitle: data["description"] as? String,
                                           coordinate: coordinate)

                    markers.append(marker)
                }
            }

        mapView.addAnnotations(markers)
    }

    internal class MapMarker: NSObject, MKAnnotation {
        internal let title: String?
        internal let subtitle: String?
        internal let coordinate: CLLocationCoordinate2D

        internal init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
            if let title = title {
                self.title = title
            } else {
                self.title = NotificareLocalizable.string(resource: .mapUnknownTitleMarker)
            }

            self.subtitle = subtitle
            self.coordinate = coordinate
        }
    }
}

extension NotificareMapViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation === mapView.userLocation { // View for user location
            if let image = NotificareLocalizable.image(resource: .mapMarkerUserLocation) {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "NotificareUserLocation")
                    ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "NotificareUserLocation")

                view.isEnabled = true
                view.canShowCallout = false
                view.image = image
                view.annotation = annotation

                return view
            } else {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "NotificareUserLocation") as? MKPinAnnotationView
                    ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: "NotificareUserLocation")

                view.pinTintColor = UIColor.purple
                view.animatesDrop = true

                return view
            }
        } else { // View for marker
            if let image = NotificareLocalizable.image(resource: .mapMarker) {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "NotificareLocation")
                    ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "NotificareLocation")

                view.isEnabled = true
                view.canShowCallout = true
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                view.image = image
                view.annotation = annotation

                return view
            } else {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "NotificareLocation") as? MKPinAnnotationView
                    ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: "NotificareLocation")

                view.pinTintColor = UIColor.red
                view.canShowCallout = true
                view.animatesDrop = true
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

                return view
            }
        }
    }

    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped _: UIControl) {
        guard let annotation = view.annotation, view.annotation !== mapView.userLocation else {
            return
        }

        let currentLocation = MKMapItem.forCurrentLocation()
        let coordinate = annotation.coordinate

        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let destination = MKMapItem(placemark: placemark)
        destination.name = annotation.title ?? nil

        MKMapItem.openMaps(with: [currentLocation, destination],
                           launchOptions: [
                               MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                               MKLaunchOptionsShowsTrafficKey: true,
                           ])

        destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

extension NotificareMapViewController: NotificareNotificationPresenter {
    internal func present(in controller: UIViewController) {
        controller.presentOrPush(self) {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didPresentNotification: self.notification)
            }
        }
    }
}
