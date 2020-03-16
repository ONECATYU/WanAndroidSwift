//
//  ViewModel.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/9.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
        
    func transform(input: Input) -> Output
}

class ViewModel {
    
    let disposeBag = DisposeBag()
    
    lazy var loading = ActivityIndicator()
    lazy var error = ErrorTracker()
}
