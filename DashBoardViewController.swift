//
//  DashBoardViewController.swift
//  News_Paper
//
//  Created by Smitiv iOS on 27/03/19.
//  Copyright © 2019 Gova. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVKit
import SWRevealViewController
import NVActivityIndicatorView
import CoreLocation


class DashBoardViewController: UIViewController ,SWRevealViewControllerDelegate,UIScrollViewDelegate,CLLocationManagerDelegate{

    

    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var nameLbl1: UILabel!
    @IBOutlet weak var citynameLbl: UILabel!
    @IBOutlet weak var weatherLbl: UILabel!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var DashBoardScrollView: UIScrollView!
    @IBOutlet weak var overAllTableView: UITableView!
    @IBOutlet weak var menuView: UIView!
     let defaults: UserDefaults? = UserDefaults.standard
    
    var titleArray : [String] = []
    var imageArray : [URL] = []
    var titleSectionArr = ["Top news","Videos"]
    var videoArr : [URL] = []
    var newsImagesArr : [URL] = []
    var titleArr : [String] = []
    var postDateArr : [String] = []
    var categoryListArr : [String] = []
    var shareCountArr : [String] = []
    var cmmtCountArr : [String] = []
    var likeCountArr : [String] = []
    let revealViewButton = UIButton()
    var postid :String?
    var refreshControl = UIRefreshControl()
    
    //var locationManager = CLLocationManager()
    let manager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    var locality = ""
    var administrativeArea = ""
    var country = ""
    var city :String?

    var greeting = String()
    let date     = Date()
    let calendar = Calendar.current
    let hour     = Calendar.current.component(.hour, from: Date())

    let morning = 3; let afternoon=12; let evening=16; let night=22;
    var userName = String ()
    
    var player = AVPlayer()
    var avPlayerController = AVPlayerViewController()
    
    
//
    override func viewDidLoad() {
        super.viewDidLoad()
       
        getFeaturedpNewsInfo()
        getBottomVideoInfo()
        greetingLogic()
        
//        self.navigationController?.navigationBar.isHidden = true
//        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        nameLbl1.text = "Guest"
     
        if (self.defaults?.string(forKey: "userNameLogin")) != nil {
            
            nameLbl1.text = self.defaults?.string(forKey: "userNameLogin")
        } else if (self.defaults?.string(forKey: "userNameFb")) != nil{
            nameLbl1.text = self.defaults?.string(forKey: "userNameFb") 
        } else if (self.defaults?.string(forKey: "userNameGoole")) != nil{
            nameLbl1.text = self.defaults?.string(forKey: "userNameGoole")
        } else if (self.defaults?.string(forKey: "userNameReg")) != nil{
            nameLbl1.text = self.defaults?.string(forKey: "userNameReg")
        }
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        overAllTableView.dataSource = self
        overAllTableView.delegate = self
        overAllTableView.reloadData()
        
         self.revealViewController().delegate = self
        revealViewButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        revealViewButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        revealViewButton.backgroundColor = UIColor.clear
        revealViewButton.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        revealViewButton.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
         self.activityIndicator(animate: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.topNewsNavigation(notification:)), name: Notification.Name("NotificationIdentifier"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.coruselNavigation(notification:)), name: Notification.Name("NotificationCollection"), object: nil)

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.videosNavigation(notification:)), name: Notification.Name("VideosNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.MagazineNavigation(notification:)), name: Notification.Name("MagazineNotification"), object: nil)

         NotificationCenter.default.addObserver(self, selector: #selector(self.EducationNavigation(notification:)), name: Notification.Name("EducationNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.cricNavigation(notification:)), name: Notification.Name("Notification"), object: nil)
        
       
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        overAllTableView.addSubview(refreshControl)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.activityIndicator(animate: false)
       
        if let StatusbarView = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            StatusbarView.backgroundColor = UIColor(red: 57/255, green: 73/255, blue: 171/255, alpha: 1.0)
            
        }
        setNavigationBar(type: "", title: "", background: Colors.DashboardThemColor, textColor: .white, backButton: "RoundBackBtn", showBckBtn: false, fromRevealView: false, dismiss: false)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if (defaults?.bool(forKey: "signedIn"))!{
            performSegue(withIdentifier: "signed", sender: self)
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }

    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
//
//        let geocoder = CLGeocoder()
//
//
//    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        manager.stopUpdatingLocation()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            if (error != nil) {
                print("Error in reverseGeocode")
            }
            
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count > 0 {
                let placemark = placemarks![0]
                self.locality = placemark.locality!
                self.administrativeArea = placemark.administrativeArea!
                self.country = placemark.country!
                self.citynameLbl.text = self.locality
                
                
                let url = URLComponents(string: "http://api.apixu.com/v1/forecast.json?key=361ffef4aac44e018f1134610183101&q=\(self.locality))&days=1")
                print("weather url", url as Any)
                //print("weather url",locality)
                
                Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default)
                    .responseJSON { response in
                        
                        
                        if response.result.isSuccess {
                            print("weatherREsponse",response)
                            let json = try? JSON(data: response.data!)
                            
                                print("weatherjson",json!)
                                let newsList = json!["current"].dictionary
                            
                                print("current",newsList as Any)
                                
                            let temp = newsList!["temp_c"]!.intValue
                            self.weatherLbl.text = String(temp)
                            print("temperature",temp)
                            
                        }
                }
                self.overAllTableView.reloadData()
                
                
                
                
            }
        })
    }
    
    func userLocationString() -> String {
        let userLocationString = "\(locality), \(administrativeArea), \(country)"
        return userLocationString
    }
    
    func greetingLogic() {
        let date = NSDate()
        let calendar = NSCalendar.current
        let currentHour = calendar.component(.hour, from: date as Date)
        let hourInt = Int(currentHour.description)!
        
        if hourInt >= 12 && hourInt <= 16 {
            greeting = "Afternoon,"
        }
        else if hourInt >= 7 && hourInt <= 12 {
            greeting = "Morning,"
        }
        else if hourInt >= 16 && hourInt <= 20 {
            greeting = "Evening,"
        }
        else if hourInt >= 20 && hourInt <= 24 {
            greeting = "Night,"
        }
        else if hourInt >= 0 && hourInt <= 7 {
            greeting = "You should be sleeping right now,"
        }
        
        nameLbl.text = greeting
    }

    @objc func cricNavigation(notification: NSNotification){
        
        //        print("notification.userInfo",notification.userInfo!)
        
        let dict = notification.userInfo
        let currentIndex = dict!["currentIndex"]
        
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CricketVc") as! CricketVc
        self.navigationController?.pushViewController(vc, animated:true)
//        let viewController: CricketVc? = storyboard?.instantiateViewController(withIdentifier: "CricketVc") as? CricketVc
//
//        let navi = UINavigationController(rootViewController: viewController!)
//        self.navigationController?.pushViewController(navi, animated: true)
//
    }
    
    @objc func topNewsNavigation(notification: NSNotification){
        
//        print("notification.userInfo",notification.userInfo!)
        
        let dict = notification.userInfo
       // let currentIndex = dict!["currentIndex"]
        
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        self.navigationController?.pushViewController(vc, animated:true)
        
    }
    
    @objc func coruselNavigation(notification: NSNotification){
        
//        print("notification.userInfo",notification.userInfo!)
        
        let dict = notification.userInfo
      //  let currentIndex = dict!["currentIndex"]
        
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        self.navigationController?.pushViewController(vc, animated:true)
        
    }
    @objc func videosNavigation(notification: NSNotification){
        
//        print("notification.userInfo",notification.userInfo!)
        
        let dict = notification.userInfo
     //   let currentIndex = dict!["currentIndex"]
        
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        self.navigationController?.pushViewController(vc, animated:true)
        
    }
    
    @objc func MagazineNavigation(notification: NSNotification){
        
//        print("notification.userInfo",notification.userInfo!)
        
        let dict = notification.userInfo
     //   let currentIndex = dict!["currentIndex"]
        
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        self.navigationController?.pushViewController(vc, animated:true)
        
    }
    @objc func EducationNavigation(notification: NSNotification){
        
//        print("notification.userInfo",notification.userInfo!)
        
        let dict = notification.userInfo
      //  let currentIndex = dict!["currentIndex"]
        
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        self.navigationController?.pushViewController(vc, animated:true)
        
    }
    
    @objc func refresh(_ sender: Any) {
//       print("hello")
        getBottomVideoInfo()
        getFeaturedpNewsInfo()
        getTopNewsInfo()
        getFeaturedpNewsInfo()
        getEducationInfo()
       // getSubCategrynfo()
        getCategoryInfo()
        getCategoryInfo1()
        refreshControl.endRefreshing()

    }
    
    func activityIndicator(animate:Bool) {
        
        let size = CGSize(width: 45, height: 45)
        let activityData = ActivityData(size: size, type: .circleStrokeSpin, color: UIColor.white, padding: 5)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
        
        if animate == true {
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
        } else {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
        }
    }
    
    
   
    
    func  getVideoNewsInfo(){
        
        
        let url = "\(WebService.BaseUrl)\(WebService.VideosNews)"
        
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                
                if response.result.isSuccess {
                    
                    let json = try? JSON(data: response.data!)
                    if json!["status"] == 1 {
                        
                        let newsList = json!["news_list"].array
                        
                        let jsonArr = JSON(newsList!)
                        for (_, object) in jsonArr {
                            let category = object ["category"].stringValue
//                            print("category",category)
                            
                            let artcile_arr = object ["article_list"].array
                            
                            //                            let cat_list = object ["article_list"][0]["cat_list"].array
                                             //           print("category", cat_list as Any )
                            
                            
                            let postid1 = artcile_arr![0...3]
//                            print("post_title",postid1 as Any)
                            
                            
                            for postid in postid1 {
                                
                                let post = postid ["post_title"].stringValue
                                
                                self.titleArr.append(post)
//                                print("post_title", post as Any)
                            }
                            for art_postdate in artcile_arr! {
                                
                                let art_post_date = art_postdate ["art_post_date"].stringValue
                                self.postDateArr.append(art_post_date)
//                                print("art_post_date", art_post_date as Any)
                            }
                            for topnewsImg in artcile_arr!{
                                let image = topnewsImg["post_image"].stringValue
                                let imageURL: URL = URL(string: image)!
                                self.newsImagesArr.append(imageURL)
                            }
                            for shareCount in artcile_arr!{
                                let share_Count = shareCount ["share_count"].stringValue
                                self.shareCountArr.append(share_Count)
                            }
                            for cmmtCount in artcile_arr!{
                                let cmmt_Count = cmmtCount ["comment_count"].stringValue
                                self.cmmtCountArr.append(cmmt_Count)
                            }
                            for likeCount in artcile_arr!{
                                let like_Count = likeCount ["likes_count"].stringValue
                                self.likeCountArr.append(like_Count)
                            }
                            for catlist in artcile_arr! {
                                
                                let categorylists = catlist ["cat_list"].arrayValue
//                                print("categorylists", categorylists  as Any)
                                for catName in categorylists {
                                    
                                    let cat_Name = catName["cat_name"].stringValue
                                    self.categoryListArr.append(cat_Name)
//                                    print("cat_Name", cat_Name  as Any)
                                    
                                }
                            }
                            
                        }
                    }
                }
                self.overAllTableView.reloadData()
        }
  }
    
    
    func  getBottomVideoInfo(){
        
        let url = "\(WebService.BaseUrl)\(WebService.BottomVideo)"
        
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                
                if response.result.isSuccess {
                    
                    let json = try? JSON(data: response.data!)
                    if json!["status"] == 1 {
                        
                        let newsList = json!["news_list"].array
                        
                        let jsonArr = JSON(newsList!)
                        for (_, object) in jsonArr {
                            
                            
                            let videoHeading = object["video_heading"].stringValue
//                            print("videoHeading",videoHeading )
                            
                            let video = object["video_file"].stringValue
                            let videoURL: URL = URL(string: video)!
                            self.videoArr.append(videoURL)
//                            print("video",videoURL)
                            
                        }
                        
                    }
                }
        }
         self.overAllTableView.reloadData()
    }
    @IBAction func searchBtn(_ sender: Any) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let memberDetailsViewController = storyBoard.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        self.navigationController?.pushViewController(memberDetailsViewController, animated:true)
//        print("button clicked")
    }
    
    @IBAction func newsBtn(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let memberDetailsViewController = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        self.navigationController?.pushViewController(memberDetailsViewController, animated:true)
    }
 
    @IBAction func menu_Btn(_ sender: Any) {
       self.revealViewController().revealToggle(animated: true)
    }
    
    func reloadAllApi(){
        
        
       
    }
    
    @IBAction func bulletIn(_ sender: Any) {
        let vc : BulletInVc = storyboard?.instantiateViewController(withIdentifier: "BulletInVc") as! BulletInVc
        let navVC = UINavigationController(rootViewController:vc)
        self.revealViewController().pushFrontViewController(navVC, animated:true)
    }
    
    
    
    
    func  getFeaturedpNewsInfo(){
        
        
        let url = "\(WebService.BaseUrl)\(WebService.FeaturedNews)"
        
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                
                if response.result.isSuccess {
//                    print("response",response)
                    let json = try? JSON(data: response.data!)
                    if json!["status"] == 1 {
                        
                        let newsList = json!["article_list"].array
                        
                        let jsonArr = JSON(newsList!)
                        for (_, object) in jsonArr {
                            let category = object ["category"].stringValue
//                            print("category",category)
                            
                            let post = object ["post_title"].stringValue
                            
                        }
                    }
                }
                
        }
    }
    
    
//    @objc func showSpinningWheel(_ notification: NSNotification) {
//        postid = (notification.userInfo?["id"]!) as? String
//
//        if let id = postid{
//            postid  = id
//            print("catvalue",postid ?? "")
//
//
//
//        }
////        getSubCategrynfo()
//        getCategoryInfo1()
//        getCategoryInfo1()
//
//    }
    
    func  getTopNewsInfo(){
        
        let url = "\(WebService.BaseUrl)\(WebService.TopNews)"
        
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                
                if response.result.isSuccess {
                    
                    let json = try? JSON(data: response.data!)
                    if json!["status"] == 1 {
                        
                        let newsList = json!["news_list"].array
                        
                        let jsonArr = JSON(newsList!)
                        for (_, object) in jsonArr {
                            let category = object ["category"].stringValue
//                            print("category",category)
                            
                            let artcile_arr = object ["article_list"].array
                            
                            //                            let cat_list = object ["article_list"][0]["cat_list"].array
                            //                            print("category", cat_list as Any )
                            
                            for postid in artcile_arr! {
                                
                                let post = postid ["post_title"].stringValue
                                self.titleArr.append(post)
                                // print("post_title", post as Any)
                            }
                            for art_postdate in artcile_arr! {
                                
                                let art_post_date = art_postdate ["art_post_date"].stringValue
                                self.postDateArr.append(art_post_date)
                                //print("art_post_date", art_post_date as Any)
                            }
                            for topnewsImg in artcile_arr!{
                                let image = topnewsImg["post_image"].stringValue
                                if image != "" {
                                    let imageURL: URL = URL(string: image)!
                                    self.newsImagesArr.append(imageURL)
                                }
                            }
                            for shareCount in artcile_arr!{
                                let share_Count = shareCount ["share_count"].stringValue
                                self.shareCountArr.append(share_Count)
                            }
                            for cmmtCount in artcile_arr!{
                                let cmmt_Count = cmmtCount ["comment_count"].stringValue
                                self.cmmtCountArr.append(cmmt_Count)
                            }
                            for likeCount in artcile_arr!{
                                let like_Count = likeCount ["likes_count"].stringValue
                                self.likeCountArr.append(like_Count)
                            }
                            for catlist in artcile_arr! {
                                
                                let categorylists = catlist ["cat_list"].arrayValue
                              //  print("categorylists", categorylists  as Any)
                                for catName in categorylists {
                                    
                                    let cat_Name = catName["cat_name"].stringValue
                                    self.categoryListArr.append(cat_Name)
//                                    print("cat_Name", cat_Name  as Any)
                                    
                                }
                            }
                            
                        }
                    }
                }
                
        }
    }
    
    
    func  getEducationInfo(){
        
        let url = "\(WebService.BaseUrl)\(WebService.EducationNews)"
        
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                
                if response.result.isSuccess {
                    
                    let json = try? JSON(data: response.data!)
                    if json!["status"] == 1 {
                        
                        let newsList = json!["news_list"].array
                        
                        let jsonArr = JSON(newsList!)
                        for (_, object) in jsonArr {
                            let category = object ["category"].stringValue
//                            print("category",category)
                            
                            let artcile_arr = object ["article_list"].array
                            
                            //                            let cat_list = object ["article_list"][0]["cat_list"].array
                            //                            print("category", cat_list as Any )
                            
                            
                            let postid1 = artcile_arr![0...4]
//                            print("post_title",postid1 as Any)
                            
                            
                            for postid in postid1 {
                                
                                let post = postid ["post_title"].stringValue
                                
                                self.titleArr.append(post)
//                                print("post_title", post as Any)
                            }
                            for art_postdate in artcile_arr! {
                                
                                let art_post_date = art_postdate ["art_post_date"].stringValue
                                self.postDateArr.append(art_post_date)
                                //print("art_post_date", art_post_date as Any)
                            }
                            for topnewsImg in artcile_arr!{
                                let image = topnewsImg["post_image"].stringValue
                                if image != ""{
                                    let imageURL: URL = URL(string: image)!
                                    self.newsImagesArr.append(imageURL)
                                }
                            }
                            for shareCount in artcile_arr!{
                                let share_Count = shareCount ["share_count"].stringValue
                                self.shareCountArr.append(share_Count)
                            }
                            for cmmtCount in artcile_arr!{
                                let cmmt_Count = cmmtCount ["comment_count"].stringValue
                                self.cmmtCountArr.append(cmmt_Count)
                                
                            }
                            for likeCount in artcile_arr!{
                                let like_Count = likeCount ["likes_count"].stringValue
                                self.likeCountArr.append(like_Count)
                            }
                            for catlist in artcile_arr! {
                                
                                let categorylists = catlist ["cat_list"].arrayValue
//                                print("categorylists", categorylists  as Any)
                                for catName in categorylists {
                                    
                                    let cat_Name = catName["cat_name"].stringValue
                                    self.categoryListArr.append(cat_Name)
//                                    print("cat_Name", cat_Name  as Any)
                                    
                                }
                            }
                            
                        }
                    }
                }
                
        }
    }
    
    
//    func  getSubCategrynfo(){
//
//        let url = "\(WebService.BaseUrl)\(WebService.SubCategoryList)"
//        let parameters: [String:Any] = ["cat_id" : Int(postid!)]
//
//
//        print("url",url)
//        print("parameters",parameters)
//
//        Alamofire.request(url, method: .post, parameters: parameters , encoding: URLEncoding.default)
//            .responseJSON { response in
//
//                print("response",response)
//                if response.result.isSuccess {
//
//
//                    let json = try? JSON(data: response.data!)
//                    if json!["status"] == 1 {
//
//                        let newsList = json!["article_list"].array
//
//                        let jsonArr = JSON(newsList!)
//
//                        for i in 0 ..< 4
//                        {
//                            // print(jsonArr[i])
//                            let post = jsonArr[i] ["post_title"].stringValue
//                            self.titleArr.append(post)
//                            print("post_title", post as Any)
//
//                            let image = jsonArr[i] ["post_image"].stringValue
//                            if image != ""{
//                                let imageURL: URL = URL(string: image)!
//                                self.newsImagesArr.append(imageURL)
//
//                            }
//
//                            let art_post_date = jsonArr[i]  ["art_post_date"].stringValue
//                            self.postDateArr.append(art_post_date)
//
//
//                            let share_Count = jsonArr[i]["share_count"].stringValue
//                            self.shareCountArr.append(share_Count)
//
//                            let cmmt_Count = jsonArr[i] ["comment_count"].stringValue
//                            self.cmmtCountArr.append(cmmt_Count)
//
//                            let like_Count = jsonArr[i]["likes_count"].stringValue
//                            self.likeCountArr.append(like_Count)
//
//                        }
//
//                    }
//
//                }
//        }
//    }
    func  getCategoryInfo(){
        
        let url = "\(WebService.BaseUrl)\(WebService.CategoryTitle)"
        
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                
                if response.result.isSuccess {
                    
                    let json = try? JSON(data: response.data!)
                    if json!["status"] == 1 {
                        
                        let newsList = json!["category_list"].array
                        
                        let jsonArr = JSON(newsList!)
                        for (_, object) in jsonArr {
                            let category = object ["category_name"].stringValue
                           // print("category",category)
                            
                            let artcile_arr = object ["subcategory_list"].array
                            
                            for postid in artcile_arr! {
                                
//                                let subCategoryName = postid ["subcategory_name"].stringValue
//                                self.subCategoryArr.append(subCategoryName)
//                                //print("categoryAr", self.subCategoryArr.count)
//
//                                let subCategoryId = postid ["subcategory_id"].stringValue
//                                self.subCaId.append(subCategoryId)
//                                print("subCategoryId",subCategoryId)
                            }
                            
                            
                            
                        }
                    }
                }
               
        }
    }
    
    func  getCategoryInfo1(){
        
        let url = "\(WebService.BaseUrl)\(WebService.CategoryTitle)"
        
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                
                if response.result.isSuccess {
                    
                    let json = try? JSON(data: response.data!)
                    if json!["status"] == 1 {
                        
                        let newsList = json!["category_list"].array
                        
                        let jsonArr = JSON(newsList!)
                        for (_, object) in jsonArr {
                            let category = object ["category_name"].stringValue
//                            print("category",category)
                            
                            let artcile_arr = object ["subcategory_list"].array
                            
                            for postid in artcile_arr! {
//
//                                let post = postid ["subcategory_name"].stringValue
//                                self.categoryArr.append(post)
//                                print("categoryAr", self.categoryArr.count)
//
//                                let subCategoryId = postid ["subcategory_id"].stringValue
//                                self.subCaId.append(subCategoryId)
//                                print("subCategoryId",subCategoryId)
                            }
                            
                        }
                    }
                }
                
                
        }
    }

  
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    





extension DashBoardViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0 ) {
           return 2
        } else if (section == 1) {
           return 1
        } else if (section == 2) {
           return 1
        } else if (section == 3) {
           return 1
        } else if (section == 4) {
           return 1
        }else {
           return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as? DashBoardTableViewCell
            cell?.setCollectionViewWith(imageArray: imageArray, newsArray: titleArray)
            return cell!
            
        } else if indexPath.section == 0 && indexPath.row == 1 {
            
            let topNewsCell = tableView.dequeueReusableCell(withIdentifier: "topNewsCell", for: indexPath) as? TopNewsCell
            
            
            topNewsCell?.setTopNewsTableViewWith(image: [], newsTitle: [], newsTag: [], time: [], reads: [], like: [], share: [], comment: [])
            topNewsCell? .layoutMargins = UIEdgeInsets.zero
            topNewsCell? .preservesSuperviewLayoutMargins = false
            topNewsCell?.separatorInset = UIEdgeInsets.zero
            return topNewsCell!
            
        }else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "videosCell", for: indexPath) as? VideosCell
                
                cell?.carbonView = self.storyboard?.instantiateViewController(withIdentifier: "carbonKitVc") as! CarbonKitVc
                self.addChild((cell?.carbonView)!)
                cell?.contentView.addSubview((cell?.carbonView.view)!)
                
                cell?.carbonView.view.frame.size = CGSize(width: self.view.frame.width, height: (128 * 4 ) + 90 )
                cell?.carbonView.didMove(toParent: self)
                cell?.layoutMargins = UIEdgeInsets.zero
                cell?.preservesSuperviewLayoutMargins = false
                cell?.separatorInset = UIEdgeInsets.zero
                return cell!
            }
            
        }  else if indexPath.section == 2 {
            
            if indexPath.row == 0 {
                let magazineCell = tableView.dequeueReusableCell(withIdentifier: "MagazinesCell", for: indexPath) as? MagazinesCell
               
                magazineCell?.carbonView = self.storyboard?.instantiateViewController(withIdentifier: "CarbonKitCollectionVc") as! CarbonKitCollectionVc
                self.addChild((magazineCell?.carbonView)!)
                magazineCell?.contentView.addSubview((magazineCell?.carbonView.view)!)
                magazineCell?.carbonView.view.frame.size = CGSize(width: self.view.frame.width, height: 250 )
                magazineCell?.carbonView.didMove(toParent: self)
                
                return magazineCell!
            }
            
            
        } else if indexPath.section == 3{
            if indexPath.row == 0 {
                
                let educationCell = tableView.dequeueReusableCell(withIdentifier: "EducationCell", for: indexPath) as? EducationCell
                educationCell?.setTopNewsTableViewWith(image: [], newsTitle: [], newsTag: [], time: [], reads: [], like: [], share: [], comment: [])
                
               educationCell? .layoutMargins = UIEdgeInsets.zero
                educationCell? .preservesSuperviewLayoutMargins = false
               educationCell?.separatorInset = UIEdgeInsets.zero
                return educationCell!
                
            } else if indexPath.row == 1{
                
                let educationLblCell = tableView.dequeueReusableCell(withIdentifier: "EducationSeeAllCell", for: indexPath) as? EducationSeeAllCell
                
                educationLblCell? .layoutMargins = UIEdgeInsets.zero
                educationLblCell? .preservesSuperviewLayoutMargins = false
                educationLblCell?.separatorInset = UIEdgeInsets.zero
                return educationLblCell!
            }
            
            
        } else if indexPath.section == 4{
            if indexPath.row == 0{
                
                let avPlayerCell = tableView.dequeueReusableCell(withIdentifier: "AvPlayerCell", for: indexPath) as? AvPlayerCell
//
//                if let path = Bundle.main.path(forResource: "video", ofType: "mp4")
//                {
//                    let video = AVPlayer(url: URL(fileURLWithPath: path))
//                    let videoPlayer = AVPlayerViewController()
//                    videoPlayer.player = video
//
//                    present(videoPlayer, animated: true, completion:
//                        {
//
//                            video.play()
//                    })
//                }
                 let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
                
                player = AVPlayer(url: videoURL!)
                avPlayerController = AVPlayerViewController()
                
                avPlayerController.player = player;
                avPlayerController.view.frame = (avPlayerCell?.videoView.bounds)!;
                avPlayerController.showsPlaybackControls = true
                
                self.addChild(avPlayerController)
                avPlayerCell?.videoView.addSubview(avPlayerController.view);
                player.play()
                
                
                
//                let videoURL = URL(string: "http://perfectrdp.us/newspaper_wp/wp-content/uploads/2018/11/SampleVideo_1280x720_1mb.mp4")
//                let player = AVPlayer(url: videoURL as! URL)
//                let playerLayer = AVPlayerLayer(player: player)
//                playerLayer.frame = (avPlayerCell?.bounds)!
//                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//                avPlayerCell?.videoView.layer.addSublayer(playerLayer)
////                avPlayerCell?.layer.addSublayer(playerLayer)
//                player.play()
                return avPlayerCell!
                
               
                
            } 
        }
        
        
        
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        player.pause()
        
        
    }
  
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
       var headerView = UIView()
         headerView.backgroundColor = UIColor.white
        
        if (section == 0 )
        {
            headerView = UIView.init(frame: CGRect.init(x: 50, y: 0, width: tableView.frame.width, height: 30))
            headerView.backgroundColor = UIColor.white
            let label = UILabel()
            label.frame = CGRect.init(x: 20, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
            label.text = "Top News"
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 20) // my custom font
            label.textColor = UIColor.black
            headerView.addSubview(label)
            return headerView
            
        }
        else if ( section == 1)
        {
            headerView = UIView.init(frame: CGRect.init(x: 50, y: 0, width: tableView.frame.width, height:40))
            headerView.backgroundColor = UIColor.white
            let label = UILabel()
            label.frame = CGRect.init(x: 20, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
            label.text = "Videos"
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 20) // my custom font
            label.textColor = UIColor.black
            headerView.addSubview(label)
            return headerView
        }else if ( section == 2)
        {
            headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.frame.size.height))
            headerView.backgroundColor = UIColor.white
            
            let title = UILabel()
            title.translatesAutoresizingMaskIntoConstraints = false
            title.text = "Magazines"
            title.font =  UIFont(name: "HelveticaNeue-Bold", size: 20) 
            headerView.addSubview(title)
            
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("See All >", for: .normal)
            
            button.addTarget(self, action: #selector(seeAllBtn(sender:)), for: .touchUpInside)

            
            button.setTitleColor(UIColor.red, for: .normal)
            headerView.addSubview(button)
            
            var headerViews = Dictionary<String, UIView>()
            headerViews["title"] = title
            headerViews["button"] = button
            
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[title]-[button]-15-|", options: [], metrics: nil, views: headerViews))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[title]-|", options: [], metrics: nil, views: headerViews))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[button]-|", options: [], metrics: nil, views: headerViews))
            
        }else if (section == 3){
            headerView = UIView.init(frame: CGRect.init(x: 50, y: 0, width: tableView.frame.width, height:40))
            headerView.backgroundColor = UIColor.white
            let label = UILabel()
            label.frame = CGRect.init(x: 20, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
            label.text = "Education"
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 20) // my custom font
            label.textColor = UIColor.black
            headerView.addSubview(label)
            return headerView
        } else if (section == 4){
            
            headerView = UIView.init(frame: CGRect.init(x: 50, y: 0, width: tableView.frame.width, height: 40))
            headerView.backgroundColor = UIColor.white
            let label = UILabel()
            label.frame = CGRect.init(x: 20, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
            label.text = "Flash News"
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 20) // my custom font
            label.textColor = UIColor.black
            headerView.addSubview(label)
            return headerView
            
        }
        return headerView
 
    }
    @objc func seeAllBtn(sender: UIButton) {
        let vc :  MoviesOverAllVc = storyboard?.instantiateViewController(withIdentifier: "MoviesOverAllVc") as! MoviesOverAllVc
        let navVC = UINavigationController(rootViewController:vc)
        self.revealViewController().pushFrontViewController(navVC, animated:true)
        
        
       
        
//        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
//        let memberDetailsViewController = storyBoard.instantiateViewController(withIdentifier:"MoviesOverAllVc") as! MoviesOverAllVc
//        self.navigationController?.pushViewController(memberDetailsViewController, animated:true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 )
        {
            return 40
        }
        else if ( section == 1)
        {
            return 40
        }else if ( section == 2)
        {
            return 40
        }else if (section == 3){
            return 40
        } else if (section == 4){
            return 40
            
        }
        return 10
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            if  indexPath.row == 0 {
                return 240
                
            } else if indexPath.row == 1 {
                
                return (128 * 4) + 10
                
            }
            
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                
               return (128 * 4) + 90
            }
            
        } else if indexPath.section == 2 {
            
            if indexPath.row == 0 {
            
                return   250
            }
            
        }else if indexPath.section == 3 {
            
            if indexPath.row == 0 {
                
                return (128 * 5) + 70
            } else if indexPath.row == 1{
                
                return 50
            }
            
        } else if indexPath.section == 4 {
            
            //if indexPath.row == 0 {
            
            return 350
            //}
            
        }  else {
            return UITableView.automaticDimension
        }
    
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            
            if  indexPath.row == 0 {
                return 240
                
            } else if indexPath.row == 1 {
                
                return (128 * 4) + 90
                
            }
            
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                
                return (128 * 4) + 70
            }
            
            
            
        } else if indexPath.section == 2 {
            
            //if indexPath.row == 0 {
            
            return 250
            //}
            
        }else if indexPath.section == 3 {
            
            if indexPath.row == 0 {
                
                return (128 * 5) + 70
            } else if indexPath.row == 1{
                
                return 50
            }
            
        } else if indexPath.section == 4 {
            
            //if indexPath.row == 0 {
            
            return 350
            //}
            
        }  else {
            return UITableView.automaticDimension
        }
        
        return UITableView.automaticDimension
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    
    }
    
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        
        switch position {
            
        case FrontViewPosition.leftSideMostRemoved:
            print("LeftSideMostRemoved")
            
        case FrontViewPosition.leftSideMost:
            print("LeftSideMost")
            
        case FrontViewPosition.leftSide:
            print("LeftSide")
            
        case FrontViewPosition.right:
            print("right")
            self.view.addSubview(revealViewButton)
            
        case FrontViewPosition.left:
            print("left")
            self.revealViewButton.removeFromSuperview()
            
        case FrontViewPosition.rightMost:
            print("RightMost")
            
        case FrontViewPosition.rightMostRemoved:
            print("RightMostRemoved")
            
        }
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            menuView.isHidden = true
        }else{
           menuView.isHidden = false
        }

    }
   
    
    
    
    
}


