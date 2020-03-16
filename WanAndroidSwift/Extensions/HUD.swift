//
//  HUD.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/16.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit
import MBProgressHUD
import MBProgressHUD_Add

extension MBProgressHUD {
    private struct AssociatedKeys {
        static var isAutoHiddenKey = "MBProgressHUD.isAutoHidden"
    }
    var isAutoHidden: Bool? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isAutoHiddenKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isAutoHiddenKey) as? Bool
        }
    }
}

extension UIViewController {
    func showSuccess(msg: String) {
        let image = Iconfont.success.image(size: 28, color: .white)
        showHUD(with: image, message: msg)
        hud?.isAutoHidden = true
    }
    
    func showError(msg: String) {
        let image = Iconfont.error.image(size: 28, color: .white)
        showHUD(with: image, message: msg)
        hud?.isAutoHidden = true
    }
    
    func showMessage(msg: String) {
        showHUDMessage(msg)
        hud?.isAutoHidden = true
    }
}
