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
}

extension UserAPI: TargetType {
    var path: String {
        switch self {
        case .collectArticle(let id):
            return "/lg/collect/\(id)/json"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .collectArticle(_):
            return .post
        }
    }
}

extension UserAPI {
    static let provider = MoyaProvider<UserAPI>(plugins: defaultPlugins)
}
