//
//  AnnictAPIRequest.swift
//  Colombia
//
//  Created by 山根大生 on 2021/02/16.
//

import Foundation

enum AccessToken {
    static var annictAPI: String {
        guard let filePath = Bundle.main.path(forResource: "AccessToken", ofType: "plist") else {
            fatalError("Couldn't find file 'AccessToken.plist'")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "AnnictAPIAccessToken") as? String else {
            fatalError("Couldn't find key 'AnnictAPIAccessToken' in 'AccessToken.plist'")
        }
        return value
    }
}

enum Endpoint {
    //とりあえずworksだけ実装
    case works
    
    func endpoint() -> String {
        switch self {
        case .works:
            return "/v1/works"
        }
    }
}

struct AnnictAPIRequest:Requestable {
    
    typealias Response = AnnictWorksModel
    
    private let endpoint: Endpoint
    
    var url: URL {
        var baseURL = URLComponents(string: "https://api.annict.com")!
        baseURL.path = endpoint.endpoint()
        
        switch endpoint {
        case .works:
            baseURL.queryItems = [
                //1ページあたりのデータの数、とりあえず20を指定
                URLQueryItem(name: "per_page", value: "20"),
                //とりあえずid,title,recommended_urlのみを受け取る
                URLQueryItem(name: "fields", value: "id,title,images.recommended_url"),
                URLQueryItem(name: "access_token", value: AccessToken.annictAPI)
            ]
        }
        return baseURL.url!
    }
    
    init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }
}
