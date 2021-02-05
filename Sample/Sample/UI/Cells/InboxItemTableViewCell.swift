//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareInboxKit
import SDWebImage
import UIKit

class InboxItemTableViewCell: UITableViewCell {
    // UI references
    @IBOutlet var attachmentImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var notificationTypeLabel: UILabel!
    @IBOutlet var timeAgoLabel: UILabel!
    @IBOutlet var openedImageView: UIImageView!

    var item: NotificareInboxItem? {
        didSet { update() }
    }

    private func update() {
        guard let item = item else {
            return
        }

        attachmentImageView.clipsToBounds = true
        attachmentImageView.layer.cornerRadius = 8.0

        var attachmentUrl: URL?
        if let urlStr = item.attachment?.uri {
            attachmentUrl = URL(string: urlStr)
        }

        attachmentImageView.sd_setImage(with: attachmentUrl, placeholderImage: UIImage(named: "Badge"), options: []) { image, _, _, _ in
            self.attachmentImageView.contentMode = image != nil ? .scaleAspectFill : .scaleAspectFit
        }

        titleLabel.text = item.title
        messageLabel.text = item.message
        notificationTypeLabel.text = item.type.components(separatedBy: ".").last
        timeAgoLabel.text = item.time.timeAgo
        openedImageView.isHidden = item.opened
    }
}
