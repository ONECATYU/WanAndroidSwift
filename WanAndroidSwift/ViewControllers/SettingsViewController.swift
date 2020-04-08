//
//  SettingsViewController.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/4/7.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SettingsViewController: BaseViewController {
    
    struct ListItem {
        let title: String
        var switchState: BehaviorRelay<Bool>?
        var loginOut: PublishRelay<Void>?
        let disposeBag = DisposeBag()
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 44
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "黑暗模式")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "关于我们")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "隐私政策")
        tableView.register(SingleBtnTableViewCell.self, forCellReuseIdentifier: "退出登录")
        return tableView
    }()
    
    private lazy var switchTheme: BehaviorRelay<Bool> = {
        let isDark = appTheme.type == .dark
        return BehaviorRelay<Bool>(value: isDark)
    }()
    private lazy var logout = PublishRelay<Void>()
    
    private let viewModel = SettingsViewModel()
    private lazy var dataSource = getDataSrouce()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        viewModel.loading.asObservable().bind(to: showLoading).disposed(by: disposeBag)
        viewModel.error.asObservable().bind(to: showError).disposed(by: disposeBag)
        
        let input = SettingsViewModel.Input(
            switchTheme: self.switchTheme.asObservable(),
            logout: self.logout.asObservable()
        )
        let output = viewModel.transform(input: input)
        output.logoutSuccess?.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
            .disposed(by: disposeBag)
        
        var items = fetchItems()
        if !AppState.share.loginUser.value.isLogin {
            items.removeLast()
        }
        let sectionModels = items.map {
            SectionModel(model: (), items: $0)
        }
        Driver.just(sectionModels)
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
}

extension SettingsViewController {
    func getDataSrouce() -> RxTableViewSectionedReloadDataSource<SectionModel<Void, ListItem>> {
        return RxTableViewSectionedReloadDataSource<SectionModel<Void, ListItem>>(configureCell: { (ds, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: item.title, for: indexPath)
            cell.contentView.backgroundColor = .clear
            cell.textLabel?.text = item.title
            cell.selectionStyle = .none
            appTheme.rx
                .bind({ $0.lightBackgroundColor }, to: cell.rx.backgroundColor)
                .bind({ $0.textColor }, to: cell.textLabel!.rx.textColor)
                .disposed(by: item.disposeBag)
            
            if let switchTheme = item.switchState, let cell = cell as? SwitchTableViewCell {
                if cell.switch.isOn != switchTheme.value {
                    cell.switch.isOn = switchTheme.value
                }
                cell.switch.rx.isOn.bind(to: switchTheme).disposed(by: item.disposeBag)
            }
            else if let logout = item.loginOut, let cell = cell as? SingleBtnTableViewCell {
                cell.button.rx.tap.bind(to: logout).disposed(by: item.disposeBag)
                cell.button.setTitle(item.title, for: .normal)
                cell.textLabel?.text = nil
                appTheme.rx
                    .bind({ $0.textColor }, to: cell.button.rx.titleColor(for: .normal))
                    .disposed(by: item.disposeBag)
            } else {
                cell.accessoryType = .disclosureIndicator
            }
            
            return cell
        })
    }
    
    func fetchItems() -> [[ListItem]] {
        let setion1 = [
            ListItem(title: "黑暗模式", switchState: self.switchTheme)
        ]
        let setion2 = [
            ListItem(title: "关于我们"),
            ListItem(title: "隐私政策")
        ]
        let setion3 = [
            ListItem(title: "退出登录", loginOut: self.logout)
        ]
        return [setion1, setion2, setion3]
    }
}
