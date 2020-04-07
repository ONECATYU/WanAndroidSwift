//
//  TextCollectionReuseableView.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/13.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit

class TextCollectionReuseableView: UICollectionReusableView {
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .largeTitle
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textLabel)
        appTheme.rx
            .bind({ $0.textColor }, to: textLabel.rx.textColor)
            .disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = bounds
    }
}
