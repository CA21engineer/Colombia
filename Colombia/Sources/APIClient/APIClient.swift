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
                if let error = error {
                    observer.onError(APIError.unknown(error))
                }
                guard let resultData = resultData, response != nil else {
                    observer.onError(APIError.response)
                    return
                }
                do {
                    let decodeData = try decoder.decode(T.Response.self, from: resultData)
                    observer.onNext(decodeData)
                } catch let error {
                    observer.onError(APIError.decode(error))
                }
            }
            task.resume()
            return Disposables.create()
        }
    }
}

enum APIError: Error {
    case decode(Error)
    case response
    case unknown(Error)
}
