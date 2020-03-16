//
//  TreeViewModel.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/13.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TreeViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let selectedIndex: Observable<Int>
        let refresh: Observable<Void>
    }
    
    struct Output {
        let treeItems: Driver<TreeItem>
    }
    
    enum TreeItem {
        case tree([TreeModel])
        case navigate([NavigateModel])
    }
    
    func transform(input: Input) -> Output {
        
        let reqTree = ApiProvider()
            .rx
            .request(.tree)
            .mapModelList(TreeModel.self, path: "data")
            .map { TreeItem.tree($0) }
            .trackActivity(self.loading)
            .trackErrorJustReturn(self.error, value: .navigate([]))
        
        let reqNav = ApiProvider()
            .rx
            .request(.nav)
            .mapModelList(NavigateModel.self, path: "data")
            .map { TreeItem.navigate($0) }
            .trackActivity(self.loading)
            .trackErrorJustReturn(self.error, value: .tree([]))
        
        let item = Observable
            .combineLatest(input.selectedIndex, input.refresh)
            .map { $0.0 }
            .filter { $0 >= 0 && $0 < 2 }
            .flatMapLatest { index -> Observable<TreeItem> in
                if index == 0 { return reqTree }
                return reqNav
        }
        
        return Output(
            treeItems: item.asDriverOnErrorJustComplete()
        )
    }
}
