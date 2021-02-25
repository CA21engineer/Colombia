//
//  WorksIndexModel.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/25.
//

import Foundation
import RxSwift
import RxCocoa

class WorksIndexModel {
    static let shared = WorksIndexModel()
    let works =  BehaviorRelay<[Work]>(value: [])
    let favoriteWorks = BehaviorRelay<[Work]>(value: [])
    let favoriteValueChanged = PublishRelay<Work>()
}
