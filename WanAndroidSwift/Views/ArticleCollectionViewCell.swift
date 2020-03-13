//
//  ArticleTableViewCell.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/11.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit
import FlexKit
import UITableView_FDTemplateLayoutCell

class ArticleCollectionViewCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = createLabel(font: .title)
    lazy var descLabel: UILabel = createLabel(font: .subTitle)
    lazy var newLabel: UILabel = createLabel()
    lazy var timeLabel: UILabel = createLabel()
    lazy var authorLabel: UILabel = createLabel()
    lazy var stickLabel: UILabel = createLabel()
    lazy var originLabel: UILabel = createLabel()
    
    lazy var collectBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(Iconfont.heart.image(size: 20, color: .red), for: .normal)
        btn.setImage(Iconfont.heartSolid.image(size: 20, color: .red), for: .selected)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configLayouts()
        configThemes()
        
        newLabel.text = "New"
        stickLabel.text = "置顶"
        titleLabel.numberOfLines = 2
        descLabel.numberOfLines = 3
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.yoga.applyLayout(preservingOrigin: true)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let finalSize = contentView.yoga.calculateLayout(with: size)
        return finalSize
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ArticleCollectionViewCell {
    private func configLayouts() {
        contentView.makeFlexLayout { (make) in
            make.flexDirection(.column).padding(12)
            /// header
            make.addChild { (make) in
                make.flexDirection(.row).justifyContent(.spaceBetween).marginBottom(12)
                make.addChild { (make) in
                    make.flexDirection(.row)
                    make.addChild(self.newLabel).marginRight(8)
                    make.addChild(self.authorLabel)
                }
                make.addChild(self.timeLabel)
            }
            
            /// title
            make.addChild(self.titleLabel)
            /// desc
            make.addChild(self.descLabel).marginTop(5)
            /// footer
            make.addChild { (make) in
                make.flexDirection(.row).justifyContent(.spaceBetween).alignItems(.flexEnd)
                make.addChild { (make) in
                    make.flexDirection(.row)
                    make.addChild(self.stickLabel).marginRight(8)
                    make.addChild(self.originLabel)
                }
                make.addChild(self.collectBtn).size(CGSize(width: 30, height: 30))
            }
        }
        /// 按照node树,将子view添加到父视图上
        contentView.yoga.adjustsViewHierarchy()
    }
    
    private func configThemes() {
        stickLabel.textColor = .orange
        backgroundColor = .clear
        appTheme.rx
            .bind({ $0.lightBackgroundColor }, to: rx.backgroundColor)
            .bind({ $0.primaryColor }, to: newLabel.rx.textColor)
            .bind({ $0.textColor }, to: titleLabel.rx.textColor)
            .bind({ $0.subTextColor }, to: authorLabel.rx.textColor, timeLabel.rx.textColor, descLabel.rx.textColor, originLabel.rx.textColor)
    }
    
    private func createLabel(font: UIFont = UIFont.small) -> UILabel {
        let label = UILabel()
        label.font = font
        return label
    }
}

extension ArticleCollectionViewCell {
    func bind(model article: ArticleModel) {
        
        authorLabel.text = article.displayAuthor
        timeLabel.text = article.niceDate
        titleLabel.text = article.title
        descLabel.text = article.desc
        originLabel.text = article.displayOrigin
        
        newLabel.isHidden = !article.fresh
        newLabel.yoga.isIncludedInLayout = article.fresh
        
        stickLabel.isHidden = !article.isTop
        stickLabel.yoga.isIncludedInLayout = article.isTop
        
        if article.desc == nil || article.desc! == "" {
            descLabel.isHidden = true
            descLabel.yoga.isIncludedInLayout = false
        } else {
            descLabel.isHidden = false
            descLabel.yoga.isIncludedInLayout = true
        }
        
        contentView.yoga.markChildrenDirty()
    }
}
