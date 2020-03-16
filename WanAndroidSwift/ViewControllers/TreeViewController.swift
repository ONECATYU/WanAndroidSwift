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

class TreeViewController: BaseViewController {
    
    enum TreeItem {
        case tree([TreeModel])
        case navigate([NavigateModel])
    }
    
    lazy var segmentedControl: UISegmentedControl = {
        let ctl = UISegmentedControl(items: ["体系", "导航"])
        ctl.setWidth(80, forSegmentAt: 0)
        ctl.setWidth(80, forSegmentAt: 1)
        ctl.selectedSegmentIndex = 0
        return ctl
    }()
    
    lazy var listView: AstaListView = {
        let listView = AstaListView()
        listView.layout.minimumInteritemSpacing = 12
        listView.layout.headerReferenceSize = CGSize(
            width: UIScreen.main.bounds.width - 24,
            height: 44
        )
        listView.register(TextCollectionViewCell.self)
        listView.register(TextCollectionReuseableView.self, elementKind: UICollectionView.elementKindSectionHeader)
        return listView
    }()
    
    let viewModel = TreeViewModel()
    
    lazy var dataSource = getDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
        
        viewModel.loading.asObservable().bind(to: listView.isLoading).disposed(by: disposeBag)
        viewModel.loading.asObservable().bind(to: showLoading).disposed(by: disposeBag)
        viewModel.error.asObservable().bind(to: showError).disposed(by: disposeBag)
        
        let input = TreeViewModel.Input(
            selectedIndex: segmentedControl.rx.value.asObservable(),
            refresh: listView.refresh
        )
        let output = viewModel.transform(input: input)
        output.treeItems.map { item -> [SectionModel<String, Any>] in
            switch item {
            case .tree(let items):
                return items.map { SectionModel(model: $0.name, items: $0.children) }
            case .navigate(let items):
                return items.map { SectionModel(model: $0.name, items: $0.articles) }
            }
        }
        .drive(listView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)

        listView.rx.setDelegate(self).disposed(by: disposeBag)
        
    }
    
    func configViews() {
        navigationItem.titleView = segmentedControl
        view.addSubview(listView)
        listView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
}

extension TreeViewController {
    
    func getDataSource() -> RxCollectionViewSectionedReloadDataSource<SectionModel<String, Any>> {
        return RxCollectionViewSectionedReloadDataSource<SectionModel<String, Any>>(
            configureCell: { (ds, collectionView, indexPath, item) in
                let listView = collectionView as! AstaListView
                let cell = listView.dequeueReusableCell(TextCollectionViewCell.self, for: indexPath)
                if let tree = item as? TreeModel {
                    cell.textLabel.text = tree.name
                } else if let article = item as? ArticleModel {
                    cell.textLabel.text = article.title
                }
                return cell
        },
            configureSupplementaryView: { (ds, collectionView, kind, indexPath) -> UICollectionReusableView in
                let sectionModel = ds[indexPath.section]
                let listView = collectionView as! AstaListView
                let view = listView.dequeueReusableView(ofKind: kind, withType: TextCollectionReuseableView.self, for: indexPath)
                view.textLabel.text = sectionModel.model
                return view
        })
    }
}


extension TreeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataSource[indexPath]
        let cell = listView.templateCell(TextCollectionViewCell.self, for: indexPath)
        if let tree = item as? TreeModel {
            cell.textLabel.text = tree.name
        } else if let article = item as? ArticleModel {
            cell.textLabel.text = article.title
        }
        let size = cell.sizeThatFits(listView.frame.size)
        return size
    }
}
