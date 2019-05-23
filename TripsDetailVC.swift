//
//  TripsDetailVC.swift
//  PocketTrips
//
//  Created by apple on 06/03/19.
//  Copyright © 2019 Smitiv. All rights reserved.
//

import UIKit
import Mapbox
import Popover

// MGLPointAnnotation subclass
class MyCustomPointAnnotation: MGLPointAnnotation {
    var willUseImage: Bool = true
}
// end MGLPointAnnotation subclass


class TripsDetailVC: UIViewController, UIScrollViewDelegate {

    let LocationGeocoder = CLGeocoder.init()
    var lat = Double()
    var long = Double()
    
    var trail_id = Int()
    
    let APP = UIApplication.shared.delegate as! AppDelegate
    
    var trailsIntro = TrailIntroResponse()
    var channel_price_high = ChannelPriceHigh()
    var trail_hotspots = [TrailHotspots]()
    var latLongArr = NSMutableArray.init()
    
    var hotspotGeoData = [HotspotGeoDataResponse]()
    var currentPage = Int()
    
    var allTrailsList = [TrailsList]()
    var allTrailsCurrentList = [TrailsList]()
    
    var screenId = "0012"

    var currentStyle = UIStatusBarStyle.default
    
    var popoverTitleArr = ["All Trips","Favourite Trips"]

    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.auto),
        .cornerRadius(13),
        .blackOverlayColor(UIColor.black.withAlphaComponent(0.16))
    ]
    let popoverTblView = UITableView.init()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentStyle
    }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var rightTableview: UITableView!
    
    // Left view
    @IBOutlet weak var letfView: UIView!
    @IBOutlet weak var leftViewWidth: NSLayoutConstraint!
    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var popoverBtn: UIButton!
    
    var layoutDic = [String:AnyObject]()
    
    var isExpanded = Bool()
    
    //MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()

        currentStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()

        currentPage = 0
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        rightTableview.separatorStyle = .none
        
        isExpanded = false
        
        popoverTblView.delegate = self
        popoverTblView.dataSource = self
        popoverTblView.isScrollEnabled = false
        
        self.leftViewWidth.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        self.rightTableview.setContentOffset(.zero, animated: true)
        self.leftTableView.tableFooterView = UIView(frame: CGRect.zero)
        callTrailHotspotGeoDataApi(trail_id: trail_id)
    }
    
    func toExpandOrCollapseView()
    {
        if isExpanded
        {
            self.leftViewWidth.constant = 0
            self.isExpanded = false
            self.rightTableview.reloadData()
        }
        else
        {
            self.leftViewWidth.constant = 320
            self.isExpanded = true
            self.rightTableview.reloadData()
        }
    }
    
    func setupMapView(mapView: MGLMapView)
    {
        for i in 0 ..< trail_hotspots.count
        {
            let latLong = (Double("\(trail_hotspots[i].hotspot_lat!)")!, Double("\(trail_hotspots[i].hotspot_lon!)")!)
            latLongArr.add(latLong)
            
            if i == 0
            {
                lat = Double("\(trail_hotspots[i].hotspot_lat!)")!
                long = Double("\(trail_hotspots[i].hotspot_lon!)")!
            }
        }
        
        mapView.styleURL = MGLStyle.streetsStyleURL
       
        for i in 0..<latLongArr.count
        {
            setAnnotations(latLong: latLongArr[i] as! (Double, Double), mapView: mapView)
        }
        
        let locValue:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long);
        let camera = MGLMapCamera(lookingAtCenter: locValue, fromDistance: 1500, pitch: 15, heading: 360)
        mapView.fly(to: camera, withDuration: 2, peakAltitude: 3000, completionHandler: nil)
    }
    
    func setAnnotations(latLong: (Double, Double), mapView: MGLMapView)
    {
        let locValue:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latLong.0, latLong.1);
        let pointD = MyCustomPointAnnotation()
        pointD.coordinate = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        mapView.addAnnotation(pointD)
    }
    
    func setTypeView(baseView: UIView)
    {
        // Type Image View
        let typeImgView = UIImageView.init()
        typeImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["typeImgView"] = typeImgView
        typeImgView.backgroundColor = UIColor.white
        typeImgView.image = #imageLiteral(resourceName: "tag")
        typeImgView.contentMode = .scaleAspectFit
        baseView.addSubview(typeImgView)
        if Extensions.isCurrentDeviceIsiPad()
        {
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typeImgView(70)]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[typeImgView(70)]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        else
        {
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typeImgView(56)]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[typeImgView(56)]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        
        // Type Line View
        let typeLineView = UIView.init()
        typeLineView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["typeLineView"] = typeLineView
        typeLineView.backgroundColor = UIColor.lightGray
        baseView.addSubview(typeLineView)
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typeLineView(1)]-(5)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[typeImgView]-(8)-[typeLineView]-(15)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        
        // Type Value Label
        let typeValueLbl = UILabel.init()
        typeValueLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["typeValueLbl"] = typeValueLbl
        typeValueLbl.backgroundColor = UIColor.white
        typeValueLbl.text = "\(channel_price_high.product_type!)"
        typeValueLbl.font = UIFont.setAppFontSemiBold(17)
        typeValueLbl.textColor = UIColor.darkGray
        baseView.addSubview(typeValueLbl)
        if Extensions.isCurrentDeviceIsiPad()
        {
            typeValueLbl.font = UIFont.setAppFontSemiBold(20)
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typeValueLbl(34)]-(0)-[typeLineView]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        else
        {
            typeValueLbl.font = UIFont.setAppFontSemiBold(16)
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typeValueLbl(25)]-(0)-[typeLineView]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[typeImgView]-(8)-[typeValueLbl]-(5)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        
        // Type Title Label
        let typeTitleLbl = UILabel.init()
        typeTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["typeTitleLbl"] = typeTitleLbl
        typeTitleLbl.backgroundColor = UIColor.white
        typeTitleLbl.text = "Type"
        typeTitleLbl.textColor = UIColor.lightGray
        baseView.addSubview(typeTitleLbl)
        if Extensions.isCurrentDeviceIsiPad()
        {
            typeTitleLbl.font = UIFont.setAppFontSemiBold(20)
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typeTitleLbl(34)]-(0)-[typeValueLbl]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        else
        {
            typeTitleLbl.font = UIFont.setAppFontSemiBold(16)
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typeTitleLbl(25)]-(0)-[typeValueLbl]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[typeImgView]-(8)-[typeTitleLbl]-(5)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
    }
    
    func setPlaceView(baseView: UIView)
    {
        // Place Image View
        let placeImgView = UIImageView.init()
        placeImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["placeImgView"] = placeImgView
        placeImgView.backgroundColor = UIColor.white
        placeImgView.image = #imageLiteral(resourceName: "places")
        placeImgView.contentMode = .scaleAspectFit
        baseView.addSubview(placeImgView)
        if Extensions.isCurrentDeviceIsiPad()
        {
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[placeImgView(70)]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[placeImgView(70)]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        else
        {
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[placeImgView(56)]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[placeImgView(56)]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        
        // Place Line View
        let placeLineView = UIView.init()
        placeLineView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["placeLineView"] = placeLineView
        placeLineView.backgroundColor = UIColor.lightGray
        baseView.addSubview(placeLineView)
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[placeLineView(1)]-(5)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[placeImgView]-(8)-[placeLineView]-(15)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        
        // Place Value Label
        let placeValueLbl = UILabel.init()
        placeValueLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["placeValueLbl"] = placeValueLbl
        placeValueLbl.backgroundColor = UIColor.white
        if "\(trailsIntro.places!)" == "" || "\(trailsIntro.places!)" == " " || "\(trailsIntro.places!)" == "0"
        {
            placeValueLbl.text = " - "
        }
        if "\(trailsIntro.places!)" == "1"
        {
            placeValueLbl.text = "\(trailsIntro.places!) place"
        }
        else
        {
            placeValueLbl.text = "\(trailsIntro.places!) places"
        }
        placeValueLbl.textColor = UIColor.darkGray
        placeValueLbl.font = UIFont.setAppFontSemiBold(17)
        baseView.addSubview(placeValueLbl)
        if Extensions.isCurrentDeviceIsiPad()
        {
            placeValueLbl.font = UIFont.setAppFontSemiBold(20)
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[placeValueLbl(34)]-(0)-[placeLineView]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        else
        {
            placeValueLbl.font = UIFont.setAppFontSemiBold(16)
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[placeValueLbl(25)]-(0)-[placeLineView]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[placeImgView]-(8)-[placeValueLbl]-(5)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        
        // Place Title Label
        let placeTitleLbl = UILabel.init()
        placeTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["placeTitleLbl"] = placeTitleLbl
        placeTitleLbl.backgroundColor = UIColor.white
        placeTitleLbl.text = "Places"
        placeTitleLbl.textColor = UIColor.lightGray
        baseView.addSubview(placeTitleLbl)
        if Extensions.isCurrentDeviceIsiPad()
        {
            placeTitleLbl.font = UIFont.setAppFontSemiBold(20)
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[placeTitleLbl(34)]-(0)-[placeValueLbl]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        else
        {
            placeTitleLbl.font = UIFont.setAppFontSemiBold(16)
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[placeTitleLbl(25)]-(0)-[placeValueLbl]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[placeImgView]-(8)-[placeTitleLbl]-(5)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
    }
    
    func setDurationView(baseView: UIView)
    {
        // duration Image View
        let durationImgView = UIImageView.init()
        durationImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["durationImgView"] = durationImgView
        durationImgView.backgroundColor = UIColor.white
        durationImgView.image = #imageLiteral(resourceName: "duration")
        durationImgView.contentMode = .scaleAspectFit
        baseView.addSubview(durationImgView)
        if Extensions.isCurrentDeviceIsiPad()
        {
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[durationImgView(70)]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[durationImgView(70)]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        else
        {
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[durationImgView(56)]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[durationImgView(56)]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        
        // duration Line View
        let durationLineView = UIView.init()
        durationLineView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["durationLineView"] = durationLineView
        durationLineView.backgroundColor = UIColor.lightGray
        baseView.addSubview(durationLineView)
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[durationLineView(1)]-(5)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[durationImgView]-(8)-[durationLineView]-(15)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        
        // duration Value Label
        let durationValueLbl = UILabel.init()
        durationValueLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["durationValueLbl"] = durationValueLbl
        durationValueLbl.backgroundColor = UIColor.white
        if "\(trailsIntro.hours!)" == "" || "\(trailsIntro.hours!)" == " " || "\(trailsIntro.hours!)" == "0"
        {
            durationValueLbl.text = " - "
        }
        if "\(trailsIntro.hours!)" == "1"
        {
            durationValueLbl.text = "\(trailsIntro.hours!) Hour"
        }
        else
        {
            durationValueLbl.text = "\(trailsIntro.hours!) Hours"
        }
        durationValueLbl.textColor = UIColor.darkGray
        durationValueLbl.font = UIFont.setAppFontSemiBold(17)
        baseView.addSubview(durationValueLbl)
        if Extensions.isCurrentDeviceIsiPad()
        {
            durationValueLbl.font = UIFont.setAppFontSemiBold(20)
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[durationValueLbl(34)]-(0)-[durationLineView]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        else
        {
            durationValueLbl.font = UIFont.setAppFontSemiBold(16)
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[durationValueLbl(25)]-(0)-[durationLineView]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[durationImgView]-(8)-[durationValueLbl]-(5)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        
        // duration Title Label
        let durationTitleLbl = UILabel.init()
        durationTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["durationTitleLbl"] = durationTitleLbl
        durationTitleLbl.backgroundColor = UIColor.white
        durationTitleLbl.text = "Duration"
        durationTitleLbl.textColor = UIColor.lightGray
        baseView.addSubview(durationTitleLbl)
        if Extensions.isCurrentDeviceIsiPad()
        {
            durationTitleLbl.font = UIFont.setAppFontSemiBold(20)
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[durationTitleLbl(34)]-(0)-[durationValueLbl]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        else
        {
            durationTitleLbl.font = UIFont.setAppFontSemiBold(16)
            baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[durationTitleLbl(25)]-(0)-[durationValueLbl]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
        }
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[durationImgView]-(8)-[durationTitleLbl]-(5)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
    }
    
    //MARK: - Actions
    @objc func backBtnAction(_ sender: UIButton){
        
        self.navigationController?.popViewController(animated: true)
        
    }
    @objc func shareBtnAction(_ sender: UIButton){
        
        // text to share
        let text = "This is some text that I want to share."
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    @objc func favBtnAction(_ sender: UIButton){
        
        if sender.isSelected
        {
            sender.isSelected = false
        }
        else
        {
            sender.isSelected = true
        }
        rightTableview.reloadData()
    }
    
    @objc func previousBtnAction(_ sender: Any) {
        
        currentPage = currentPage - 1
        //setupTrailIntroPages()
        rightTableview.reloadData()
    }
    
    @objc func nextBtnAction(_ sender: Any) {
        
        currentPage = currentPage + 1
        //setupTrailIntroPages()
        rightTableview.reloadData()
    }
    
    @objc func goBtnAction(_ sender: Any) {
        
        self.navigationController?.isNavigationBarHidden = false
        let vc : HotspotDetailsVC = storyboard?.instantiateViewController(withIdentifier: "HotspotDetailsVC") as! HotspotDetailsVC
        vc.hotspotGeoData = self.hotspotGeoData
        vc.headerTitle = "\(trailsIntro.trail_name!)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func navBtnAction(_ sender: Any) {
        
        toExpandOrCollapseView()
        
    }
    
    @IBAction func popoverAction(_ sender: Any) {
        
        let aView = UIView(frame: CGRect(x: 0, y: 10, width: 240, height: 100))

        self.popoverTblView.frame = CGRect(x: 0, y: 10, width: 240, height: 100)
        aView.addSubview(self.popoverTblView)

        // POPOVER
        self.popover = Popover(options: self.popoverOptions)
        self.popover.willShowHandler = {
            print("willShowHandler")
            self.popoverTblView.reloadData()
        }
        self.popover.didShowHandler = {
            print("didDismissHandler")
        }
        self.popover.willDismissHandler = {
            print("willDismissHandler")
        }
        self.popover.didDismissHandler = {
            print("didDismissHandler")
        }
        self.popover.show(aView, fromView: self.popoverBtn)
    }
    
    
    //MARK: - Api Calls
    func callTrailInfoApi(trail_id: Int) {
        
        let paramDic:NSDictionary = ["trail_id":"\(trail_id)"]
        
        MyTripsProvider.Instance.trailIntro(withURL: "\(WebServiceURL.V1BaseURL)\(WebServiceURL.TrailIntro)", parameters: paramDic as! Dictionary<String, Any>, screen_id: screenId, event_id: "06") { (message, response) in
            
            if message != nil {
                print(message!)
            }
            else {
                print(response!)
                self.trailsIntro = response!
                self.channel_price_high = (response?.channel_price_high)!
                self.trail_hotspots = (response?.trail_hotspots)!
               // self.setValues()
                self.rightTableview.reloadData()
                self.rightTableview.scrollsToTop = true
                self.callTrailHotspotGeoDataApi(trail_id: trail_id)
            }
        }
    }
    
    func callTrailHotspotGeoDataApi(trail_id: Int) {
        
        let paramDic:NSDictionary = ["trail_id":"\(trail_id)"]
        print(paramDic)
        
        MyTripsProvider.Instance.trail_hotspot_geodata(withURL: "\(WebServiceURL.V1BaseURL)\(WebServiceURL.Trail_Hotspot_Geodata)", parameters: paramDic as! Dictionary<String, Any>, screen_id: screenId, event_id: "07") { (message, response) in
            
            if message != nil {
                print(message!)
            }
            else {
                print(response!)
                
                self.hotspotGeoData = response!
                
                if Extensions.isCurrentDeviceIsiPad()
                {
                    self.callListOfTrailsApi()
                }
            }
        }
    }
    
    func callListOfTrailsApi() {
        
        print("\(Extensions.getProducerId())")
        let paramDic:NSDictionary = ["producer_id":"\(Extensions.getProducerId())"]
        
        MyTripsProvider.Instance.listOfTrails(withURL: "\(WebServiceURL.V1BaseURL)\(WebServiceURL.ListOfTrails)", parameters: paramDic as! Dictionary<String, Any>, screen_id: screenId, event_id: "05") { (message, response) in
            
            if message != nil {
               // self.removeLoader()
                self.view.makeToast("\(message!)")
            }
            else {
                self.allTrailsList = response!
                self.allTrailsCurrentList = self.allTrailsList
                self.leftTableView.reloadData()
              //  self.removeLoader()
            }
        }
    }
}

//MARK: - Delegates -
extension TripsDetailVC: UITableViewDelegate, UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView == leftTableView
        {
            return 1
        }
        else if tableView == popoverTblView
        {
            return 1
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == leftTableView
        {
            return allTrailsCurrentList.count
        }
        else if tableView == popoverTblView
        {
            return popoverTitleArr.count
        }
        else
        {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == leftTableView
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TripsDetailsLeftCell
            cell.selectionStyle = .none
            
            cell.trailsImage.layer.borderColor = UIColor.lightGray.cgColor
            cell.trailsImage.layer.borderWidth = 0.5
            cell.trailsImage.layer.cornerRadius = 5
            cell.trailsImage.clipsToBounds = true
            
            cell.trailsTitleLbl.text = allTrailsCurrentList[indexPath.row].trail_name
            cell.downloadsLbl.text = allTrailsCurrentList[indexPath.row].trail_downloads! + " Downloads"
            
            let str = allTrailsCurrentList[indexPath.row].trail_image
            if str != nil {
                self.downloadFromServer(imgView: cell.trailsImage, ImageURL: "\(str!)")
            }
            
            return cell
        }
        else if tableView == popoverTblView
        {
            var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "catCell")
            if cell == nil
            {
                cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "catCell")
            }
            for subView in cell.subviews
            {
                subView.removeFromSuperview()
            }
            cell.selectionStyle = .none
            
            let label = UILabel.init(frame: CGRect(x: 15, y: 0, width: cell.frame.width, height: cell.frame.height))
            label.text = "\(popoverTitleArr[indexPath.row])"
            label.font = UIFont.setAppFontRegular(17)
            cell.addSubview(label)
            
            return cell
        }
        else
        {
            switch indexPath.row
            {
            case 0: //MARK: Trail title
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell0", for: indexPath) as! Cell0
                cell.selectionStyle = .none
                cell.trailTitleLbl.text = "\(trailsIntro.trail_name!)"
                if Extensions.isCurrentDeviceIsiPad()
                {
                    cell.backBtn.isHidden = true // hides for ipad
                    cell.trailTitleLbl.font = UIFont.setAppFontSemiBold(38)
                    if isExpanded {
                        
                        cell.expandViewWidth.constant = 0
                        cell.expandBtnWidth.constant = 0
                        cell.expandImg.isHidden = true
                    }
                    else {
                        
                        cell.expandViewWidth.constant = 100
                        cell.expandBtnWidth.constant = 100
                        cell.expandImg.isHidden = false
                    }
                }
                else
                {
                    cell.trailTitleLbl.font = UIFont.setAppFontSemiBold(32)
                    cell.backBtn.isHidden = false
                    cell.expandImg.isHidden = true
                    cell.expandViewWidth.constant = 0
                    cell.expandBtnWidth.constant = 0
                }
                cell.backBtn.addTarget(self, action: #selector(backBtnAction(_:)), for: .touchUpInside)
                cell.favBtn.addTarget(self, action: #selector(favBtnAction(_:)), for: .touchUpInside)
                cell.shareBtn.addTarget(self, action: #selector(shareBtnAction(_:)), for: .touchUpInside)
                if cell.favBtn.isSelected
                {
                    cell.favBtn.imageView?.image = #imageLiteral(resourceName: "favorite-focus")
                }
                else
                {
                    cell.favBtn.imageView?.image = #imageLiteral(resourceName: "favorite-unfocus")
                }
                return cell
                
            case 1://MARK: Trial image
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! Cell1
                cell.selectionStyle = .none
                let imgStr = trailsIntro.trail_image
                downloadFromServer(imgView: cell.trailImage, ImageURL: "\(imgStr!)")
                return cell
                
            case 2://MARK: Type, place, duration
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! Cell2
                cell.selectionStyle = .none
                
                
                // Type View
                let typeView = UIView.init()
                typeView.translatesAutoresizingMaskIntoConstraints = false
                layoutDic["typeView"] = typeView
                typeView.backgroundColor = UIColor.white
                cell.addSubview(typeView)
                
                // Place View
                let placeView = UIView.init()
                placeView.translatesAutoresizingMaskIntoConstraints = false
                layoutDic["placeView"] = placeView
                placeView.backgroundColor = UIColor.white
                cell.addSubview(placeView)
                
                // Duration View
                let durationView = UIView.init()
                durationView.translatesAutoresizingMaskIntoConstraints = false
                layoutDic["durationView"] = durationView
                durationView.backgroundColor = UIColor.white
                cell.addSubview(durationView)
                
                if isExpanded
                {
                    let viewWidth = cell.frame.size.width / 2
                    let widthValue = viewWidth
                    let metrics = ["widthValue": widthValue]
                    
                    //type view
                    cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[typeView(85)]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
                    cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[typeView]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
                    
                    //place view
                    cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typeView]-(0)-[placeView]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
                    cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[placeView(widthValue)]", options: NSLayoutFormatOptions(rawValue:0), metrics: metrics, views: layoutDic))
                    
                    //duration view
                    cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typeView]-(0)-[durationView]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
                    cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[placeView]-(0)-[durationView(widthValue)]", options: NSLayoutFormatOptions(rawValue:0), metrics: metrics , views: layoutDic))
                }
                else
                {
                    if !Extensions.isCurrentDeviceIsiPad()
                    {
                        let viewWidth = cell.frame.size.width / 2
                        let widthValue = viewWidth
                        let metrics = ["widthValue": widthValue]
                        
                        //type view
                        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[typeView(60)]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
                        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[typeView]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
                        
                        //place view
                        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typeView]-(0)-[placeView(60)]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
                        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[placeView(widthValue)]", options: NSLayoutFormatOptions(rawValue:0), metrics: metrics, views: layoutDic))
                        
                        //duration view
                        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typeView]-(0)-[durationView(60)]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
                        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[placeView]-(0)-[durationView(widthValue)]", options: NSLayoutFormatOptions(rawValue:0), metrics: metrics , views: layoutDic))
                    }
                    else
                    {
                        let viewWidth = cell.frame.size.width / 3
                        let widthValue = viewWidth
                        let metrics = ["widthValue": widthValue]
                        
                        //type view
                        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[typeView]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
                        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[typeView(widthValue)]", options: NSLayoutFormatOptions(rawValue:0), metrics: metrics, views: layoutDic))
                        
                        //place view
                        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[placeView]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
                        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[typeView]-(0)-[placeView(widthValue)]", options: NSLayoutFormatOptions(rawValue:0), metrics: metrics, views: layoutDic))
                        
                        //duration view
                        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[durationView]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
                        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[placeView]-(0)-[durationView]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: layoutDic))
                    }
                }
                
                setTypeView(baseView: typeView)
                setPlaceView(baseView: placeView)
                setDurationView(baseView: durationView)
                
                return cell
                
            case 3: //MARK: description title
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! Cell3
                cell.selectionStyle = .none
                cell.descriptionTitleLbl.text = "Description"
                if Extensions.isCurrentDeviceIsiPad()
                {
                    cell.descriptionTitleLbl.font = UIFont.setAppFontBold(28)
                }
                else
                {
                    cell.descriptionTitleLbl.font = UIFont.setAppFontBold(20)
                }
                return cell
                
            case 4://MARK: description value lbl
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath) as! Cell4
                cell.selectionStyle = .none
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = trailsIntro.trail_description
                cell.textLabel?.font = UIFont.setAppFontRegular(Extensions.isCurrentDeviceIsiPad() ? 20 : 16)
                
                return cell
                
            case 5://MARK: trail hotspots
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath) as! Cell5
                cell.selectionStyle = .none
                cell.expectTitleLbl?.font = UIFont.setAppFontBold(Extensions.isCurrentDeviceIsiPad() ? 28 : 20)
                cell.hotspotCountLbl.font = UIFont.setAppFontSemiBold(Extensions.isCurrentDeviceIsiPad() ? 23 : 20)
               
                for i in 0 ..< trail_hotspots.count
                {
                    ImageDownlaod.downloadFromServerStoreCache(ImageURL: "\(trail_hotspots[i].hotspot_image_urls![0])")
                    cell.hotspotCountLbl.text = "Letter Writer Mural (" + "\(currentPage + 1)" + "/" + "\(trail_hotspots.count)" + ")"
                    
                    if currentPage == i
                    {
                        downloadFromServer(imgView: cell.hotspotImg, ImageURL: "\(trail_hotspots[i].hotspot_image_urls![0])")
                    }
                }
                return cell
                
            case 6://MARK: trail hotspots lbl
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell6", for: indexPath) as! Cell6
                cell.selectionStyle = .none
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = UIFont.setAppFontRegular(Extensions.isCurrentDeviceIsiPad() ? 20 : 16)
                
                for i in 0 ..< trail_hotspots.count
                {
                    if currentPage == i
                    {
                        cell.textLabel?.text = "\(trail_hotspots[i].hotspot_description!)"
                    }
                }
                return cell
                
            case 7://MARK: next previous
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell7", for: indexPath) as! Cell7
                cell.selectionStyle = .none
                
                cell.nextImgBtn.addTarget(self, action: #selector(nextBtnAction(_:)), for: .touchUpInside)
                cell.nextBtn.addTarget(self, action: #selector(nextBtnAction(_:)), for: .touchUpInside)
                
                cell.previousImgBtn.addTarget(self, action: #selector(previousBtnAction(_:)), for: .touchUpInside)
                cell.previousBtn.addTarget(self, action: #selector(previousBtnAction(_:)), for: .touchUpInside)
                
                cell.nextBtn.titleLabel?.font = UIFont.setAppFontBold(Extensions.isCurrentDeviceIsiPad() ? 20 : 18)
                cell.previousBtn.titleLabel?.font = UIFont.setAppFontBold(Extensions.isCurrentDeviceIsiPad() ? 20 : 18)
                
                if currentPage >= 0 && (currentPage + 1) < trail_hotspots.count
                {
                    print(currentPage, trail_hotspots.count)
                    cell.nextBtn.isEnabled = true
                    cell.nextImgBtn.isEnabled = true
                    
                    cell.nextBtn.setTitleColor(UIColor.getAppButtonColor(), for: .normal)
                    cell.nextImgBtn.imageView?.image = #imageLiteral(resourceName: "next-focus")
                }
                else
                {
                    cell.nextBtn.isEnabled = false
                    cell.nextImgBtn.isEnabled = false
                    
                    cell.nextBtn.setTitleColor(UIColor.getAppLightGrayColor(), for: .normal)
                    cell.nextImgBtn.imageView?.image = #imageLiteral(resourceName: "next-unfocus")
                }
                
                if currentPage <= 0
                {
                    cell.previousBtn.isEnabled = false
                    cell.previousImgBtn.isEnabled = false
                    
                    cell.previousBtn.setTitleColor(UIColor.getAppLightGrayColor(), for: .normal)
                    cell.previousImgBtn.imageView?.image = #imageLiteral(resourceName: "previous-unfocus")
                }
                else
                {
                    cell.previousBtn.isEnabled = true
                    cell.previousImgBtn.isEnabled = true
                    
                    cell.previousBtn.setTitleColor(UIColor.getAppButtonColor(), for: .normal)
                    cell.previousImgBtn.imageView?.image = #imageLiteral(resourceName: "previous-focus")
                }
                
                return cell
                
            case 8://MARK: mapview
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell8", for: indexPath) as! Cell8
                cell.selectionStyle = .none
                self.setupMapView(mapView: cell.mapView)
                return cell
                
            case 9://MARK: go btn
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell9", for: indexPath) as! Cell9
                cell.selectionStyle = .none
                
                cell.goBtn.layer.cornerRadius = cell.goBtn.frame.size.height / 2
                cell.goBtn.clipsToBounds = true
                cell.goBtn.addTarget(self, action: #selector(goBtnAction(_:)), for: .touchUpInside)
                
                cell.goBtn.titleLabel?.font = UIFont.setAppFontSemiBold(Extensions.isCurrentDeviceIsiPad() ? 24 : 18)
                
                return cell
                
            default:
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == leftTableView
        {
            return 120
        }
        else if tableView == popoverTblView
        {
            return 50
        }
        else
        {
            switch indexPath.row
            {
            case 0:
                return Extensions.isCurrentDeviceIsiPad() ? (isExpanded ? 136 : 136) : 165
            case 1:
                return Extensions.isCurrentDeviceIsiPad() ? (isExpanded ? 320 : 330) : 208
            case 2:
                return Extensions.isCurrentDeviceIsiPad() ? (isExpanded ? 170: 90) : 125
            case 3:
                return Extensions.isCurrentDeviceIsiPad() ? (isExpanded ? 60 : 60) : 50
            case 4:
                return UITableViewAutomaticDimension
            case 5:
                return Extensions.isCurrentDeviceIsiPad() ? (isExpanded ? 510 : 600) : 320
            case 6:
                return UITableViewAutomaticDimension
            case 7:
                return Extensions.isCurrentDeviceIsiPad() ? (isExpanded ? 100 : 100) : 70
            case 8:
                return Extensions.isCurrentDeviceIsiPad() ? (isExpanded ? 300 : 520) : 278
            case 9:
                return Extensions.isCurrentDeviceIsiPad() ? (isExpanded ? 320 : 225) : 180
            default:
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == leftTableView
        {
            self.trail_id = self.allTrailsCurrentList[indexPath.row].trail_id!
            self.callTrailInfoApi(trail_id: self.allTrailsCurrentList[indexPath.row].trail_id!)
        }
        else if tableView == popoverTblView
        {
            print("All trips / Fav Trips")
            self.popover.dismiss()
        }
    }
}

extension TripsDetailVC: MGLMapViewDelegate
{
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        return nil
    }
    
    // Allow callout view to appear when an annotation is tapped.
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}
