//
//  CityModel.swift
//  Favorites
//
//  Created by Joshua Reed on 6/8/26.
//

import Foundation

struct BookModel : Identifiable {
    let id: Int
    let bookTitle: String
    let bookAuthor: String
    var isFavorite: Bool = false
}
