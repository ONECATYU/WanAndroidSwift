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

class MineViewController: BaseViewController {
    
    struct ListItem {
        let icon: Iconfont
        let title: String
        let iconColor: UIColor?
        let vcProvider: () -> UIViewController
        init(title: String,
             iconFont: Iconfont,
             viewController: @escaping @autoclosure () -> UIViewController,
             iconColor: UIColor? = nil
        ) {
            self.icon = iconFont
            self.title = title
            self.iconColor = iconColor
            self.vcProvider = viewController
        }
    }
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    var headView: MineHeadView = {
        let frame = CGRect(
            origin: .zero,
            size: CGSize(width: UIScreen.main.bounds.width, height: 200)
        )
        let view = MineHeadView(frame: frame)
        return view
    }()
    
    lazy var dataSource = getDataSource()
    
    private var currentTheme: Theme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarHidden = true
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.bottom.centerX.equalTo(self.view)
            make.width.equalTo(self.view).offset(-24)
        }
        tableView.tableHeaderView = headView
        
        AppState.share.loginUser.bind(to: headView.bindUser).disposed(by: disposeBag)
        headView.userNameBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self, !AppState.share.loginUser.value.isLogin else { return }
            LoginViewController.show(from: self)
        })
            .disposed(by: disposeBag)
        
        Observable.just(fetchData())
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ListItem.self).subscribe(onNext: { [weak self] item in
            let toVC = item.vcProvider()
            toVC.hidesBottomBarWhenPushed = true
            toVC.title = item.title
            self?.navigationController?.pushViewController(toVC, animated: true)
        })
            .disposed(by: disposeBag)
        
        appTheme.attrsStream.subscribe(onNext: { [weak self] theme in
            self?.currentTheme = theme
            self?.tableView.reloadData()
        })
            .disposed(by: disposeBag)
    }
}

/// private
extension MineViewController {
    func getDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<Void, ListItem>> {
        return RxTableViewSectionedReloadDataSource<SectionModel<Void, ListItem>>(configureCell: { [weak self] (ds, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.selectionStyle = .none
            let theme = self?.currentTheme
            cell.imageView?.image = item.icon.image(size: 20, color: (item.iconColor ?? theme?.primaryColor) ?? .blue)
            cell.textLabel?.text = item.title
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = theme?.lightBackgroundColor
            cell.textLabel?.textColor = theme?.textColor
            return cell
        })
    }
    
    func fetchData() -> [SectionModel<Void, ListItem>] {
        let section1Items = [
            ListItem(
                title: "我的积分",
                iconFont: .integral,
                viewController: MyIntegralViewController()
            ),
            ListItem(
                title: "我的分享",
                iconFont: .share,
                viewController: MyShareViewController()
            ),
            ListItem(
                title: "我的收藏",
                iconFont: .heart,
                viewController: MyCollectionViewController(),
                iconColor: .red
            )
        ]
        let section2Items = [
            ListItem(
                title: "设置",
                iconFont: .setting,
                viewController: SettingsViewController()
            )
        ]
        
        let sectionModels = [section1Items, section2Items].map {
            SectionModel(model: (), items: $0)
        }
        return sectionModels
    }
}
