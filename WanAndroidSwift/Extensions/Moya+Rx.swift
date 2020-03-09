//
//  Moya_Rx.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/9.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import RxSwift
import Moya

extension MoyaProvider: ReactiveCompatible { }

extension Reactive where Base: MoyaProviderType {
    func request(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Observable<Response> {
        return Observable.create({ (observer) -> Disposable in
            let cancellableToken = self.base.request(token, callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                case let .success(response):
                    observer.onNext(response)
                case let .failure(error):
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            return Disposables.create {
                cancellableToken.cancel()
            }
        })
    }
}
