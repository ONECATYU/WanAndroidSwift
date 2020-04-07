//
//  TextCollectionViewCell.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/13.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit

class TextCollectionViewCell: UICollectionViewCell {
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .subTitle
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textLabel)
        appTheme.rx
            .bind({ $0.textColor }, to: textLabel.rx.textColor)
            .bind({ $0.lightBackgroundColor }, to: contentView.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = contentView.bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let padding: CGFloat = 8
        let contentSize = textLabel.sizeThatFits(size)
        return CGSize(width: contentSize.width + 2 * padding, height: contentSize.height + padding)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
