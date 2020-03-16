//
//  AstaListView.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/12.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit
import MJRefresh
import WSCollectionViewFlowLayout
import RxSwift
import RxCocoa

class AstaListView: UICollectionView {
    
    lazy var refresh: BehaviorSubject<Void> = {
        let subject = BehaviorSubject<Void>(value: ())
        mj_header = MJRefreshNormalHeader {
            subject.onNext(())
        }
        return subject
    }()
    
    lazy var loadMore: PublishSubject<Void> = {
        let subject = PublishSubject<Void>()
        mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            subject.onNext(())
        })
        return subject
    }()
    
    lazy var isLoading: PublishSubject<Bool> = {
        let isLoading = PublishSubject<Bool>()
        isLoading.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] loading in
            if !loading {
                self?.mj_header?.endRefreshing()
                self?.mj_footer?.endRefreshing()
            }
        }).disposed(by: disposeBag)
        return isLoading
    }()
    
    private let disposeBag = DisposeBag()
    private lazy var templateCells = [String: UICollectionViewCell]()
    
    var layout: WSCollectionViewFlowLayout = {
        let layout = WSCollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        layout.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 0, right: 12)
        return layout
    }()
    
    init() {
        super.init(frame: .zero, collectionViewLayout: layout)
        backgroundColor = .clear
    }
    
    func templateCell<Cell: UICollectionViewCell>(_ type: Cell.Type, for indexPath: IndexPath) -> Cell {
        let identifier = "\(type)"
        if let cell = templateCells[identifier] {
            return cell as! Cell
        }
        let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! Cell
        templateCells[identifier] = cell
        return cell
    }
    
    func register<Cell: UICollectionViewCell>(_ type: Cell.Type) {
        register(type, forCellWithReuseIdentifier: "\(type)")
    }
    
    func register<View: UICollectionReusableView>(_ type: View.Type, elementKind: String) {
        register(type, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: "\(type)")
    }
    
    func dequeueReusableCell<Cell: UICollectionViewCell>(_ type: Cell.Type, for indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: "\(type)", for: indexPath) as? Cell else {
            fatalError("\(type): unregistered")
        }
        return cell
    }
    
    func dequeueReusableView<View: UICollectionReusableView>(
        ofKind elementKind: String,
        withType type: View.Type,
        for indexPath: IndexPath
    ) -> View {
        guard let view = dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: "\(type)", for: indexPath) as? View else {
            fatalError("\(type), kind: \(elementKind): unregistered")
        }
        return view
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
