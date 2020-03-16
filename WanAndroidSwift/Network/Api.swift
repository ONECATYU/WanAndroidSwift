//
//  Api.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/9.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import Moya

enum Api {
    case banner
    case articles(Int)
    case collectArticle(Int)
    case tree
    case nav
}

extension Api: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.wanandroid.com")!
    }
    
    var path: String {
        switch self {
        case .banner:
            return "/banner/json"
        case .articles(let page):
            return "/article/list/\(page)/json"
        case .collectArticle(let id):
            return "/lg/collect/\(id)/json"
        case .tree:
            return "/tree/json"
        case .nav:
            return "/navi/json"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .collectArticle:
            return .post
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
}

func ApiProvider() -> MoyaProvider<Api> {
    return MoyaProvider<Api>(plugins: [NetworkLogger()])
}
