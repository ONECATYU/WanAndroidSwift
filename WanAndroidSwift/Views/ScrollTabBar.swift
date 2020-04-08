//
//  ScrollTabBar.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/21.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol ScrollTabBarData {
    var title: String { get }
}

class ScrollTabBar: UIView {

    let tabs: PublishSubject<[ScrollTabBarData]> = PublishSubject()
    
    let didSelectedIndex: PublishSubject<Int> = PublishSubject()
    
    let didSelectedTab: PublishSubject<ScrollTabBarData> = PublishSubject()
    
    var textColor: UIColor = .black {
        willSet { collectionView.reloadData() }
    }
    
    var lineColor: UIColor = .blue {
        willSet { bottomLine.backgroundColor = newValue }
    }
    
    var textHorizontalPadding: CGFloat = 10
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 2, left: 12, bottom: 3, right: 12)
        let ctlView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        ctlView.backgroundColor = .clear
        ctlView.showsVerticalScrollIndicator = false
        ctlView.showsHorizontalScrollIndicator = false
        ctlView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseID)
        return ctlView
    }()
    
    private lazy var bottomLine: UIView = UIView()
    
    private lazy var dataSource = getDataSource()
    
    private let disposeBag = DisposeBag()
    
    private var _selectedIndex: Int = 0
    
    init() {
        super.init(frame: .zero)
        addSubview(collectionView)
        bottomLine.backgroundColor = .black
        collectionView.addSubview(bottomLine)
        
        tabs.map { [TabSectionModel(model: "", items: $0)] }
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tabs.delay(.milliseconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.updateBottomLinePosition(index: self._selectedIndex, animate: false)
            })
            .disposed(by: disposeBag)
        
        didSelectedIndex
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let `self` = self else { return }
                if self._selectedIndex != index || self.bottomLine.frame == .zero {
                    self.updateBottomLinePosition(index: index)
                    self._selectedIndex = index
                }
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .map { $0.item }
            .bind(to: didSelectedIndex)
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(ScrollTabBarData.self)
            .bind(to: didSelectedTab)
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = self.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// open
extension ScrollTabBar {
    func tabData(at index: Int) -> ScrollTabBarData {
        let indexPath = IndexPath(item: index, section: 0)
        return dataSource[indexPath]
    }
}

/// private
extension ScrollTabBar {
    
    private class Cell: UICollectionViewCell {
        class var reuseID: String { return "ScrollTabBar.item" }
        
        lazy var textLabel: UILabel = {
            let label = UILabel()
            label.font = .title
            label.textAlignment = .center
            self.contentView.addSubview(label)
            return label
        }()
        
        override func layoutSubviews() {
            super.layoutSubviews()
            textLabel.frame = contentView.bounds
        }
    }
    
    typealias TabSectionModel = SectionModel<String, ScrollTabBarData>
    
    private func getDataSource() -> RxCollectionViewSectionedReloadDataSource<TabSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<TabSectionModel>(configureCell: { [weak self] (ds, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseID, for: indexPath) as! Cell
            cell.textLabel.text = item.title
            cell.textLabel.textColor = self?.textColor
            return cell
        })
    }
    
    @discardableResult
    private func updateBottomLinePosition(index: Int, animate: Bool = true) -> Bool {
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? Cell else {
            return false
        }
        let updateBottomLineFrame = {
            self.bottomLine.frame = CGRect(
                x: cell.frame.minX,
                y: cell.frame.maxY,
                width: cell.frame.width,
                height: self.bottomLineHeight
            )
            self.collectionView.scrollToItem(
                at: indexPath,
                at: .centeredHorizontally,
                animated: false
            )
        }
        if !animate {
            updateBottomLineFrame()
        } else {
            UIView.animate(withDuration: 0.2) {
                UIView.setAnimationCurve(.easeInOut)
                updateBottomLineFrame()
            }
        }
        return true
    }
    
    private var bottomLineHeight: CGFloat {
        return 2
    }
}

extension ScrollTabBar: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = dataSource[indexPath]
        let size = (data.title as NSString).boundingRect(with: collectionView.frame.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.title], context: nil).size
        return CGSize(width: size.width + textHorizontalPadding * 2, height: collectionView.frame.height - 5)
    }
}

extension Reactive where Base: ScrollTabBar {
    var textColor: Binder<UIColor> {
        return Binder<UIColor>(self.base) { (bar, color) in
            bar.textColor = color
        }
    }
    
    var lineColor: Binder<UIColor> {
        return Binder<UIColor>(self.base) { (bar, color) in
            bar.lineColor = color
        }
    }
}
