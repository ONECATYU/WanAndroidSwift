//
//  NavigationModel.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/13.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import HandyJSON

class NavigateModel: HandyJSON {
    
    var articles: [ArticleModel] = []
    var cid: Int?
    var name: String = ""
    
    required init() {
        
    }
}
