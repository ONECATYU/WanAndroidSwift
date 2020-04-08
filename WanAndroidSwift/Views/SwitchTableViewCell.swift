//
//  SwitchTableViewCell.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/4/8.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
    
    var `switch`: UISwitch = {
        let sw = UISwitch()
        return sw
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryView = self.switch
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
