//
//  CityModel.swift
//  Favorites
//
//  Created by Joshua Reed on 6/8/26.
//

import Foundation

struct CityModel: Identifiable {
    let id: Int
    let cityName: String
    let cityImage: String
    var isFavorite: Bool = false
}
