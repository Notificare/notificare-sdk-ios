//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareGeoKit
import UIKit

class RangingBeaconTableViewCell: UITableViewCell {
    @IBOutlet private var beaconLabel: UILabel!
    @IBOutlet private var regionLabel: UILabel!
    @IBOutlet private var proximityImage: UIImageView!

    func render(beacon: NotificareBeacon, in region: NotificareRegion) {
        beaconLabel.text = "\(beacon.name) (\(beacon.minor ?? 0))"
        regionLabel.text = region.name

        switch beacon.proximity {
        case .immediate:
            proximityImage.image = UIImage(named: "WiFi-Signal-3")
        case .near:
            proximityImage.image = UIImage(named: "WiFi-Signal-2")
        case .far:
            proximityImage.image = UIImage(named: "WiFi-Signal-1")
        default:
            if #available(iOS 13.0, *) {
                proximityImage.image = UIImage(systemName: "wifi.slash")
            } else {
                proximityImage.image = nil
            }
        }
    }
}
