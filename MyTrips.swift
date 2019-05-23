//
//  MyTrips.swift
//  PocketTrips
//
//  Created by apple on 05/03/19.
//  Copyright © 2019 Smitiv. All rights reserved.
//

import Foundation

//MARK: - List Of Trails
struct TrailsList: Decodable
{
    var trail_id: Int?
    var old_trail_id: String?
    var trail_image: String?
    var trail_rating: String?
    var trail_downloads: String?
    var sort_weighted: String?
    var product_highlights: Product_Highlights?
    var application_name: String?
    var trails_banner: String?
    var trail_description: String?
    var share: String?
    var highlights: [String]?
    var places: String?
    var distance: String?
    var steps: String?
    var hours: String?
    var country_id: Int?
    var category_id: Int?
    var release_flag: String?
    var created: String?
    var updated: String?
    var shop_redirection_url: String?
    var universal_link: String?
    var trail_name: String?
    var producer_id: Int?
    
    enum CodingKeys: String, CodingKey{
        
        case trail_id
        case old_trail_id
        case trail_image
        case trail_rating
        case trail_downloads
        case sort_weighted
        case product_highlights
        case application_name
        case trails_banner
        case trail_description
        case share
        case highlights
        case places
        case distance
        case steps
        case hours
        case country_id
        case category_id
        case release_flag
        case created
        case updated
        case shop_redirection_url
        case universal_link
        case trail_name
        case producer_id
    }
}

class Product_Highlights: Decodable
{
    var ar_label: String?
    var ar_icon: String?
    var coupon_label: String?
    var coupon_icon: String?
}
