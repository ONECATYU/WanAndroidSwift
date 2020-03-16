//
//  HomeViewModel.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/9.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class HomeViewModel: ViewModel, ViewModelType {
    struct Input {
        let refresh: Observable<Void>
        let loadMore: Observable<Void>
        let modelSelected: Driver<ArticleCellViewModel>
    }
    
    struct Output {
        let banners: Observable<[BannerModel]>
        let articles: Observable<[ArticleCellViewModel]>
    }
    
    private var page = 0
    
    private let articles = BehaviorRelay<[ArticleModel]>(value: [])
    private let banners = BehaviorRelay<[BannerModel]>(value: [])
    
    func transform(input: Input) -> Output {
        input.refresh
            .flatMapLatest { [weak self] () -> Observable<([BannerModel], [ArticleModel])> in
                guard let `self` = self else {
                    return Observable.just(([], []))
                }
                self.page = 0
                return Observable
                    .zip(self.fetchBanners(), self.fetchArticles())
                    .trackError(self.error)
                    .trackActivity(self.loading)
        }
        .subscribe(onNext: { [weak self] (banners, articles) in
            guard let `self` = self else { return }
            self.banners.accept(banners)
            self.articles.accept(articles)
        })
            .disposed(by: disposeBag)
        
        input.loadMore
            .flatMapLatest { [weak self] () -> Observable<[ArticleModel]> in
                guard let `self` = self else { return Observable.just([]) }
                self.page += 1
                return self.fetchArticles(page: self.page)
                    .trackError(self.error)
                    .trackActivity(self.loading)
        }
        .subscribe(onNext: { [weak self] articles in
            guard let `self` = self else { return }
            self.articles.accept(self.articles.value + articles)
        })
            .disposed(by: disposeBag)
        
        let articleViewModels = self.articles.map { models in
            return models.map { model -> ArticleCellViewModel in
                let viewModel = ArticleCellViewModel(article: model)
                viewModel.collectTap.flatMapLatest { [weak self] _ -> Observable<Bool> in
                    guard let `self` = self else { return .empty() }
                    return ApiProvider()
                        .rx
                        .request(.collectArticle(model.id))
                        .validateSuccess()
                        .trackActivity(self.loading)
                        .trackError(self.error)
                        .catchErrorJustComplete()
                }
                .subscribe(onNext: {
                    model.collect = $0
                })
                    .disposed(by: viewModel.disposeBag)
                
                return viewModel
            }
        }
        
        return Output(
            banners: banners.asObservable(),
            articles: articleViewModels.asObservable()
        )
    }
    
    func fetchBanners() -> Observable<[BannerModel]> {
        return ApiProvider()
            .rx
            .request(.banner)
            .mapModelList(BannerModel.self, path: "data")
            .catchErrorJustReturn([])
    }
    
    func fetchArticles(page: Int = 1) -> Observable<[ArticleModel]> {
        return ApiProvider()
            .rx
            .request(.articles(page))
            .mapModelList(ArticleModel.self, path: "data.datas")
            .catchErrorJustReturn([])
    }
}
