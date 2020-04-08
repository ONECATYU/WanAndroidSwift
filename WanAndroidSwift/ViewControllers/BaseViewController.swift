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
    
    let disposeBag = DisposeBag()
    
    var navigationBarHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        navigationController?.navigationBar.shadowImage = UIImage()
        
        bindViewsTheme()
        bindNavigationBarTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(navigationBarHidden, animated: true)
    }
    
    func bindViewsTheme() {
        appTheme.rx
        .bind({ $0.backgroundColor }, to: view.rx.backgroundColor)
        .disposed(by: disposeBag)
    }
    
    func bindNavigationBarTheme() {
        guard let nav = navigationController else { return }
        appTheme.rx
            .bind({ $0.lightBackgroundColor }, to: nav.navigationBar.rx.barBackgroundColor)
            .bind({ $0.textColor }, to: nav.navigationBar.rx.tintColor, nav.navigationBar.rx.barTintColor, nav.navigationBar.rx.titleColor)
            .disposed(by: disposeBag)
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
