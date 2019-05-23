//
//  APIManager.swift
//  SampleApp
//
//  Created by John Raja on 22/05/19.
//  Copyright © 2019 John Raja. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper
//import SwiftyUserDefaults
//import HTTPStatusCodes
import AlamofireObjectMapper
import RealmSwift

typealias completionHandler = (_ apiResponseHandler: ApiResponseHandler, _ error: Error?) -> Void
typealias responseCompletionHandler = (_ apiResponseHandler: ApiResponseHandler, _ error: Error?) -> Void


class APIManager {
    
    // Singleton
    static let sharedInstance = APIManager()
    
    var defaultManager: Alamofire.SessionManager!
    
    init() {
        
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            :
        ]
        
        let sessionManager = SessionManager(
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
        self.defaultManager = sessionManager
        
    }
    
    enum Router: URLConvertible {
        
        case GetTopNews()
        
        var path: String {
            switch self {
            case .GetTopNews:
                return "/get_top_news.php"
            }
        }
        
        func asURL() throws -> URL {
            
            //http://friendservice.herokuapp.com/listFriends
            //let url = "http://perfectrdp.us/newspaper_webservice/get_top_news.php"
            
            //let url = "http://perfectrdp.us/newspaper_webservice"
            let url = try Constants.API.URL.asURL()
            return url.appendingPathComponent(path)
        }
        
    }
    
    func sendJSONRequest(method: HTTPMethod, path: URLConvertible, parameters: [String : Any]?, completed: @escaping responseCompletionHandler) {
//        let headers = [
//            "Authorization": getAuthorizationCode(path: path),
//            "Content-Type" : "application/json"
//        ]
        
        let updatedParams = parameters
        
        sendJSONRequest(method: method, path: path, parameters: updatedParams, encoding: JSONEncoding.default, completed: completed)
    }
    
    // Common JSON Request
    func sendJSONRequest(method: HTTPMethod, path: URLConvertible, parameters: [String : Any]?, encoding: ParameterEncoding, completed: @escaping responseCompletionHandler) {
        
        defaultManager.request(path, method: method, parameters: parameters, encoding: encoding)
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .success(let data):
                    
                    //if let rsp = response.response {
                        
                        //let successCode = HTTPStatusCode(rawValue: rsp.statusCode)!.isSuccess
                        
                        // Have HTTP error ?
                        //if successCode {
                            
                            //let json = JSON(data)
                            //let error = json["Success"].boolValue
                            //let errorMessage = json["Message"].stringValue
                            //let errorCode = json["ErrorCode"].stringValue
                        //}
                        
                        let apiResponseHandler : ApiResponseHandler = ApiResponseHandler(json: data)
                        completed(apiResponseHandler, nil)
                        
                    //}
                    
                    break
                    
                case .failure(let error):
                    
                    let apiResponseHandler:ApiResponseHandler = ApiResponseHandler(json: nil)
                    
                    completed(apiResponseHandler, error)
                    
                    break
                    
                }
                
        }
    }
}

struct ApiResponseHandler {
    var success:Bool = false
    var message:String? = nil
    var dataString:Any? = nil
    var jsonObject:Any? = nil
    
    init(json:Any?) {
        if let js = json {
            self.jsonObject = js
            
            let json = JSON(js)
            self.success = json["status"].boolValue
            self.message = json["msg"].stringValue
            self.dataString = json["news_list"].string
        }
    }
    
    func isSuccess() -> Bool {
        return success == true
    }
    
    func errorMessage() -> String {
        guard message != nil else {
            return "Unknown Error Occurred"
        }
        return message!
    }
}
