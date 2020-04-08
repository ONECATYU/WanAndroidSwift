//
//  SettingsViewModel.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/4/8.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SettingsViewModel: ViewModel, ViewModelType {
    struct Input {
        let switchTheme: Observable<Bool>
        var logout: Observable<Void>?
    }
    struct Output {
        var logoutSuccess: Observable<Void>?
    }
    
    func transform(input: Input) -> Output {
        input.switchTheme
            .map { $0 ? ThemeType.dark : .light }
            .bind(to: appTheme.switcher)
            .disposed(by: disposeBag)
        
        var logoutSuccess: Observable<Void>?
        if let logout = input.logout {
            logoutSuccess = logout.flatMapLatest { (_) -> Observable<Void> in
                return UserAPI.provider.rx
                    .request(.logout)
                    .validateSuccess()
                    .trackErrorJustComplete(self.error)
                    .trackActivity(self.loading)
            }
            .do(onNext: {
                let emptyUser = UserModel()
                emptyUser.writeToLocal()
                AppState.share.loginUser.accept(emptyUser)
            })
        }
        
        return Output(
            logoutSuccess: logoutSuccess
        )
    }
}
