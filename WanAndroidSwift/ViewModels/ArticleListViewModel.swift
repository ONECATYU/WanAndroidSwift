//
//  PublicPlatViewModel.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/24.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ArticleListRepos {
    func fetchTabs() -> Observable<[TreeModel]>
    func fetchArticles(by id: String, at page: Int) -> Observable<[ArticleModel]>
}

class ArticleListViewModel: ViewModel, ViewModelType {
    struct Input {
        let fetchTabsData: Observable<Void>
        let selectedTab: PublishSubject<Int>
        let refresh: Observable<Void>
        let loadMore: Observable<Void>
    }
    
    struct Output {
        let tabs: Driver<[TreeModel]>
        let articles: Driver<[ArticleCellViewModel]>
    }
    
    let repos: ArticleListRepos
    
    private let tabs: BehaviorRelay<[TreeModel]> = BehaviorRelay(value: [])
    
    private var page: Int = 0
    
    init(repos: ArticleListRepos) {
        self.repos = repos
    }
    
    func transform(input: Input) -> Output {
        
        input.fetchTabsData
            .flatMapLatest {[weak self] (_) -> Observable<[TreeModel]> in
                guard let `self` = self else { return Observable.just([]) }
                return self.repos.fetchTabs()
                    .trackErrorJustReturn(self.error, value: [])
                    .trackActivity(self.loading)
        }
        .subscribe(onNext: { [weak self] trees in
            guard let `self` = self else { return }
            self.tabs.accept(trees)
            input.selectedTab.onNext(0)
        })
            .disposed(by: disposeBag)
        
        let articles: BehaviorRelay<[ArticleCellViewModel]> = BehaviorRelay(value: [])
        
        Observable
            .combineLatest(input.refresh, input.selectedTab)
            .flatMapLatest({ [weak self] (_, index) -> Observable<[ArticleCellViewModel]> in
                guard let `self` = self else { return Observable.just([]) }
                self.page = 0
                return self.fetchArticles(index: index)
            })
            .subscribe(onNext: { models in
                articles.accept(models)
            })
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(input.loadMore, input.selectedTab)
            .flatMapLatest({ [weak self] (_, index) -> Observable<[ArticleCellViewModel]> in
                guard let `self` = self else { return Observable.just([]) }
                self.page += 1
                return self.fetchArticles(index: index, page: self.page)
            })
            .subscribe(onNext: { models in
                articles.accept(articles.value + models)
            })
            .disposed(by: disposeBag)
        
        return Output(
            tabs: tabs.asDriver(),
            articles: articles.asDriver()
        )
    }
    
    func fetchArticles(index: Int, page: Int = 0) -> Observable<[ArticleCellViewModel]> {
        if index >= tabs.value.count { return Observable.just([]) }
        let tree = tabs.value[index]
        if let id = tree.id {
            return repos.fetchArticles(by: String(id), at: page)
                .map { $0.map { ArticleCellViewModel(article: $0) } }
                .trackErrorJustReturn(error, value: [])
                .trackActivity(loading)
        }
        return Observable.just([])
    }
}
