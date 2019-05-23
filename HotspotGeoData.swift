//
//  HotspotGeoData.swift
//  PocketTrips
//
//  Created by apple on 02/04/19.
//  Copyright © 2019 Smitiv. All rights reserved.
//

import Foundation

class HotspotGeoDataResponse: Decodable
{
    var hotspot_name: String?
    var hotspot_lat: String?
    var hotspot_lon: String?
    var hotspot_highlights: Hotspot_Highlights?
    var hotspot_visited_count: Int?
    var hotspot_address: String?
    var hotspot_description: String?
    var operating_hours: String?
    var hotspot_favorite_count: Int?
    var hotspot_share_count: Int?
    var hotspot_share_url: String?
    var hotspot_has_level: Bool?
    var release_flag: String?
    var country_id: Int?
    var category_id: Int?
    var hotspot_number: String?
    var hotspot_image_urls: [String]?
    var updated: String?
    var trail_id: Int?
    var hotspot_id: Int?
    var shop_redirection_url: String?
    var universal_link: String?
    var producer_id: String?
    var iso_language_code: String?
    var trip_advisor_list: [String]?
    var levels: [HotspotGeoData_Levels]?
    var triggers: [Triggers]?
    
    enum CodingKeys: String, CodingKey
    {
        case hotspot_name
        case hotspot_lat
        case hotspot_lon
        case hotspot_highlights
        case hotspot_visited_count
        case hotspot_address
        case hotspot_description
        case operating_hours
        case hotspot_favorite_count
        case hotspot_share_count
        case hotspot_share_url
        case hotspot_has_level
        case release_flag
        case country_id
        case category_id
        case hotspot_number
        case hotspot_image_urls
        case updated
        case trail_id
        case hotspot_id
        case shop_redirection_url
        case universal_link
        case producer_id
        case iso_language_code
        case trip_advisor_list
        case levels
        case triggers
    }
}

class Hotspot_Highlights: Decodable
{
    var ar: String?
    var arIcon: String?
    var coupon: String?
    var couponIcon: String?
    var games: String?
    var gamesIcon: String?
    
    enum CodingKeys: String, CodingKey
    {
        case ar
        case arIcon
        case coupon
        case couponIcon
        case games
        case gamesIcon
    }
}

class HotspotGeoData_Levels: Decodable
{
    var _id: String?
    var hotspot_number: String?
    var trail_id: Int?
    var hotspot_id: Int?
    var level_id: Int?
    var level: String?
    var created: String?
    var release_flag: String?
    var updated: String?
    var level_description: String?
    var level_name: String?
    var media360: [String]?
    
    enum CodingKeys: String, CodingKey
    {
        case _id
        case hotspot_number
        case trail_id
        case hotspot_id
        case level_id
        case level
        case created
        case release_flag
        case updated
        case level_description
        case level_name
        case media360
    }
}

//MARK: - Triggers
class Triggers: Decodable
{
    var geodata_ble_hotspot: Geodata_Ble_Hotspot?
    var geodata_gps_hotspot: Geodata_Gps_Hotspot?
    var geodata_ir_hotspot: Geodata_Ir_Hotspot?
    var trigger_id: Int?
    var level_id: Int?
    var hotspot_id: Int?
    var hotspot_number: String?
    
    enum CodingKeys: String, CodingKey
    {
        case geodata_ble_hotspot
        case geodata_gps_hotspot
        case geodata_ir_hotspot
        case trigger_id
        case level_id
        case hotspot_id
        case hotspot_number
    }
}

//MARK: - Geodata_Ble_Hotspot
class Geodata_Ble_Hotspot: Decodable
{
    var type: String?
    var properties: Ble_Properties?
    var geometry: Ble_Geometry?
    
    enum CodingKeys: String, CodingKey
    {
        case type
        case properties
        case geometry
    }
}

class Ble_Properties: Decodable
{
    var feature_type: String?
    var projection: String?
    var radius: Int?
    var triggerType: String?
    var settings: Ble_Settings?
    var centroid:  Ble_Centroid?
    
    enum CodingKeys: String, CodingKey
    {
        case feature_type
        case projection
        case radius
        case triggerType
        case settings
        case centroid
    }
}

class Ble_Settings: Decodable
{
    var beacons: [Ble_Beacons]?
    var uid: String?
    var action: String?
    var meta: String?
    
    enum CodingKeys: String, CodingKey
    {
        case beacons
        case uid
        case action
        case meta
    }
}

class Ble_Beacons: Decodable
{
    var name: String?
    var uuid: String?
    var major: String?
    var minor: String?
    var range: String?
    var meta: String?
    
    enum CodingKeys: String, CodingKey
    {
        case name
        case uuid
        case major
        case minor
        case range
        case meta
    }
}

class Ble_Centroid: Decodable
{
    var lon: Double?
    var lat: Double?
    
    enum CodingKeys: String, CodingKey
    {
        case lon
        case lat
    }
}

class Ble_Geometry: Decodable
{
    var type: String?
    var coordinates: [Ble_Coordinates]?
    
    enum CodingKeys: String, CodingKey
    {
        case type
        case coordinates
    }
}

class Ble_Coordinates : Decodable
{
    
}

//class Ble_Coordinates : Codable
//{
//    let array: [Double]?
//
//    required init(from decoder: Decoder) throws
//    {
//        var container = try decoder.unkeyedContainer()
//        array = try container.decode([Double].self)
//    }
//}


//MARK: - Geodata_Gps_Hotspot
class Geodata_Gps_Hotspot: Decodable {
    
    var type: String?
    var properties: Gps_Properties?
    var geometry: Gps_Geometry?
    
    enum CodingKeys: String, CodingKey
    {
        case type
        case properties
        case geometry
    }
}

class Gps_Properties: Decodable {
    
    var feature_type: String?
    var projection: String?
    var radius: Int?
    var triggerType: String?
    var centroid: Gps_Centroid?
    var action: String?
    
    enum CodingKeys: String, CodingKey
    {
        case feature_type
        case projection
        case radius
        case triggerType
        case centroid
        case action
    }
}

class Gps_Centroid: Decodable {
    
    var lon: Double?
    var lat: Double?
    
    enum CodingKeys: String, CodingKey
    {
        case lon
        case lat
    }
}

class Gps_Geometry: Decodable
{
    var type: String?
    var coordinates: [Gps_Coordinates]?
    
    enum CodingKeys: String, CodingKey
    {
        case type
        case coordinates
    }
}

class Gps_Coordinates : Decodable
{
    
}

//class Gps_Coordinates : Codable
//{
//    let array: [Double]?
//
//    required init(from decoder: Decoder) throws
//    {
//        var container = try decoder.unkeyedContainer()
//        array = try container.decode([Double].self)
//    }
//}

//MARK: - Geodata_Ir_Hotspot
class Geodata_Ir_Hotspot: Decodable {
    
    var type: String?
    var properties: Ir_Properties?
    var geometry: Ir_Geometry?
    
    enum CodingKeys: String, CodingKey
    {
        case type
        case properties
        case geometry
    }
}

class Ir_Properties: Decodable {
    
    var feature_type: String?
    var projection: String?
    var radius: Int?
    var triggerType: String?
    var settings: Ir_Settings?
    var centroid: Ir_Centroid?
    
    enum CodingKeys: String, CodingKey
    {
        case feature_type
        case projection
        case radius
        case triggerType
        case settings
        case centroid
    }
}

class Ir_Settings: Decodable {
    
    var images: [Ir_Images]?
    var preview: [String]?
    var uid: String?
    var autoTriggerInSecs: Int?
    var action: String?
    var meta: String?
    
    enum CodingKeys: String, CodingKey
    {
        case images
        case preview
        case uid
        case autoTriggerInSecs
        case action
        case meta
    }
}

class Ir_Centroid: Decodable {
    
    var lon: Double?
    var lat: Double?
    
    enum CodingKeys: String, CodingKey
    {
        case lon
        case lat
    }
}

class Ir_Geometry: Decodable {
    
    var type: String?
    var coordinates: [Ir_Coordinates]?
    
    enum CodingKeys: String, CodingKey
    {
        case type
        case coordinates
    }
}

class Ir_Coordinates : Decodable
{
    
}

//class Ir_Coordinates : Codable
//{
//    let array: [Double]?
//
//    required init(from decoder: Decoder) throws
//    {
//        var container = try decoder.unkeyedContainer()
//        array = try container.decode([Double].self)
//    }
//}

class Ir_Images: Decodable {
    
    var uri: String?
    var name: String?
    
    enum CodingKeys: String, CodingKey
    {
        case uri
        case name
    }
}
