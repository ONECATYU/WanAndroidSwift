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
import RxDataSources
import SnapKit
import Moya
import HandyJSON
import MJRefresh

class HomeViewController: BaseViewController {
    
    typealias HomeSectionModel = SectionModel<String, Any>
    
    lazy var listView: AstaListView = {
        let listView = AstaListView()
        listView.register(ArticleCollectionViewCell.self)
        listView.register(BannerCollectionViewCell.self)
        return listView
    }()
    
    let viewModel = HomeViewModel()
    
    lazy var dataSource = getDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
        
        viewModel.loading.asObservable().bind(to: listView.isLoading).disposed(by: disposeBag)
        viewModel.loading.asObservable().bind(to: showLoading).disposed(by: disposeBag)
        viewModel.error.asObservable().bind(to: showError).disposed(by: disposeBag)
        
        let input = HomeViewModel.Input(
            refresh: listView.refresh,
            loadMore: listView.loadMore,
            modelSelected: listView.rx.modelSelected(ArticleCellViewModel.self).asDriver()
        )
        let output = viewModel.transform(input: input)
        
        Observable.combineLatest(output.banners, output.articles)
            .map { (tup) -> [HomeSectionModel] in
                return [
                    HomeSectionModel(model: "banner", items: [tup.0]),
                    HomeSectionModel(model: "article", items: tup.1)
                ]
        }
        .asDriver(onErrorJustReturn: [])
        .drive(listView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        listView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func configViews() {
        view.addSubview(listView)
        listView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        let searchBar = SearchBar(style: .click)
        searchBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 12, height: 36)
        searchBar.placeholder = "搜索"
        self.navigationItem.titleView = searchBar
        appTheme.rx
            .bind({ $0.backgroundColor }, to: searchBar.rx.backgroundColor)
            .bind({ $0.textColor }, to: searchBar.rx.tintColor)
    }
    
}

extension HomeViewController {
    private func getDataSource() -> RxCollectionViewSectionedReloadDataSource<HomeSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<HomeSectionModel>(configureCell: { (ds, collectionView, indexPath, item) in
            let listView = collectionView as! AstaListView
            switch item {
            case is [BannerModel]:
                let cell = listView.dequeueReusableCell(BannerCollectionViewCell.self, for: indexPath)
                cell.bind(model: item as! [BannerModel])
                return cell
            case is ArticleCellViewModel:
                let cell = listView.dequeueReusableCell(ArticleCollectionViewCell.self, for: indexPath)
                cell.bind(to: item as! ArticleCellViewModel)
                return cell
            default:
                fatalError()
            }
        })
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 24
        let item = dataSource[indexPath]
        switch item {
        case is [BannerModel]:
            return CGSize(width: width, height: 200)
        case is ArticleCellViewModel:
            let cell = self.listView.templateCell(ArticleCollectionViewCell.self, for: indexPath)
            cell.bind(to: item as! ArticleCellViewModel)
            return cell.sizeThatFits(CGSize(width: width, height: CGFloat.nan))
        default:
            fatalError()
        }
    }
}
