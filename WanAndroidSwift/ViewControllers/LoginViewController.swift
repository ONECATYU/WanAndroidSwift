//
//  LoginViewController.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/30.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var toRegisterBtn: UIButton!
    
    @IBOutlet weak var userNameTFContainer: UIView!
    @IBOutlet weak var passwordTFContainer: UIView!
    
    let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.loading.asObservable().bind(to: showLoading).disposed(by: disposeBag)
        viewModel.error.asObservable().bind(to: showError).disposed(by: disposeBag)
        
        let userName = userNameTF.rx.text.filterNil()
        let password = passwordTF.rx.text.filterNil()
                
        let input = LoginViewModel.Input(
            userName: userName,
            password: password,
            login: loginBtn.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        output.validate.subscribe(onNext: { [weak self] validate in
            guard let `self` = self else { return }
            self.loginBtn.isUserInteractionEnabled = validate
            self.loginBtn.isSelected = validate
        })
            .disposed(by: disposeBag)
        
        output.loginSuccess.subscribe(onNext: { [weak self] success in
            self?.dismiss(animated: true, completion: nil)
        })
        .disposed(by: disposeBag)
        toRegisterBtn.rx.tap.subscribe(onNext: { [weak self] in
            if let registerVC = RegisterViewController.fromStoryboard() {
                self?.navigationController?.pushViewController(registerVC, animated: true)
            }
        })
        .disposed(by: disposeBag)
        
        let colseItem = UIBarButtonItem(
            image: Iconfont.delete.image(size: 24),
            style: .plain,
            target: nil,
            action: nil
        )
        self.navigationItem.leftBarButtonItem = colseItem
        
        colseItem.rx.tap.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        })
            .disposed(by: disposeBag)
    }
    
    override func bindViewsTheme() {
        super.bindViewsTheme()
        appTheme.rx
            .bind({ $0.lightBackgroundColor }, to: userNameTFContainer.rx.backgroundColor, passwordTFContainer.rx.backgroundColor, loginBtn.rx.backgroundColor)
            .bind({ $0.textColor }, to: userNameTF.rx.textColor, passwordTF.rx.textColor)
            .bind({ $0.primaryColor }, to: loginBtn.rx.titleColor(for: .selected), toRegisterBtn.rx.titleColor(for: .normal))
            .bind({ $0.subTextColor }, to: loginBtn.rx.titleColor(for: .normal))
            .disposed(by: disposeBag)
    }
    
    override func bindNavigationBarTheme() {
        if let nav = navigationController {
            nav.navigationBar.shadowImage = UIImage()
            appTheme.rx
                .bind({ $0.backgroundColor }, to: nav.navigationBar.rx.barBackgroundColor)
                .bind({ $0.textColor }, to: nav.navigationBar.rx.tintColor)
                .disposed(by: disposeBag)
        }
    }
    
}

extension LoginViewController {
    class func show(from vc: UIViewController) {
        if let loginVC = LoginViewController.fromStoryboard() {
            let nav = UINavigationController(rootViewController: loginVC)
            vc.present(nav, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
