//
//  ScrollTabBarListController.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/23.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

extension TreeModel: ScrollTabBarData {
    var title: String { return name }
}

class ArticleListViewController: BaseViewController {
    
    lazy var scrollTabBar: ScrollTabBar = {
        let tabBar = ScrollTabBar()
        return tabBar
    }()
    
    lazy var listView: AstaListView = {
        let listView = AstaListView()
        listView.register(ArticleCollectionViewCell.self)
        return listView
    }()
    
    lazy var dataSource = getDataSource()
    
    let viewModel: ArticleListViewModel
    
    init(repos: ArticleListRepos) {
        viewModel = ArticleListViewModel(repos: repos)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViewsLayout()
        
        viewModel.loading.asObservable().bind(to: listView.isLoading).disposed(by: disposeBag)
        viewModel.loading.asObservable().bind(to: showLoading).disposed(by: disposeBag)
        viewModel.error.asObservable().bind(to: showError).disposed(by: disposeBag)
        
        let input = ArticleListViewModel.Input(
            fetchTabsData: Observable.just(()),
            selectedTab: scrollTabBar.didSelectedIndex,
            refresh: listView.refresh,
            loadMore: listView.loadMore
        )
        let output = viewModel.transform(input: input)
        output.tabs.map { $0 }.drive(scrollTabBar.tabs).disposed(by: disposeBag)
        output.articles
        .map { [SectionModel(model: "", items: $0)] }
        .drive(listView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        listView.rx.modelSelected(ArticleCellViewModel.self)
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] model in
                let article = model.article
                let detailVC = ArticleDetailViewController(
                    id: String(article.id),
                    url: article.link!,
                    name: article.title
                )
                self?.navigationController?.pushViewController(detailVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        listView.rx.setDelegate(self).disposed(by: disposeBag)
        
        appTheme.rx
            .bind({ $0.lightBackgroundColor }, to: scrollTabBar.rx.backgroundColor)
            .bind({ $0.textColor }, to: scrollTabBar.rx.textColor)
            .bind({ $0.primaryColor }, to: scrollTabBar.rx.lineColor)
            .disposed(by: disposeBag)
    }
    
    private func configViewsLayout() {
        view.addSubview(scrollTabBar)
        view.addSubview(listView)
        scrollTabBar.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.view.snp.topMargin)
            make.height.equalTo(44)
        }
        listView.snp.makeConstraints { (make) in
            make.top.equalTo(self.scrollTabBar.snp.bottom)
            make.left.right.bottom.equalTo(self.view)
        }
    }
    
    private func getDataSource() -> RxCollectionViewSectionedReloadDataSource<SectionModel<String, ArticleCellViewModel>> {
        return RxCollectionViewSectionedReloadDataSource<SectionModel<String, ArticleCellViewModel>>(configureCell: { (ds, collectionView, indexPath, item) -> UICollectionViewCell in
            let listView = collectionView as! AstaListView
            let cell = listView.dequeueReusableCell(ArticleCollectionViewCell.self, for: indexPath)
            cell.bind(to: item)
            return cell
        })
    }
}

extension ArticleListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 24
        let item = dataSource[indexPath]
        let cell = self.listView.templateCell(ArticleCollectionViewCell.self, for: indexPath)
        cell.bind(to: item)
        return cell.sizeThatFits(CGSize(width: width, height: CGFloat.nan))
    }
}
