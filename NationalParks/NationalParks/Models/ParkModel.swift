//
//  ParkModel.swift
//  NationalParks
//
//  Created by Joshua Reed on 6/12/26.
//

import Foundation

struct ParkModel : Codable, Identifiable {
    var id : String
    var fullName : String
    var states : String
    var designation : String
    var images : [ParkImageModel]
}

struct ParkImageModel : Codable {
    var url : String
    var alt : String
    
    enum CodingKeys: String, CodingKey {
        case url
        case alt = "altText"
    }
}
