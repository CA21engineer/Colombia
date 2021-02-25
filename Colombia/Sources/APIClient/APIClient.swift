//
//  APIClient.swift
//  Colombia
//
//  Created by 山根大生 on 2021/02/19.
//

import Foundation
import RxSwift

struct APIClient {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    func request<T: Requestable>(_ requestable: T) -> Observable<T.Response> {
        Observable<T.Response>.create { observer in
            let url = requestable.url
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { resultData, response, error in
                guard let resultData = resultData else {
                    if let error = error {
                        observer.onError(error)
                    }
                    return
                }
                do {
                    let decodeData = try decoder.decode(T.Response.self, from: resultData)
                    observer.onNext(decodeData)
                } catch let error {
                    observer.onError(error)
                }
            }
            task.resume()
            return Disposables.create()
        }
    }
}
