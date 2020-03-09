//
//  UIColor+Hex.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/9.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit

extension UIColor {
    class func fromRGBA(
        _ r: CGFloat,
        _ g: CGFloat,
        _ b: CGFloat,
        _ a: CGFloat = 1.0
    ) -> UIColor {
        return UIColor(
            red: r / 256.0,
            green: g / 256.0,
            blue: b / 256.0,
            alpha: a
        )
    }
    
    class func fromHex(_ value: UInt64) -> UIColor {
        let r = (value & 0xff0000) >> 16
        let g = (value & 0xff00) >> 8
        let b = value & 0xff
        return UIColor(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff,
            alpha: 1
        )
    }
    
    var mapImage: UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(self.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
