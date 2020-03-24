//
//  BaseViewController.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/9.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD_Add

class BaseViewController: UIViewController {
    
    lazy var refreshData = PublishSubject<Void>()
    lazy var loadMoreData = PublishSubject<Void>()
    
    lazy var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appTheme.rx.bind({ $0.backgroundColor }, to: view.rx.backgroundColor)
        if let nav = navigationController {
            nav.navigationBar.shadowImage = UIImage()
            appTheme.rx.bind({ $0.lightBackgroundColor }, to: nav.navigationBar.rx.barBackgroundColor)
        }
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
}

extension BaseViewController {
    var showLoading: Binder<Bool> {
        return Binder<Bool>(self) { (vc, isLoading) in
            if isLoading {
                vc.showHUD()
            } else {
                if let hud = vc.hud {
                    if let isAutoHidden = hud.isAutoHidden, isAutoHidden {
                        return
                    }
                    vc.hideHUD()
                }
            }
        }
    }
    
    var showError: Binder<Error?> {
        return Binder<Error?>(self) { (vc, error) in
            if let reqErr = error as? RequestError {
                vc.showError(msg: reqErr.localizedDescription)
            }
        }
    }
}
