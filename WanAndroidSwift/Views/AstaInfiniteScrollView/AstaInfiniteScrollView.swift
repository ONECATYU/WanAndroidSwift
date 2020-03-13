//
//  InfiniteRollView.swift
//  FreshSwift
//
//  Created by 余汪送 on 2019/8/8.
//  Copyright © 2019 capsule. All rights reserved.
//

import UIKit

@objc protocol AstaInfiniteScrollViewDelegate: NSObjectProtocol {
    func numberOfItems(in infiniteScrollView: AstaInfiniteScrollView) -> Int
    func infiniteScrollView(_ infiniteScrollView: AstaInfiniteScrollView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    
    @objc optional func infiniteScrollView(_ infiniteScrollView: AstaInfiniteScrollView, didSelectedItemAt indexPath: IndexPath)
    @objc optional func infiniteScrollView(_ infiniteScrollView: AstaInfiniteScrollView, didScrollToItemAt indexPath: IndexPath)
}

class AstaInfiniteScrollView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum CellType {
        case `class`(UICollectionViewCell.Type)
        //nibName, bundle
        case nib(String, Bundle?)
    }
    
    enum ScrollPosition {
        case start
        case center
        case end
    }
    
    weak var delegate: AstaInfiniteScrollViewDelegate?
    
    var isInfiniteScrollEnabled: Bool = true
    
    var isAutoScrollEnabled: Bool = true {
        willSet {
            if newValue {
                setupTimer()
            } else {
                invalidateTimer()
            }
        }
    }
    
    var autoScrollTimeInterval: TimeInterval = 2.0 {
        willSet {
            if newValue > 0 {
                setupTimer()
            } else {
                invalidateTimer()
            }
        }
    }
    
    var isPagingEnabled: Bool = true {
        willSet {
            collectionView.decelerationRate = newValue == true ? .fast : .normal
        }
    }
    
    private(set) var currentIndex: Int = 0
    
    var scrollDirection: UICollectionView.ScrollDirection {
        set { flowLayout.scrollDirection = newValue }
        get { return flowLayout.scrollDirection }
    }
    
    var scrollPosition: ScrollPosition = .start
    
    var itemSpacing: CGFloat = 0 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var itemSize: CGSize {
        set { flowLayout.itemSize = newValue }
        get {
            let layoutSize = flowLayout.itemSize
            let containerSize = collectionView.frame.size
            return CGSize(
                width: layoutSize.width > 0 ? layoutSize.width : containerSize.width,
                height: layoutSize.height > 0 ? layoutSize.height : containerSize.height
            )
        }
    }
    
    var padding: UIEdgeInsets = .zero {
        didSet { layoutIfNeeded() }
    }
    
    var showPageControl: Bool = true
    
    let extraItemsMultiple = 10
    
    var canInfiniteScroll: Bool {
        return isInfiniteScrollEnabled && numberOfItems > 1
    }
    
    var canAutoScroll: Bool {
        return isAutoScrollEnabled && numberOfItems > 1 && autoScrollTimeInterval > 0
    }
    
    private(set) lazy var pageControl: AstaPageControl = {
        let pageControl = AstaPageControl()
        return pageControl
    }()
    
    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.isPagingEnabled = false
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
        }() {
        willSet {
            collectionView.collectionViewLayout = newValue
        }
    }
    
    private var numberOfItems: Int {
        set {
            pageControl.numberOfPages = newValue
        }
        get {
            var num = collectionView.numberOfItems(inSection: 0)
            if isInfiniteScrollEnabled {
                num = num / extraItemsMultiple
            }
            return num
        }
    }
    
    private lazy var cellIdentifierSet: Set<String> = []
    
    private var timer: Timer?
    
    private var currentExtraItemIndex = 0 {
        willSet {
            delegate?.infiniteScrollView?(self, didScrollToItemAt: IndexPath(item: newValue, section: 0))
            currentIndex = index(for: newValue)
            pageControl.currentPage = currentIndex
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupSubviewsLayout(withSize: bounds.size)
        if collectionView.contentOffset == .zero {
            scrollToIndex(0)
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if isAutoScrollEnabled && timer == nil {
            setupTimer()
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        invalidateTimer()
    }
    
}

// MARK: setup subviews
extension AstaInfiniteScrollView {
    func setupSubviews() {
        addSubview(collectionView)
        addSubview(pageControl)
    }
    
    func setupSubviewsLayout(withSize containerSize: CGSize) {
        let contentSize = CGSize(
            width: containerSize.width - padding.right - padding.left,
            height: containerSize.height - padding.top - padding.bottom
        )
        collectionView.frame = CGRect(
            x: padding.left,
            y: padding.top,
            width: contentSize.width,
            height: contentSize.height
        )
        let pageControlSize = pageControl.size(forNumberOfPages: numberOfItems)
        pageControl.frame = CGRect(
            x: padding.left,
            y: contentSize.height - pageControlSize.height - padding.bottom - 20,
            width: contentSize.width,
            height: pageControlSize.height
        )
    }
}

//MARK: delegate method
extension AstaInfiniteScrollView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var num = delegate?.numberOfItems(in: self) ?? 0
        numberOfItems = num
        if isInfiniteScrollEnabled {
            num = num * extraItemsMultiple
        }
        return num
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = delegate?.infiniteScrollView(self, cellForItemAt: indexPath) else {
            fatalError()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.infiniteScrollView?(self, didSelectedItemAt: indexPath)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var pagingSize: CGFloat = 0
        var targetOffset: CGFloat = 0
        var targetVelocity: CGFloat = 0
        var containerSize: CGFloat = 0
        if flowLayout.scrollDirection == .horizontal {
            pagingSize = itemSize.width + itemSpacing
            targetOffset = targetContentOffset.pointee.x
            targetVelocity = velocity.x
            containerSize = collectionView.frame.size.width
        } else {
            pagingSize = itemSize.height + itemSpacing
            targetOffset = targetContentOffset.pointee.y
            targetVelocity = velocity.y
            containerSize = collectionView.frame.size.height
        }
        
        var resultIndex: Int = currentExtraItemIndex
        if isPagingEnabled {
            if abs(targetVelocity) >= 0.25 {
                resultIndex = targetVelocity > 0 ? currentExtraItemIndex + 1 : currentExtraItemIndex - 1
            } else  {
                let pageIndex = Int(round(Double(targetOffset / pagingSize)))
                let minusIndex = pageIndex - currentExtraItemIndex
                if minusIndex > 0 {
                    resultIndex = currentExtraItemIndex + 1
                } else if minusIndex < 0 {
                    resultIndex = currentExtraItemIndex - 1
                } else {
                    resultIndex = pageIndex
                }
            }
        } else {
            resultIndex = Int(round(Double(targetOffset / pagingSize)))
        }
        
        let maxIndex = isInfiniteScrollEnabled ? numberOfItems * extraItemsMultiple - 1 : numberOfItems - 1
        resultIndex = max(0, min(maxIndex, resultIndex))
        
        var pointeeOffset = CGFloat(resultIndex) * pagingSize
        if scrollPosition == .center {
            let offset = (containerSize - (pagingSize - itemSpacing)) / 2
            pointeeOffset -= offset
        } else if scrollPosition == .end {
            let offset = containerSize - (pagingSize - itemSpacing)
            pointeeOffset -= offset
        }
        if flowLayout.scrollDirection == .horizontal {
            targetContentOffset.pointee.x = pointeeOffset
        } else {
            targetContentOffset.pointee.y = pointeeOffset
        }
        currentExtraItemIndex = resultIndex
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToIndex(currentIndex)
        if isAutoScrollEnabled {
            setupTimer()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isAutoScrollEnabled {
            invalidateTimer()
        }
    }
}

// MARK: some func
extension AstaInfiniteScrollView {
    
    func scrollTo(index: Int, animated: Bool = false) {
        guard index < numberOfItems else { return }
        if isAutoScrollEnabled {
            invalidateTimer()
        }
        scrollToIndex(index)
        if isAutoScrollEnabled {
            setupTimer()
        }
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func index(for indexPath: IndexPath) -> Int {
        return index(for: indexPath.item)
    }
    
    private func index(for index: Int) -> Int {
        let numberOfItems = self.numberOfItems
        guard canInfiniteScroll else {
            return index
        }
        return index % numberOfItems
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setupTimer() {
        invalidateTimer()
        timer = Timer(
            timeInterval: autoScrollTimeInterval,
            target: self,
            selector: #selector(autoScrollHandler),
            userInfo: nil,
            repeats: true
        )
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func scrollToIndex(_ index: Int, animated: Bool = false) {
        let numberOfItems = self.numberOfItems
        guard index >= 0, index < numberOfItems else {
            return
        }
        let scrollPosition = self.scrollPosition.convertToCollectionViewScrollPosition(scrollDirection: scrollDirection)
        if canInfiniteScroll {
            let midIndex = numberOfItems * extraItemsMultiple / 2
            let minusIndex = index - currentIndex
            let currentItem = midIndex + currentIndex
            let currentIndexPath = IndexPath(item: currentItem, section: 0)
            collectionView.scrollToItem(at: currentIndexPath, at: scrollPosition, animated: false)
            if minusIndex == 0 {
                currentExtraItemIndex = currentItem
            } else {
                let toIndex = currentItem + minusIndex
                let toIndexPath = IndexPath(item: toIndex, section: 0)
                collectionView.scrollToItem(at: toIndexPath, at: scrollPosition, animated: true)
                currentExtraItemIndex = toIndex
            }
        } else {
            let currentIndexPath = IndexPath(item: index, section: 0)
            collectionView.scrollToItem(at: currentIndexPath, at: scrollPosition, animated: true)
            currentExtraItemIndex = index
        }
    }
    
    @objc private func autoScrollHandler() {
        guard canAutoScroll else { return }
        let scrollPosition = self.scrollPosition.convertToCollectionViewScrollPosition(scrollDirection: scrollDirection)
        var toIndex = currentIndex + 1
        if isInfiniteScrollEnabled {
            if toIndex > numberOfItems - 1 {
                let numberOfItems = self.numberOfItems
                let midItemIndex = numberOfItems * extraItemsMultiple / 2
                let toItemIndex = midItemIndex + currentIndex + 1
                let toItemIndexPath = IndexPath(item: toItemIndex, section: 0)
                collectionView.scrollToItem(at: toItemIndexPath, at: scrollPosition, animated: true)
                currentExtraItemIndex = toItemIndex
                return
            }
            scrollToIndex(toIndex, animated: true)
        } else {
            if toIndex > numberOfItems - 1 {
                toIndex = 0
            }
            let toIndexPath = IndexPath(item: toIndex, section: 0)
            collectionView.scrollToItem(at: toIndexPath, at: scrollPosition, animated: true)
            currentExtraItemIndex = toIndex
        }
    }
}


// MARK: dequeueReusableCell
extension AstaInfiniteScrollView {
    
    func dequeueReusableCell(withType cellType: CellType, for indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = registerCellIfNeed(cellType: cellType)
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
    }
    
    private func registerCellIfNeed(cellType: CellType) -> String {
        let cellIdentifier = cellType.identifier
        if !cellIdentifierSet.contains(cellIdentifier) {
            cellIdentifierSet.insert(cellIdentifier)
            switch cellType {
            case let .class(cellClass):
                collectionView.register(cellClass, forCellWithReuseIdentifier: cellIdentifier)
            case let .nib(nibName, bundle):
                let nib = UINib(nibName: nibName, bundle: bundle)
                collectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
            }
        }
        return cellIdentifier
    }
}

extension AstaInfiniteScrollView.CellType {
    var identifier: String {
        switch self {
        case let .class(type):
            return String(describing: type)
        case let .nib(nibName, bundle):
            var identifier = nibName
            if let bundleIdentifier = bundle?.bundleIdentifier {
                identifier += bundleIdentifier
            }
            return identifier
        }
    }
}

extension AstaInfiniteScrollView.ScrollPosition {
    func convertToCollectionViewScrollPosition(scrollDirection: UICollectionView.ScrollDirection = .horizontal) -> UICollectionView.ScrollPosition {
        switch self {
        case .start:
            return scrollDirection == .horizontal ? .left : .top
        case .center:
            return scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
        case .end:
            return scrollDirection == .horizontal ? .right : .bottom
        }
    }
}
