//
//  HomeViewController.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/9.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PublicPlatRepos: ArticleListRepos {
    func fetchTabs() -> Observable<[TreeModel]> {
        return CategorysAPI.provider.rx.request(.publicPlat).mapModelList(TreeModel.self, path: "data")
    }
    
    func fetchArticles(by id: String, at page: Int) -> Observable<[ArticleModel]> {
        return ArticlesAPI.provider.rx.request(.publicPlat(id, page)).mapModelList(ArticleModel.self, path: "data.datas")
    }    
}

class PublicPlatViewController: ArticleListViewController {
    init() {
        super.init(repos: PublicPlatRepos())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
