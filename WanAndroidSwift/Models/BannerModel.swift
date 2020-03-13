//
//  BannerModel.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/9.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import HandyJSON

class BannerModel: HandyJSON {
    var title: String?
    var desc: String?
    var id: Int = 0
    var imagePath: String?
    var isVisible: Bool = false
    var order: Int = 0
    var type: Int = 0
    var url: String?
    
    required init() {}
}
