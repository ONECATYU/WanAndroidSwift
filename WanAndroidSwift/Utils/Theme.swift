//
//  Theme.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/9.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit
import RxSwift
import RxTheme

protocol Theme {
    var primaryColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var lightBackgroundColor: UIColor { get }
    
    var textColor: UIColor { get }
    var subTextColor: UIColor { get }
}

struct LightTheme: Theme {
    let primaryColor = UIColor.fromHex(0x52b6f4)
    let backgroundColor = UIColor.fromHex(0xf0f0f0)
    let lightBackgroundColor = UIColor.white
    
    let textColor = UIColor.black
    let subTextColor = UIColor.gray
}

struct DarkTheme: Theme {
    let primaryColor = UIColor.fromHex(0x52b6f4)
    let backgroundColor = UIColor.fromRGBA(42, 42, 42, 1)
    let lightBackgroundColor = UIColor.fromRGBA(60, 63, 65, 1)
    
    let textColor = UIColor.white
    let subTextColor = UIColor.gray
}

enum ThemeType: ThemeProvider {
    case light, dark
    var associatedObject: Theme {
        switch self {
        case .light:
            return LightTheme()
        case .dark:
            return DarkTheme()
        }
    }
}

let appTheme = ThemeType.service(initial: .dark)

/// APP font size
extension UIFont {
    class var title: UIFont {
        return UIFont.systemFont(ofSize: 17)
    }
    class var subTitle: UIFont {
        return UIFont.systemFont(ofSize: 15)
    }
    class var small: UIFont {
        return UIFont.systemFont(ofSize: 13)
    }
}
