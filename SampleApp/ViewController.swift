//
//  ViewController.swift
//  SampleApp
//
//  Created by John Raja on 13/05/19.
//  Copyright © 2019 John Raja. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var viewModel = RootViewModel()
    var NewsList : Results<NewsList>!
    var ListArray = [SampleStructData04]()
    
    var titleArr = [String]()
    var userArr = [String]()
    
    var newsList = [SampleStructData02]()
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //getFeaturedpNewsInfo()
        
        myTableView.register(UINib(nibName : "MyTableViewCell", bundle : nil), forCellReuseIdentifier: "MyTableViewCell")
    }
 
    override func viewDidAppear(_ animated: Bool) {
        sampleRequest01()
    }
    func  getFeaturedpNewsInfo(){

        
        //viewModel.getNewsList{ (apiResponseHandler, error) in
            
        APIManager.sharedInstance.sendJSONRequest(method: .get, path: APIManager.Router.GetTopNews(), parameters: nil) { (apiResponseHandler, error) -> Void in
            
            if apiResponseHandler.isSuccess() {
                
                print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
                
                if let error = error {
                    print("== \(error)")
                } else {
                    print("== success")
                    
                    guard let data = apiResponseHandler.dataString else {
                        return
                    }
                    
                    do {
                        
                        //let sample = try! JSONDecoder().decode(SampleStructData02.self, from: data)
                        
                        self.ListArray = try JSONDecoder().decode([SampleStructData04].self, from: apiResponseHandler.jsonObject as! Data)
                        //let codableStruct = try JSONDecoder().decode(SampleResponse.todos.self, from: data)
                        
                        /*
                         for info in self.ListArray {
                         
                         self.titleArr.append(info.title!)
                         self.userArr.append(String(info.userId))
                         
                         //print("\(self.sympolsCoin) : \(self.priceUSDcoin)")
                         
                         }
                         */
                        
                        DispatchQueue.main.async {
                            self.myTableView.reloadData()
                        }
                        
                        print(self.ListArray)
                    } catch {
                        print(error)
                    }
                    
                    print("===============================\n\n")
                }
                
                /*
                if let response = Mapper<NewsResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                    
                    print(response.NewsList!)
                }
                 */
            }
        }
        
        
        
        /*
         if let parentProfile = ProfileData.getProfileObj() {
            let request = InsertNtucUserNricRequest(email: parentProfile.email, nric: "", accessToken: parentProfile.accessToken, mobileNo:txtNRIC.text!)
         
            if ReachabilityUtil.shareInstance.isOnline(){
         
                ParentApiManager.sharedInstance.InsertNtucUserNric(request, completed: { (apiResponseHandler, error) in
         
                if apiResponseHandler.isSuccess() {
                    self.RedeemUpdatedSuccessfully()
                } else {
                    self.showAlert(apiResponseHandler.errorMessage())
                }
            })
         }
         }
        */
        
        /*
        let url = "http://friendservice.herokuapp.com/listFriends"
        
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                if response.result.isSuccess {
                    print("response",response)
                    let json = try? JSON(data: response.data!)
                    
                    
                    let friendsList = json?.arrayValue
                    let jsonArr = JSON(friendsList!)
                    
                    for (_, object) in jsonArr {
                        let firstname = object ["firstname"].stringValue
                        
                        print(firstname)
                    }
                    
                    /*
                    if json!["status"] == 1 {
                        
                        let newsList = json!["article_list"].array
                        
                        let jsonArr = JSON(newsList!)
                        for (_, object) in jsonArr {
                            let category = object ["category"].stringValue
                            //                            print("category",category)
                            
                            let post = object ["post_title"].stringValue
                            
                        }
                    }
 */
                }
                
        }
        */
    }
}

// MARK: - Sample Request
extension ViewController {
    func sampleRequest01(){
        print("===============================")
        print("== \(#function)")
        
        //http://perfectrdp.us/newspaper_webservice/get_top_news.php
        //https://jsonplaceholder.typicode.com/todos
        
        let url = URL(string: "http://perfectrdp.us/newspaper_webservice/get_top_news.php")
        
        //let paramDic:NSDictionary = ["trail_id":"\(trail_id)"]
        
        RootViewModel.sharedInstance.listOfTrails(withURL: "https://jsonplaceholder.typicode.com/todos") { (message, response) in
            
            if message != nil {
                print(message!)
            }
            else {
                print(response!)
                
                self.ListArray = response!
                
                DispatchQueue.main.async {
                    self.myTableView.reloadData()
                }
                
                /*
                self.trailsIntro = response!
                self.channel_price_high = (response?.channel_price_high)!
                self.trail_hotspots = (response?.trail_hotspots)!
                // self.setValues()
                self.rightTableview.reloadData()
                self.rightTableview.scrollsToTop = true
                self.callTrailHotspotGeoDataApi(trail_id: trail_id)
                */
            }
        }
        
        /*
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if let error = error {
                print("== \(error)")
            } else {
                print("== success")
                
                guard let data = data else {
                    return
                }
                
                do {
                    //self.ListArray = try JSONDecoder().decode([SampleStructData04].self, from: data)
                    //let codableStruct = try JSONDecoder().decode(SampleResponse.todos.self, from: data)
                    
                    let sample = try! JSONDecoder().decode(SampleStructData02.self, from: data)
                    print(sample)
                    /*
                    for info in self.ListArray {
                        
                        self.titleArr.append(info.title!)
                        self.userArr.append(String(info.userId))
                        
                        //print("\(self.sympolsCoin) : \(self.priceUSDcoin)")
                        
                    }
                    */
                    
                    DispatchQueue.main.async {
                        self.myTableView.reloadData()
                    }
                    
                    print(self.ListArray)
                } catch {
                    print(error)
                }
                
                print("===============================\n\n")
            }
        }).resume()
 
        */
    }
}

// MARK: - UITableViewDelegate
extension ViewController  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ListArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell") as! MyTableViewCell
        
        //let item = self.ListArray[indexPath.row].title
        cell.titleLabel?.text =  self.ListArray[indexPath.row].title
        cell.detailLabel?.text =  String(self.ListArray[indexPath.row].userId)
        
        return cell
    }
    
}
