//
//  SampleData.swift
//  SampleApp
//
//  Created by John Raja on 22/05/19.
//  Copyright © 2019 John Raja. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

/*
class ProfileResponse: NSObject, Mappable {
    
    dynamic var profiles: [ChildProfile]?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        profiles <- map["Data.profile"]
    }
    
}
*/

class NewsResponse: NSObject, Mappable {
    
    var NewsList: [NewsList]?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        NewsList <- map["news_list"]
    }
    
}

class NewsList : Object, Mappable{
    
    var postId = ""
    var postTitle = ""
    var postImage = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        postId <- map["firstname"]
        postTitle <- map["lastname"]
        postImage <- map["phonenumber"]
    }
    
}

/*
class NewsListResponse : Object, Mappable{
    
    var firstname = ""
    var lastname = ""
    var phonenumber = ""
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        firstname <- map["firstname"]
        lastname <- map["lastname"]
        phonenumber <- map["phonenumber"]
    }
    
}
*/

class ProfileRequest: NSObject, Mappable {
    
    var email = ""
    var accessToken = ""
    
    required init?(map: Map){
        
    }
    
    init(email: String, accessToken: String) {
        
        self.email = email
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
    }
}
