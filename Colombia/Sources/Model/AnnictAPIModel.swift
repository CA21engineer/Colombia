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
    let image: Image
    var isFavorite: Bool
    
    enum Key: String, CodingKey {
        case id
        case title
        case image = "images"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.image = try container.decode(Image.self, forKey: .image)
        self.isFavorite = false
    }
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


