//
//  WorksIndexModel.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/25.
//

import RxSwift
import RxRelay

enum CallingVC {
    case index
    case favorite
}

final class WorksIndexModel {
    static let shared = WorksIndexModel()
    
    //UI用に準備している変数
    
    //一覧画面表示用の作品
    let works =  BehaviorRelay<[Work]>(value: [])
    
    //お気に入りに登録している作品すべて
    let favoriteWorks = BehaviorRelay<[Work]>(value: [])
    
    //お気に入りの状態が変わりました
    let favoriteValueChanged = PublishRelay<(Work,CallingVC)>()
}
