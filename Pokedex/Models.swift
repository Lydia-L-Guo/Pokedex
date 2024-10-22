//
//  Models.swift
//  Pokedex
//
//  Created by Lydia Guo on 2024/10/21.
//

import Foundation

struct PKListItem: Codable {
    let name: String
    let url: URL?
}

struct Sprite: Codable {
    let front_default: String?
}

struct PKDetailItem {
    let sprites: Sprite?
    let frontDefaultURL: URL?
    let name: String?
}

struct PKListResponse: Codable {
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [PKListItem]
}

struct PKDetailResponse: Codable {
    let sprites: Sprite?
}
