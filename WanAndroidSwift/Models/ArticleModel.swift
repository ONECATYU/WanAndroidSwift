//
//  ArticleModel.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/9.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import HandyJSON

class ArticleModel: HandyJSON {
    var apkLink: String?
    var audit: Int = 0
    var author: String?
    var chapterId: String?
    var chapterName: String?
    var collect = false
    var courseId: Int?
    var desc: String?
    var envelopePic: String?
    var fresh = false
    var id: Int!
    var link: String?
    var niceDate: String?
    var niceShareDate: String?
    var origin: String?
    var prefix: String?
    var projectLink: String?
    var publishTime: Int?
    var selfVisible: Int?
    var shareDate: Int?
    var shareUser: String?
    var superChapterId: Int?
    var superChapterName: String?
    var tags: [ArticleTagModel]?
    var title: String?
    var type: Int?
    var userId: Int?
    var visible: Int?
    var zan: Int = 0
    
    var isTop = false
    
    required init() {
        
    }
    
    func didFinishMapping() {
        title = title?.filterHTMLString
        desc = desc?.filterHTMLString
    }
}

extension ArticleModel {
    var displayAuthor: String? {
        if author == nil || author! == "" {
            return shareUser
        }
        return author
    }
    
    var displayOrigin: String? {
        var string = chapterName
        if string != nil && !string!.isEmpty &&
            superChapterName != nil && !superChapterName!.isEmpty {
            string = "\(string!)·\(superChapterName!)"
        }
        return string
    }
}

class ArticleTagModel: HandyJSON {
    var name: String?
    var url: String?
    
    required init() {
        
    }
}
