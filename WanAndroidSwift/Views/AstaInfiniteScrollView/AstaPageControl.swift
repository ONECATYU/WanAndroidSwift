//
//  InfinitePageControl.swift
//  FreshSwift
//
//  Created by 余汪送 on 2019/8/8.
//  Copyright © 2019 capsule. All rights reserved.
//

import UIKit

class AstaPageControl: UIView {
    
    enum Style {
        case dot, line
    }
    
    var style: Style = .dot
    
    var numberOfPages: Int = 0 {
        willSet {
            setNeedsLayout()
        }
    }
    
    var currentPage: Int = 0 {
        willSet {
            setNeedsLayout()
        }
    }
    
    var hidesForSinglePage: Bool = false
    
    var pageIndicatorTintColor: UIColor = .white
    
    var currentPageIndicatorTintColor: UIColor = .lightGray
    
    var indicatorSpacing: CGFloat = 5.0
    
    var dotDiameter: CGFloat = 6.0
    
    var lineSize = CGSize(width: 10.0, height: 2.0)
    
    private lazy var containerLayer: CALayer = {
        let layer = CALayer()
        self.layer.addSublayer(layer)
        return layer
    }()
    
    private lazy var currentIndicatorLayer: CALayer = {
        let layer = CALayer()
        layer.zPosition = 1
        return layer
    }()
    
    private var indicatorLayers: [CALayer] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resetIndicatorLayers(inSize: bounds.size)
        updateCurrentIndicatorLayer(for: currentPage)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.size(forNumberOfPages: numberOfPages)
    }
    
    override var intrinsicContentSize: CGSize {
        return size(forNumberOfPages: numberOfPages)
    }
    
    func size(forNumberOfPages pageCount: Int) -> CGSize {
        if numberOfPages <= 0 { return .zero }
        switch style {
        case .dot:
            let width = (dotDiameter + indicatorSpacing) * CGFloat(pageCount) - indicatorSpacing
            return CGSize(width: width, height: dotDiameter)
        case .line:
            let width = (lineSize.width + indicatorSpacing) * CGFloat(pageCount) - indicatorSpacing
            return CGSize(width: width, height: lineSize.height)
        }
    }
}

extension AstaPageControl {
    
    @discardableResult
    private func indicatorLayer(for index: Int) -> CALayer {
        if index < indicatorLayers.count {
            let layer = indicatorLayers[index]
            return layer
        }
        let layer = CALayer()
        indicatorLayers.append(layer)
        return layer
    }
    
    private func resetIndicatorLayers(inSize containerSize: CGSize) {
        if let subLayers = containerLayer.sublayers {
            for subLayer in subLayers {
                subLayer.removeFromSuperlayer()
            }
        }
        if numberOfPages <= 0 || (hidesForSinglePage && numberOfPages == 1) { return }
        containerLayer.addSublayer(currentIndicatorLayer)
        let size = self.size(forNumberOfPages: numberOfPages)
        let x = (containerSize.width - size.width) / 2
        let y = (containerSize.height - size.height) / 2
        containerLayer.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        for index in 0..<numberOfPages {
            let layer = indicatorLayer(for: index)
            containerLayer.addSublayer(layer)
            switch style {
            case .dot:
                let layerX = CGFloat(index) * (dotDiameter + indicatorSpacing)
                layer.frame = CGRect(x: layerX, y: 0, width: dotDiameter, height: dotDiameter)
                layer.cornerRadius = dotDiameter / 2
            case .line:
                let layerX = CGFloat(index) * (lineSize.width + indicatorSpacing)
                layer.frame = CGRect(x: layerX, y: 0, width: lineSize.width, height: lineSize.height)
                layer.cornerRadius = 0
            }
            layer.backgroundColor = pageIndicatorTintColor.cgColor
        }
    }
    
    private func updateCurrentIndicatorLayer(for index: Int) {
        guard numberOfPages > 0, index < numberOfPages, index < indicatorLayers.count else {
            return
        }
        let layer = indicatorLayers[index]
        currentIndicatorLayer.frame = layer.frame
        currentIndicatorLayer.cornerRadius = layer.cornerRadius
        currentIndicatorLayer.backgroundColor = currentPageIndicatorTintColor.cgColor
    }
}
