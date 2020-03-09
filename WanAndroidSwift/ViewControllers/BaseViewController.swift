//
//  BaseViewController.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/9.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appTheme.rx.bind({ $0.backgroundColor }, to: view.rx.backgroundColor)
        if let nav = navigationController {
            appTheme.rx.bind({ $0.lightBackgroundColor }, to: nav.navigationBar.rx.barTintColor)
        }
    }
    
}


