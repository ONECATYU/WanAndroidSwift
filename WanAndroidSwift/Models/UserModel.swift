//
//  UserModel.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/4/2.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import HandyJSON

class UserModel: HandyJSON {
    var admin: Bool = false;
    var chapterTops: [Int]?;
    var collectIds: [Int]?;
    var email: String?;
    var icon: String?;
    var id: Int?;
    var nickname: String?;
    var password: String?;
    var publicName: String?;
    var token: String?;
    var type: Int?;
    var username: String?;

    var coinCount: Int = 0;
    var rank: Int = 0;
    
    required init() {}
}

extension UserModel {
    var isLogin: Bool {
        return id != nil
    }
    
    var displayName: String? {
        return nickname ?? username
    }
}

extension UserModel {
    class var cachePath: String {
        return "/user/login"
    }
    
    func writeToLocal() {
        guard
            let json = toJSONString(),
            let data = json.data(using: .utf8)
        else { return }
        FileUtils.write(data: data, to: UserModel.cachePath)
    }
    
    class func fromLoacl() -> UserModel? {
        if let data = FileUtils.readData(from: UserModel.cachePath) {
            let dataStr = String(data: data, encoding: .utf8)
            let user = UserModel.deserialize(from: dataStr)
            return user
        }
        return nil
    }
}
