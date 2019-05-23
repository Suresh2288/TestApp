//
//  RootViewModel.swift
//  SampleApp
//
//  Created by John Raja on 22/05/19.
//  Copyright © 2019 John Raja. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire

class RootViewModel {
    
    //private static let _instance = RootViewModel()
    
    static let sharedInstance = RootViewModel()
    
    
    
    /*
    func InsertNtucUserNric(_ data:ProfileRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetMasterData(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }
    
    func getCurrentSubscription(completed: @escaping completionHandler) {
        
        if let profile = ProfileData.getProfileObj() {
            
            let requestParam = GetSubscriptionRequest(email: profile.email, accessToken: profile.accessToken, countryCode: profile.CountryRegistered!).toJSON()
            
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetMasterData(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                
                completed(apiResponseHandler, error)
            }
        }
    }
    */
    
    func getNewsList(completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .get, path: APIManager.Router.GetTopNews(), parameters: nil) { (apiResponseHandler, error) -> Void in
            
            //print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            
            completed(apiResponseHandler, error)
        }
    }
    
    func listOfTrails(withURL url:String, completionHandler: @escaping (_ msg: String?, _ response: [SampleStructData04]?) -> Void) {
        
        //let headers = ["Authorization" : "Basic YWRtaW46c3VwZXJzZWNyZXQ=",
        //               "Content-Type": "application/x-www-form-urlencoded"]
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default).responseJSON { (response) in
            
            if response.result.isSuccess {
                do {
                    let userDetailsResponse = try JSONDecoder().decode([SampleStructData04].self, from: response.data!)
                    completionHandler(nil, userDetailsResponse) //{ (msg, status) in
                    //Df_TouchProvider.Instance.df_create_touches(cust_id: "\(Extensions.getUserEmail())", screen_id: "\(screen_id)", screen_meta: "List of Trails Api Call", event_id: "\(event_id)", event_meta: "List of Trails fetched successfully", product_id: "", meta_data: "")
                        //print("\(msg!)")
                    //}
                } catch {
                    print("Error in decoder \(error)",response.result.value!)
                    completionHandler("Error in decoder: \(error)", nil) //{ (msg, status) in
                    //Df_TouchProvider.Instance.df_create_touches(cust_id: "\(Extensions.getUserEmail())", screen_id: "\(screen_id)", screen_meta: "List of Trails Api Call", event_id: "\(event_id)", event_meta: "List of Trails fetched unsuccessful", product_id: "", meta_data: "") { (msg, status) in
                        //print("\(msg!)")
                    //}
                }
            } else {
                completionHandler("Something went wrong", nil)
                
            }
        }
    }
    
    /*
    func getCities(_ data:CityDataRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetCities(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
 */
}


