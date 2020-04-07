//
//  UserAPI.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/17.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import Moya

enum UserAPI {
    /// (article id)
    case collectArticle(Int)
    /// (userName, password)
    case login(String, String)
    /// (userName, password, repassword)
    case register(String, String, String)
    case logout
    case coinInfos
}

extension UserAPI: TargetType {
    var path: String {
        switch self {
        case .collectArticle(let id):
            return "/lg/collect/\(id)/json"
        case .login(_, _):
            return "/user/login"
            case .register(_, _, _):
            return "/user/register"
            case .logout:
            return "/user/logout/json"
        case .coinInfos:
            return "/lg/coin/userinfo/json"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .collectArticle(_), .login(_, _), .register(_, _, _):
            return .post
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .login(let userName, let pwd):
            return .requestParameters(
                parameters: ["username": userName, "password": pwd],
                encoding: URLEncoding.default
            )
        case .register(let userName, let pwd, let rePwd):
            return .requestParameters(
                parameters: ["username": userName, "password": pwd, "repassword": rePwd],
                encoding: URLEncoding.default
            )
        default:
            return .requestPlain
        }
    }
    
}

extension UserAPI {
    static let provider = MoyaProvider<UserAPI>(plugins: defaultPlugins)
}
