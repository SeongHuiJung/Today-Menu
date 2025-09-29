//
//  RestaurantSearchModel.swift
//  TodayMenu
//
//  Created by Claude on 9/30/25.
//

import Foundation

struct MapData: Decodable {
    let documents: [RestaurantData]
}

struct RestaurantData: Decodable {
    let id: String
    let longitude: String
    let latitude: String
    let restaurantName: String
    let categoryName: String
    let distance: String
    let addressName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case longitude = "x"
        case latitude = "y"
        case restaurantName = "place_name"
        case categoryName = "category_name"
        case distance
        case addressName = "address_name"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.longitude = try container.decode(String.self, forKey: .longitude)
        self.latitude = try container.decode(String.self, forKey: .latitude)
        self.restaurantName = try container.decode(String.self, forKey: .restaurantName)
        self.categoryName = try container.decode(String.self, forKey: .categoryName)
        self.distance = try container.decode(String.self, forKey: .distance)
        self.addressName = try container.decode(String.self, forKey: .addressName)
    }
}
