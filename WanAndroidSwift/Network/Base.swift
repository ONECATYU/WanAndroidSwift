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
    let jsonDataFormatter: ((Data) -> String) = { data -> String in
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: data)
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
        } catch {
            return String(data: data, encoding: .utf8) ?? ""
        }
    }
    let logger = NetworkLoggerPlugin(verbose: true) { (data) -> (Data) in
        let jsonStr = jsonDataFormatter(data)
        let jsonData = jsonStr.data(using: .utf8)
        return jsonData ?? data
    }
    return [logger]
    #else
    return []
    #endif
}()
