//
//  NetworkLogger.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/12.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import Moya


public final class NetworkLogger: PluginType {
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        print("=====================================================")
        print("-> url: \(target.baseURL.absoluteString + target.path)\n")
        switch result {
        case .success(let response):
            if response.statusCode != 200 {
                print("-> data: \(response)\n")
            } else {
                if let jsonObj = try? response.mapJSON() {
                    if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted) {
                        let string = String(data: jsonData, encoding: .utf8)
                        print("-> data: \(string ?? "")\n")
                    }
                }
            }
        case .failure(let moyaErr):
            print("-> error: \(moyaErr)\n")
        }
        print("=====================================================")
    }
}
