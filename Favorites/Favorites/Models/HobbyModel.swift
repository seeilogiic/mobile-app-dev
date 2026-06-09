//
//  CityModel.swift
//  Favorites
//
//  Created by Joshua Reed on 6/8/26.
//

import Foundation

struct HobbyModel : Identifiable{
    let id: Int
    let hobbyName: String
    let hobbyIcon: String
    var isFavorite: Bool = false
}
