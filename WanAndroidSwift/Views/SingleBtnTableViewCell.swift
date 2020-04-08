//
//  CenterTitleTableViewCell.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/4/8.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit

class SingleBtnTableViewCell: UITableViewCell {
    
    var button: UIButton = {
        let btn = UIButton(type: .custom)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
