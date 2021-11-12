//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreLocation
import Foundation
import NotificareGeoKit
import UIKit

class RangingBeaconsViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private var region: NotificareRegion?
    private var beacons: [NotificareBeacon]?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(onRangingBeacons(_:)), name: .RangingBeacons, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: .RangingBeacons, object: nil)
    }

    @objc private func onRangingBeacons(_ notification: Notification) {
        guard let region = notification.userInfo?["region"] as? NotificareRegion,
              let beacons = notification.userInfo?["beacons"] as? [NotificareBeacon]
        else {
            return
        }

        self.region = region
        self.beacons = beacons

        tableView.reloadData()
    }
}

extension RangingBeaconsViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        beacons?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let beacon = beacons![indexPath.row]
        let region = region!

        let cell = tableView.dequeueReusableCell(withIdentifier: "ranging-beacon", for: indexPath) as! RangingBeaconTableViewCell
        cell.render(beacon: beacon, in: region)

        return cell
    }
}
