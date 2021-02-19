//
//  AnnictWorksModel.swift
//  Colombia
//
//  Created by 山根大生 on 2021/02/16.
//

import Foundation

struct AnnictAPIModel: Decodable {
    let works: [Work]
}

struct Work: Decodable {
    let id: Int
    let title: String
    let images: Image
}

struct Image: Decodable {
    let recommendedUrl: String?
    
    enum Key: String, CodingKey {
        case recommendedUrl = "recommended_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.recommendedUrl = try container.decode(String.self, forKey: .recommendedUrl)
    }
}
