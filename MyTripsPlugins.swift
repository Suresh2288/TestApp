//
//  MyTripsPlugins.swift
//  PocketTrips
//
//  Created by apple on 05/03/19.
//  Copyright © 2019 Smitiv. All rights reserved.
//

import Foundation
import Alamofire

class MyTripsProvider {
    
    private static let _instance = MyTripsProvider()
    
    static var Instance: MyTripsProvider {
        return _instance
    }
    
    // MARK:- List Of Trails
    func listOfTrails(withURL url:String, parameters: Dictionary<String, Any>, screen_id: String, event_id: String, completionHandler: @escaping (_ msg: String?, _ response: [TrailsList]?) -> Void) {
        
        let headers = ["Authorization" : "Basic YWRtaW46c3VwZXJzZWNyZXQ=",
                       "Content-Type": "application/x-www-form-urlencoded"]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            
            if response.result.isSuccess {
                do {
                    let userDetailsResponse = try JSONDecoder().decode([TrailsList].self, from: response.data!)
                    completionHandler(nil, userDetailsResponse)
                    Df_TouchProvider.Instance.df_create_touches(cust_id: "\(Extensions.getUserEmail())", screen_id: "\(screen_id)", screen_meta: "List of Trails Api Call", event_id: "\(event_id)", event_meta: "List of Trails fetched successfully", product_id: "", meta_data: "") { (msg, status) in
                        print("\(msg!)")
                    }
                } catch {
                    print("Error in decoder \(error)",response.result.value!)
                    completionHandler("Error in decoder: \(error)", nil)
                    Df_TouchProvider.Instance.df_create_touches(cust_id: "\(Extensions.getUserEmail())", screen_id: "\(screen_id)", screen_meta: "List of Trails Api Call", event_id: "\(event_id)", event_meta: "List of Trails fetched unsuccessful", product_id: "", meta_data: "") { (msg, status) in
                        print("\(msg!)")
                    }
                }
            } else {
                completionHandler(WebServiceMessages.SomethingWrong, nil)
                Df_TouchProvider.Instance.df_create_touches(cust_id: "\(Extensions.getUserEmail())", screen_id: "\(screen_id)", screen_meta: "List of Trails Api Call", event_id: "\(event_id)", event_meta: WebServiceMessages.SomethingWrong, product_id: "", meta_data: "") { (msg, status) in
                    print("\(msg!)")
                }
            }
        }
    }
    
    // MARK:- Trail Intro
    func trailIntro(withURL url:String, parameters: Dictionary<String, Any>, screen_id: String, event_id: String, completionHandler: @escaping (_ msg: String?, _ response: TrailIntroResponse?) -> Void) {
        
        let headers = ["Authorization" : "Basic YWRtaW46c3VwZXJzZWNyZXQ=",
                       "Content-Type": "application/x-www-form-urlencoded"]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            
            if response.result.isSuccess {
                do {
                    let userDetailsResponse = try JSONDecoder().decode(TrailIntroResponse.self, from: response.data!)
                    completionHandler(nil, userDetailsResponse)
                    print("Success --> ",response.result.value!)
                    Df_TouchProvider.Instance.df_create_touches(cust_id: "\(Extensions.getUserEmail())", screen_id: "\(screen_id)", screen_meta: "Trail Info Api Call", event_id: "\(event_id)", event_meta: "Trail Info fetched successfully", product_id: "", meta_data: "") { (msg, status) in
                        print("\(msg!)")
                    }
                } catch {
                    print("Error in decoder \(error)",response.result.value!)
                    completionHandler("Error in decoder: \(error)", nil)
                    Df_TouchProvider.Instance.df_create_touches(cust_id: "\(Extensions.getUserEmail())", screen_id: "\(screen_id)", screen_meta: "Trail Info Api Call", event_id: "\(event_id)", event_meta: "Trail Info fetching unsuccessful", product_id: "", meta_data: "") { (msg, status) in
                        print("\(msg!)")
                    }
                }
            } else {
                completionHandler(WebServiceMessages.SomethingWrong, nil)
                Df_TouchProvider.Instance.df_create_touches(cust_id: "\(Extensions.getUserEmail())", screen_id: "\(screen_id)", screen_meta: "Trail Info Api Call", event_id: "\(event_id)", event_meta: WebServiceMessages.SomethingWrong, product_id: "", meta_data: "") { (msg, status) in
                    print("\(msg!)")
                }
            }
        }
    }
    
    // MARK:- Trail Hotspot Geodata
    func trail_hotspot_geodata(withURL url:String, parameters: Dictionary<String, Any>, screen_id: String, event_id: String, completionHandler: @escaping (_ msg: String?, _ response: [HotspotGeoDataResponse]?) -> Void) {
        
        let headers = ["Authorization" : "Basic YWRtaW46c3VwZXJzZWNyZXQ=",
                       "Content-Type": "application/x-www-form-urlencoded"]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            
            if response.result.isSuccess {
                do {
                    let userDetailsResponse = try JSONDecoder().decode([HotspotGeoDataResponse].self, from: response.data!)
                    completionHandler(nil, userDetailsResponse)
                    print("Success --> ",response.result.value!)
                    Df_TouchProvider.Instance.df_create_touches(cust_id: "\(Extensions.getUserEmail())", screen_id: "\(screen_id)", screen_meta: "Trail Hotspot Geodata Api Call", event_id: "\(event_id)", event_meta: "Trail Hotspot Geodata fetched successfully", product_id: "", meta_data: "") { (msg, status) in
                        print("\(msg!)")
                    }
                } catch {
                    print("Error in decoder \(error)",response.result.value!)
                    completionHandler("Error in decoder: \(error)", nil)
                    Df_TouchProvider.Instance.df_create_touches(cust_id: "\(Extensions.getUserEmail())", screen_id: "\(screen_id)", screen_meta: "Trail Hotspot Geodata Api Call", event_id: "\(event_id)", event_meta: "Trail Hotspot Geodata fetching unsuccessful", product_id: "", meta_data: "") { (msg, status) in
                        print("\(msg!)")
                    }
                }
            } else {
                completionHandler(WebServiceMessages.SomethingWrong, nil)
                Df_TouchProvider.Instance.df_create_touches(cust_id: "\(Extensions.getUserEmail())", screen_id: "\(screen_id)", screen_meta: "Trail Hotspot Geodata Api Call", event_id: "\(event_id)", event_meta: WebServiceMessages.SomethingWrong, product_id: "", meta_data: "") { (msg, status) in
                    print("\(msg!)")
                }
            }
        }
    }
    
    // MARK:- Trail Hotspot Content
    func trail_hotspot_content(withURL url:String, parameters: Dictionary<String, Any>, screen_id: String, event_id: String, completionHandler: @escaping (_ msg: String?, _ response: HotspotContentResponse?) -> Void) {
        
        let headers = ["Authorization" : "Basic YWRtaW46c3VwZXJzZWNyZXQ=",
                       "Content-Type": "application/x-www-form-urlencoded"]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            
            if response.result.isSuccess {
                do {
                    let userDetailsResponse = try JSONDecoder().decode(HotspotContentResponse.self, from: response.data!)
                    completionHandler(nil, userDetailsResponse)
                    print("Success --> ",response.result.value!)
                    Df_TouchProvider.Instance.df_create_touches(cust_id: "\(Extensions.getUserEmail())", screen_id: "\(screen_id)", screen_meta: "Trail Hotspot Content Api Call", event_id: "\(event_id)", event_meta: "Trail Hotspot Content fetched successfully", product_id: "", meta_data: "") { (msg, status) in
                        print("\(msg!)")
                    }
                } catch {
                    print("Error in decoder \(error)",response.result.value!)
                    completionHandler("Error in decoder: \(error)", nil)
                    Df_TouchProvider.Instance.df_create_touches(cust_id: "\(Extensions.getUserEmail())", screen_id: "\(screen_id)", screen_meta: "Trail Hotspot Content Api Call", event_id: "\(event_id)", event_meta: "Trail Hotspot Content fetching unsuccessful", product_id: "", meta_data: "") { (msg, status) in
                        print("\(msg!)")
                    }
                }
            } else {
                completionHandler(WebServiceMessages.SomethingWrong, nil)
                Df_TouchProvider.Instance.df_create_touches(cust_id: "\(Extensions.getUserEmail())", screen_id: "\(screen_id)", screen_meta: "Trail Hotspot Content Api Call", event_id: "\(event_id)", event_meta: WebServiceMessages.SomethingWrong, product_id: "", meta_data: "") { (msg, status) in
                    print("\(msg!)")
                }
            }
        }
    }
}
