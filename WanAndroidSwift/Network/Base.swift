//
//  Base.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/17.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import Moya

extension TargetType {
    var baseURL: URL {
        return URL(string: "https://www.wanandroid.com")!
    }
    
    var method: Moya.Method {
        return .get
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

let defaultPlugins = { () -> [PluginType] in
    #if DEBUG
    return [NetworkLogger()]
    #else
    return []
    #endif
}()
