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

class HomeViewModel: ViewModel {
    struct Input {
        let refresh: Observable<Void>
        let loadMore: Observable<Void>
    }
    
    struct Output {
        let banners: Observable<[BannerModel]>
        let articles: Observable<[ArticleModel]>
        let completion: Observable<Error?>
    }
    
    private var page = 1
    private var articleArray = [ArticleModel]()
    
    private let disposeBag = DisposeBag()
    
    private let articles = PublishSubject<[ArticleModel]>()
    private let banners = PublishSubject<[BannerModel]>()
    
    func transform(input: Input) -> Output {
        let completion = PublishSubject<Error?>()
        input.refresh
            .flatMapLatest { [weak self] () -> Observable<([BannerModel], [ArticleModel])> in
                guard let `self` = self else {
                    return Observable.just(([], []))
                }
                self.page = 1
                return Observable
                    .zip(self.fetchBanners(), self.fetchArticles())
                    .do(onError: { completion.onNext($0) })
                    .catchErrorJustReturn(([], []))
        }
        .subscribe(onNext: { [weak self] (banners, articles) in
            guard let `self` = self else { return }
            self.articleArray.removeAll()
            self.articleArray = articles
            self.articles.onNext(self.articleArray)
            self.banners.onNext(banners)
            completion.onNext(nil)
        })
            .disposed(by: disposeBag)
        
        input.loadMore
            .flatMapLatest { [weak self] () -> Observable<[ArticleModel]> in
                guard let `self` = self else { return Observable.just([]) }
                self.page += 1
                return self.fetchArticles(page: self.page)
                    .do(onError: { completion.onNext($0) })
                    .catchErrorJustReturn([])
        }
        .subscribe(onNext: { [weak self] articles in
            guard let `self` = self else { return }
            self.articleArray += articles
            self.articles.onNext(self.articleArray)
            completion.onNext(nil)
        })
            .disposed(by: disposeBag)
        
        return Output(
            banners: banners.asObservable(),
            articles: articles.asObservable(),
            completion: completion.asObservable()
        )
    }
    
    func fetchBanners() -> Observable<[BannerModel]> {
        return ApiProvider()
            .rx
            .request(.banner)
            .mapModelList(BannerModel.self, path: "data")
    }
    
    func fetchArticles(page: Int = 1) -> Observable<[ArticleModel]> {
        return ApiProvider()
            .rx
            .request(.articles(page))
            .mapModelList(ArticleModel.self, path: "data.datas")
    }
}
