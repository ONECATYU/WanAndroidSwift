//
//  String.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/12.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation

extension String {
    var filterHTMLString: String {
        var result = self
        if let regExp = try? NSRegularExpression(pattern: "<[^>]*>|\\r|\\n", options: .caseInsensitive) {
            result = regExp.stringByReplacingMatches(in: self, options: .reportProgress, range: NSRange(location: 0, length: self.count), withTemplate: "")
        }
        return result
    }
}
