//
//  BannerCollectionViewCell.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/12.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit
import Kingfisher

class ImageCollectionViewCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        contentView.addSubview(view)
        return view
    }()
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
}

class BannerCollectionViewCell: UICollectionViewCell {
    
    lazy var infiniteScrollView: AstaSimpleInfiniteView = {
        let view = AstaSimpleInfiniteView(frame: .zero, cellType: .class(ImageCollectionViewCell.self))
        view.renderItem { (index, url, cell) in
            guard let imgUrl = url as? String else {
                    fatalError()
            }
            let imgCell = cell as! ImageCollectionViewCell
            imgCell.imageView.kf.setImage(with: URL(string: imgUrl))
        }
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(infiniteScrollView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infiniteScrollView.frame = contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension BannerCollectionViewCell {
    func bind(model: [BannerModel]) {
        infiniteScrollView.dataModels = model.map { $0.imagePath ?? "" }
    }
}
