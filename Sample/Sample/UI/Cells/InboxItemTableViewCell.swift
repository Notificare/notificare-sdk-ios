//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareInboxKit
import UIKit
import SDWebImage

class InboxItemTableViewCell: UITableViewCell {
    
    // UI references
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var openedImageView: UIImageView!
    
    var item: NotificareInboxItem? {
        didSet { update() }
    }
    
    private func update() {
        guard let item = item else {
            return
        }
        
        attachmentImageView.clipsToBounds = true
        attachmentImageView.layer.cornerRadius = 8.0
        
        var attachmentUrl: URL? = nil
        if let urlStr = item.attachment?.uri {
            attachmentUrl = URL(string: urlStr)
        }
        
        attachmentImageView.sd_setImage(with: attachmentUrl, placeholderImage: UIImage(named: "Badge"), options: []) { (image, _, _, _) in
            self.attachmentImageView.contentMode = image != nil ? .scaleAspectFill : .scaleAspectFit
        }
        
        titleLabel.text = item.title
        messageLabel.text = item.message
        timeAgoLabel.text = item.time.timeAgo
        openedImageView.isHidden = item.opened
    }
}
