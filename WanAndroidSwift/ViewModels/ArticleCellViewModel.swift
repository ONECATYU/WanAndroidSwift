//
//  ArticleCellViewModel.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/14.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct ArticleCellViewModel {
    
    let title = BehaviorRelay<String?>(value: nil)
    let desc = BehaviorRelay<String?>(value: nil)
    let isNew = BehaviorRelay<Bool>(value: false)
    let time = BehaviorRelay<String?>(value: nil)
    let author = BehaviorRelay<String?>(value: nil)
    let isStick = BehaviorRelay<Bool>(value: false)
    let origin = BehaviorRelay<String?>(value: nil)
    let isCollect = BehaviorRelay<Bool>(value: false)
    
    let collectTap = PublishRelay<Void>()
    
    let disposeBag = DisposeBag()
    
    let article: ArticleModel
    
    init(article: ArticleModel) {
        self.article = article
        title.accept(article.title)
        desc.accept(article.desc)
        isNew.accept(article.fresh)
        time.accept(article.niceDate)
        author.accept(article.displayAuthor)
        isStick.accept(article.isTop)
        origin.accept(article.displayOrigin)
        isCollect.accept(article.collect)
    }
}

extension ArticleCollectionViewCell {
    
    func bind(to viewModel: ArticleCellViewModel) {
        let disposeBag = viewModel.disposeBag
        viewModel.title.asDriver().drive(titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.time.asDriver().drive(timeLabel.rx.text).disposed(by: disposeBag)
        viewModel.author.asDriver().drive(authorLabel.rx.text).disposed(by: disposeBag)
        viewModel.origin.asDriver().drive(originLabel.rx.text).disposed(by: disposeBag)
        viewModel.isCollect.asDriver().drive(collectBtn.rx.isSelected).disposed(by: disposeBag)
        
        collectBtn.rx.tap.bind(to: viewModel.collectTap).disposed(by: disposeBag)
        
        viewModel.desc.asDriver()
            .drive(onNext: { [weak self] desc in
                guard let `self` = self else { return }
                let isHidden = (desc == nil || desc!.isEmpty)
                self.descLabel.isHidden = isHidden
                self.descLabel.yoga.isIncludedInLayout = !isHidden
            })
            .disposed(by: disposeBag)
        
        viewModel.isNew.asDriver()
            .drive(onNext: { [weak self] isNew in
                guard let `self` = self else { return }
                self.newLabel.isHidden = !isNew
                self.newLabel.yoga.isIncludedInLayout = isNew
            })
            .disposed(by: disposeBag)
        
        viewModel.isStick.asDriver()
        .drive(onNext: { [weak self] isStick in
            guard let `self` = self else { return }
            self.stickLabel.isHidden = !isStick
            self.stickLabel.yoga.isIncludedInLayout = isStick
        })
        .disposed(by: disposeBag)
        
        contentView.yoga.markChildrenDirty()
        setNeedsLayout()
    }
}
