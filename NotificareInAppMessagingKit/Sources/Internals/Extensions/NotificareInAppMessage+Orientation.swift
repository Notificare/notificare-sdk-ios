//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import UIKit

extension NotificareInAppMessage {
    internal var orientationConstrainedImage: String? {
        if UIDevice.current.orientation.isLandscape {
            return landscapeImage ?? image
        }
        
        return image ?? landscapeImage
    }
}
