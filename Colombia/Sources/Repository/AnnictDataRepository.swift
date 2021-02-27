//
//  AnnictDataRepository.swift
//  Colombia
//
//  Created by 山根大生 on 2021/02/19.
//

import Foundation
import RxSwift

protocol Repository {
    associatedtype Response
    var apiClient: APIClient { get }
    func fetch() -> Observable<Response>
    
}

struct AnnictDataRepository: Repository {
    
    let apiClient = APIClient()
    
    typealias Response = AnnictAPIModel
    
    func fetch() -> Observable<AnnictAPIModel> {
        let request = AnnictAPIRequest(endpoint: .works)
        return apiClient.request(request)
    }
}
