//
//  RegisterViewController.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/30.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit

class RegisterViewController: BaseViewController {
    
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var repPasswordTF: UITextField!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var userNameContainer: UIView!
    @IBOutlet weak var passwordContainer: UIView!
    @IBOutlet weak var repPasswordContainer: UIView!
    
    let viewModel = RegisterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.loading.asObservable().bind(to: showLoading).disposed(by: disposeBag)
        viewModel.error.asObservable().bind(to: showError).disposed(by: disposeBag)
        
        let userName = userNameTF.rx.text.filterNil()
        let password = passwordTF.rx.text.filterNil()
        let repPassword = repPasswordTF.rx.text.filterNil()
        
        let input = RegisterViewModel.Input(
            userName: userName,
            password: password,
            repPassword: repPassword,
            register: registerBtn.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        output.validate.subscribe(onNext: { [weak self] validate in
            guard let `self` = self else { return }
            self.registerBtn.isUserInteractionEnabled = validate
            self.registerBtn.isSelected = validate
        })
            .disposed(by: disposeBag)
        
        output.registerSuccess.subscribe(onNext: { [weak self] success in
            self?.dismiss(animated: true, completion: nil)
        })
        .disposed(by: disposeBag)
    }
    
    override func bindViewsTheme() {
        super.bindViewsTheme()
        appTheme.rx
            .bind({ $0.backgroundColor }, to: view.rx.backgroundColor)
            .bind({ $0.lightBackgroundColor }, to: userNameContainer.rx.backgroundColor, passwordContainer.rx.backgroundColor, repPasswordContainer.rx.backgroundColor, registerBtn.rx.backgroundColor)
            .bind({ $0.textColor }, to: userNameTF.rx.textColor, passwordTF.rx.textColor, repPasswordTF.rx.textColor)
            .bind({ $0.primaryColor }, to: registerBtn.rx.titleColor(for: .selected))
            .bind({ $0.subTextColor }, to: registerBtn.rx.titleColor(for: .normal))
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
