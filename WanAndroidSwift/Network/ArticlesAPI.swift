//
//  ArticlesApi.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/17.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import Moya

enum ArticlesAPI {
    /// (page)
    case home(Int)
    case homeStick
    /// (id, page)
    case tree(String, Int)
    /// (id, page)
    case project(String, Int)
    /// (id, page)
    case publicPlat(String, Int)
}

extension ArticlesAPI: TargetType {
    var path: String {
        switch self {
        case .home(let page):
            return "/article/list/\(page)/json"
        case .homeStick:
            return "/article/top/json"
        case .tree(_, let page):
            return "/article/list/\(page)/json"
        case .project(_, let page):
            return "/project/list/\(page)/json"
        case .publicPlat(let id, let page):
            return "/wxarticle/list/\(id)/\(page)/json"
        }
    }
    
    var task: Task {
        switch self {
        case .tree(let cid, _):
            return .requestParameters(parameters: ["cid": cid], encoding: URLEncoding.queryString)
        case .project(let cid, _):
            return .requestParameters(parameters: ["cid": cid], encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
}

extension ArticlesAPI {
    static let provider = MoyaProvider<ArticlesAPI>(plugins: defaultPlugins)
}
