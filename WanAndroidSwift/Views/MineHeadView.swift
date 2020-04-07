//
//  MineHeadView.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/30.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Kingfisher

class MineHeadView: UIView {
    
    var headImgView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 35
        return view
    }()
    
    var userNameBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.largeTitle
        btn.setTitle("点击登录", for: .normal)
        return btn
    }()
    
    var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.subTitle
        label.text = "ID: --   等级: --   排名: --"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeFlexLayout { (make) in
            make.flexDirection(.column).alignItems(.center).justifyContent(.center).padding(12)
            make.addChild(self.headImgView).width(70).aspectRatio(1.0)
            make.addChild(self.userNameBtn).marginTop(12)
            make.addChild(self.infoLabel)
        }
        yoga.adjustsViewHierarchy()
        
        appTheme.rx
            .bind({ $0.textColor }, to: userNameBtn.rx.titleColor(for: .normal))
            .bind({ $0.subTextColor }, to: infoLabel.rx.textColor)
            .bind({ $0.lightBackgroundColor }, to: headImgView.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        yoga.applyLayout(preservingOrigin: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension MineHeadView {
    func setSubviewsInfos(with user: UserModel) {
        if user.isLogin {
            userNameBtn.setTitle(user.displayName, for: .normal)
            let infos = "ID: \(user.id!)   等级: \(user.rank)   排名: \(user.coinCount)"
            infoLabel.text = infos
        } else {
            userNameBtn.setTitle("点击登录", for: .normal)
            infoLabel.text = "ID: --   等级: --   排名: --"
        }
        yoga.markChildrenDirty()
        setNeedsLayout()
    }
    
    var bindUser: Binder<UserModel> {
        return Binder<UserModel>(self) { (view, user) in
            view.setSubviewsInfos(with: user)
        }
    }
}
