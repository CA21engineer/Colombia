//
//  WorksIndexModel.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/25.
//

import RxSwift
import RxRelay

//型名に省略形の命名はしない
enum CallingViewController {
    case index
    case favorite
}

struct WorkForDisplay {
    let id: Int
    let title: String
    let image: Image
    var isFavorited: Bool
}

final class WorksIndexModel {
    static let shared = WorksIndexModel()
    
    //UI用に準備している変数
    
    //一覧画面表示用の作品
    let works = BehaviorRelay<[WorkForDisplay]>(value: [])
    
    //お気に入りに登録している作品すべて
    let favoriteWorks = BehaviorRelay<[WorkForDisplay]>(value: [])
    
    //お気に入りの状態が変わりました
    let favoriteValueChanged = PublishRelay<(WorkForDisplay,CallingViewController)>()
    
    // 作品IDがお気に入りに含まれているか
    func isIncludingInFavorite(workId: Int) -> Bool {
        return favoriteWorks.value.contains{ $0.id == workId }
    }
}
