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
    
    lazy var refresh = PublishSubject<Void>()
    lazy var loadMore = PublishSubject<Void>()
    
    lazy var templateCells = [String: UICollectionViewCell]()
    
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
        mj_header = MJRefreshNormalHeader { [weak self] in
            self?.refresh.onNext(())
        }
        mj_footer = MJRefreshBackNormalFooter(refreshingBlock: { [weak self] in
            self?.loadMore.onNext(())
        })
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
    
    func dequeueReusableCell<Cell: UICollectionViewCell>(_ type: Cell.Type, for indexPath: IndexPath) -> Cell {
        return dequeueReusableCell(withReuseIdentifier: "\(type)", for: indexPath) as! Cell
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
