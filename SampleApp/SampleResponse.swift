//
//  SampleResponse.swift
//  SampleApp
//
//  Created by MacBook on 22/05/19.
//  Copyright © 2019 John Raja. All rights reserved.
//

import Foundation

struct SampleResponse { }

/**
 {
 userId: 1,
 id: 1,
 title: "delectus aut autem",
 completed: false
 }
 */
extension SampleResponse {
    struct todos: Codable {
        let userId:Int
        let id:Int
        let title: String?
        let completed:Bool?
        
        let testTrash:String?
    }
}

struct SampleStructData02: Decodable {
    let msg: String
    let news_list: SampleStructData02SubData?
    
    enum CodingKeys: String, CodingKey
    {
        case msg
        case news_list
    }
}

class SampleStructData02SubData: Decodable {
    let category : String
    //let article_list : SampleStructData03SubData
    
    enum CodingKeys: String, CodingKey
    {
        case category
        //case article_list
    }
}

struct SampleStructData03SubData: Decodable {
    let post_id : Int
    let post_title : String
    let post_image : String
    
    enum CodingKeys: String, CodingKey
    {
        case post_id
        case post_title
        case post_image
    }
}

struct SampleStructData04 : Decodable {
    let userId: Int
    //let id:Int
    let title: String?
    //let completed:Bool?
    
}
