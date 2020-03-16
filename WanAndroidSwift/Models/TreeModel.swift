//
//  TreeModel.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/13.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import HandyJSON

class TreeModel: HandyJSON {
    
    var children: [TreeModel] = []
    var courseId: Int?
    var id: Int?
    var order: Int?
    var parentChapterId: Int?
    var visible: Int = 0
    var name: String = ""
    var userControlSetTop = false
    
    required init() {
        
    }
}
