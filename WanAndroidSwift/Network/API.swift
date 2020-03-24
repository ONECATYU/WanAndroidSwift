//
//  Api.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/9.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import Moya

enum API {
    case banner
    case tree
    case nav
}

extension API: TargetType {
    var path: String {
        switch self {
        case .banner:
            return "/banner/json"
        case .tree:
            return "/tree/json"
        case .nav:
            return "/navi/json"
        }
    }
}

extension API {
    static let provider = MoyaProvider<API>(plugins: defaultPlugins)
}
