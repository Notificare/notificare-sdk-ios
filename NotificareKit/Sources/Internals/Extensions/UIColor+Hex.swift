//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import UIKit

public extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexColor = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if hexColor.starts(with: "#") {
            let start = hexColor.index(hexColor.startIndex, offsetBy: 1)
            hexColor = String(hexColor[start...])
        }

        let scanner = Scanner(string: hexColor)

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        let mask = 0x0000_00FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb = Int(r * 255) << 16 | Int(g * 255) << 8 | Int(b * 255) << 0

        return String(format: "#%06x", rgb)
    }
}
