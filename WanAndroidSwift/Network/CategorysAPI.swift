//
//  CategorysApi.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/24.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import Moya

/// tab上的分类
enum CategorysAPI {
    case publicPlat
    case project
}

extension CategorysAPI: TargetType {
    var path: String {
        switch self {
        case .publicPlat:
            return "/wxarticle/chapters/json"
        case .project:
            return "/project/tree/json"
        }
    }
}

extension CategorysAPI {
    static let provider = MoyaProvider<CategorysAPI>(plugins: defaultPlugins)
}
