//
//  AnnictWorksModel.swift
//  Colombia
//
//  Created by 山根大生 on 2021/02/16.
//

import Foundation

struct AnnictWorksModel: Decodable {
    let id: Int
    let title: String
    let title_kana: String
    let media: String
    let season_name: String
    let season_name_text: String
    let released_on: Date
    let released_on_about: String
    let official_site_url: String
    let wikipedia_url: String
    let twitter_username: String
    let twitter_hashtag: String
    let syobocal_tid: Int
    let mal_anime_id: Int
    let images: [Images]
    let episodes_count: Int
    let watchers_count: Int
}

struct Images: Decodable {
    let recommended_url: String
    let facebook: [Facebook]
    let twitter: [Twitter]
}

struct Facebook: Decodable {
    let og_image_url: String
}

struct Twitter: Decodable {
    let mini_avatar_url: String
    let normal_avatar_url: String
    let bigger_avatar_url: String
    let original_avatar_url: String
    let image_url: String
}
