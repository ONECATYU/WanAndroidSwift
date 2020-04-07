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
        init(title: String, iconFont: Iconfont, iconColor: UIColor? = nil) {
            self.icon = iconFont
            self.title = title
            self.iconColor = iconColor
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
    
    private lazy var currentTheme: BehaviorRelay<Theme> = {
        let currentTheme = BehaviorRelay<Theme>(value: appTheme.type.associatedObject)
        currentTheme.subscribe(onNext: { [weak self] theme in
            self?.tableView.reloadData()
        })
            .disposed(by: self.disposeBag)
        return currentTheme
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
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
        
        appTheme.typeStream
            .map { $0.associatedObject }
            .bind(to: currentTheme)
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

/// private
extension MineViewController {
    func getDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<Void, ListItem>> {
        return RxTableViewSectionedReloadDataSource<SectionModel<Void, ListItem>>(configureCell: { [weak self] (ds, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let theme = self?.currentTheme.value
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
            ListItem(title: "我的积分", iconFont: .integral),
            ListItem(title: "我的分享", iconFont: .share),
            ListItem(title: "我的收藏", iconFont: .heart, iconColor: .red)
        ]
        let section2Items = [
            ListItem(title: "设置", iconFont: .setting)
        ]
        
        let sectionModels = [section1Items, section2Items].map {
            SectionModel(model: (), items: $0)
        }
        return sectionModels
    }
}
