//
//  Request.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/9.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import HandyJSON

enum RequestError: Error {
    case dataInvalid(Response)
    case modelDeserialize(Response)
    case loginInvalid
    case server(String)
    case moya(MoyaError)
}

extension RequestError {
    var localizedDescription: String {
        switch self {
        case .dataInvalid(_):
            return "返回数据格式错误"
        case .modelDeserialize(_):
            return "数据解析错误"
        case .loginInvalid:
            return "您还未登录,请登录后操作"
        case .server(let msg):
            return msg
        case .moya(let moyaErr):
            return moyaErr.localizedDescription
        }
    }
}

extension MoyaProvider: ReactiveCompatible {}

extension Reactive where Base: MoyaProviderType {
    func request(
        _ target: Base.Target,
        callbackQueue: DispatchQueue? = nil
    ) -> Observable<Response>
    {
        return Observable<Response>.create { (observer) -> Disposable in
            let cancelToken = self.base.request(target, callbackQueue: callbackQueue, progress: nil) { (result) in
                switch result {
                case .success(let response):
                    if response.statusCode == 200 {
                        observer.onNext(response)
                        observer.onCompleted()
                    } else {
                        observer.onError(RequestError.moya(MoyaError.statusCode(response)))
                    }
                case .failure(let moyaErr):
                    observer.onError(RequestError.moya(moyaErr))
                }
            }
            return Disposables.create {
                cancelToken.cancel()
            }
        }
    }
}

extension Response {
    fileprivate func validate() -> ([String: Any]?, RequestError?) {
        let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let jsonDict = jsonObj as? [String: Any] else {
            return (nil, RequestError.dataInvalid(self))
        }
        
        if let errorCode = jsonDict["errorCode"] as? Int {
            if errorCode == -1001 {
                return (nil, RequestError.loginInvalid)
            }
            
            if errorCode != 0 {
                let message = (jsonDict["errorMsg"] as? String) ?? "服务器出错啦~"
                return (nil, RequestError.server(message))
            }
        }
        return (jsonDict, nil)
    }
}

extension ObservableType where Element == Moya.Response {
    
    func mapModel<Model: HandyJSON>(_ type: Model.Type, path: String? = nil) -> Observable<Model> {
        return flatMap { (response) -> Observable<Model> in
            return Observable<Model>.create { (observer) -> Disposable in
                let disposable = Disposables.create()
                let (jsonDict, reqErr) = response.validate()
                if let error = reqErr {
                    observer.onError(error)
                    return disposable
                }
                
                guard let model = Model.deserialize(from: jsonDict, designatedPath: path) else {
                    observer.onError(RequestError.modelDeserialize(response))
                    return disposable
                }
                observer.onNext(model)
                observer.onCompleted()
                return disposable
            }
        }
    }
    
    func mapModelList<Model: HandyJSON>(_ type: Model.Type, path: String) -> Observable<[Model]> {
        func innerObj(_ json: [String: Any], keyPath: String) -> Any? {
            var jsonObj: Any? = json
            let paths = path.components(separatedBy: ".")
            for key in paths {
                jsonObj = (jsonObj as? [String: Any])?[key]
                if jsonObj == nil {
                    return nil
                }
            }
            return jsonObj
        }
        return flatMap { (response) -> Observable<[Model]> in
            return Observable<[Model]>.create { (observer) -> Disposable in
                let disposable = Disposables.create()
                let (jsonDict, reqErr) = response.validate()
                if let error = reqErr {
                    observer.onError(error)
                    return disposable
                }
                guard
                    let jsonList = innerObj(jsonDict!, keyPath: path) as? [Any],
                    let models = [Model].deserialize(from: jsonList)
                    else {
                        
                        observer.onError(RequestError.modelDeserialize(response))
                        return disposable
                }
                var modelList = [Model]()
                for model in models {
                    if let model = model {
                        modelList.append(model)
                    }
                }
                observer.onNext(modelList)
                observer.onCompleted()
                return disposable
            }
        }
    }
    
    func validateSuccess() -> Observable<Bool> {
        return flatMap { (response) -> Observable<Bool> in
            return Observable<Bool>.create { (observer) -> Disposable in
                let (_, reqErr) = response.validate()
                if let error = reqErr {
                    observer.onError(error)
                } else {
                    observer.onNext(true)
                    observer.onCompleted()
                }
                return Disposables.create()
            }
        }
    }
}
