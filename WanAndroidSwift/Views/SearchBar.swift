//
//  SearchBar.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/13.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit

class SearchBar: UIView {
    
    enum Style {
        case click, input
    }
    
    var placeholder: String? {
        willSet {
            placeholderLabel.text = newValue
            textField.placeholder = newValue
        }
    }
    
    override var tintColor: UIColor! {
        willSet {
            iconView.image = Iconfont.search.image(size: 18, color: newValue)
            placeholderLabel.textColor = newValue
            textField.tintColor = newValue
            textField.textColor = newValue
        }
    }
    
    var searchHandler: ((String) -> Void)?
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: 36)
    }
    
    private(set) var style: Style
    private(set) lazy var textField: UITextField = {
        let tf = UITextField()
        tf.returnKeyType = .search
        return tf
    }()
    
    private lazy var contentView = UIView()
    private lazy var iconView = UIImageView()
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.title
        return label
    }()
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        addSubview(contentView)
        configLayout(with: style)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = self.bounds
        contentView.yoga.applyLayout(preservingOrigin: true)
    }
    
    private func configLayout(with style: Style) {
        contentView.makeFlexLayout { (make) in
            make.flexDirection(.row)
                .alignItems(.center)
                .paddingHorizontal(6)
                .paddingVertical(2)
            make.addChild(self.iconView)
                .size(CGSize(width: 18, height: 18))
                .marginRight(6)
            switch style {
            case .click:
                make.justifyContent(.center)
                make.addChild(self.placeholderLabel).flexShrink(1)
            case .input:
                make.justifyContent(.flexStart)
                make.addChild(self.textField).flex(1)
            }
        }
        contentView.yoga.adjustsViewHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
