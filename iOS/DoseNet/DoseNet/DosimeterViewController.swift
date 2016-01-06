//
//  DosimeterViewController.swift
//  DoseNet
//
//  Created by Navrit Bal on 30/12/2015.
//  Copyright © 2015 navrit. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import JLToast
import CoreLocation

let url:String! = "https://radwatch.berkeley.edu/sites/default/files/output.geojson?"
    + randomAlphaNumericString(32)
var userLoc:CLLocationCoordinate2D!
var numberOfDosimeters:Int! = 0
var dosimeters : [Dosimeter] = []

func randomAlphaNumericString(length: Int) -> String {
    
    let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let allowedCharsCount = UInt32(allowedChars.characters.count)
    var randomString = ""
    
    for _ in (0..<length) {
        let randomNum = Int(arc4random_uniform(allowedCharsCount))
        let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
        randomString += String(newCharacter)
    }
    
    return randomString
}


class DosimeterViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBAction func cancelToDosimeterViewController(segue: UIStoryboardSegue){
        
    }
    
    var items = [String]()
    var itemsDistances = [Double]()
    var newitem: String = ""
    let locationManager = CLLocationManager()
    
    func main() {
        SwiftSpinner.show("Loading...", animated: true)
        initCLLocationManager()
        networkRequest()
    }
    
    func networkRequest() {
        Alamofire.request(.GET, url).responseJSON { response in
            switch response.result {
                
            case .Success:
                
                if let value = response.result.value {
                    let features:JSON = JSON(value)["features"]
                    var lastDistance = CLLocationDistance(20037500)
                    
                    numberOfDosimeters = features.count
                    
                    for i in 0..<numberOfDosimeters {
                        let this:JSON = features[i]
                        let prop:JSON = this["properties"]
                        let name:JSON = prop["Name"]
                        let dose_uSv:JSON = prop["Latest dose (&microSv/hr)"]
                        let dose_mRem:JSON = prop["Latest dose (mREM/hr)"]
                        let time:JSON = prop["Latest measurement"]
                        
                        let lon = this["geometry"]["coordinates"][0]
                        let lat = this["geometry"]["coordinates"][1]
                        let CLlon = CLLocationDegrees(lon.double!)
                        let CLlat = CLLocationDegrees(lat.double!)
                        
                        let fromLoc = CLLocation(latitude: CLlat, longitude: CLlon)
                        let toLoc = CLLocation(latitude: userLoc.latitude,
                            longitude: userLoc.longitude)
                        let distance = fromLoc.distanceFromLocation(toLoc)
                        if (distance < lastDistance) {
                            lastDistance = distance
                            closestDosimeter = name.string
                        }
                        
                        let d = Dosimeter(name: name.string!,
                            lastDose_uSv: dose_uSv.double!,
                            lastDose_mRem: dose_mRem.double!,
                            lastTime: time.string!,
                            distance: (distance/1000))                          // m --> km
                        dosimeters.append(d)
                    }
                    let tabItem = self.tabBarController?.tabBar.items![1]
                    tabItem!.badgeValue = String(numberOfDosimeters)
                    
                    dosimeters.sortInPlace({ $0.distance < $1.distance })
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                    
                    SwiftSpinner.hide()
                }
                
            case .Failure(let error):
                SwiftSpinner.hide()
                
                SwiftSpinner.show("Failed update...").addTapHandler({
                    SwiftSpinner.hide()
                    }, subtitle: "Tap to hide, try again later!")
                print(error)
            }
        }
    }
    
    func initCLLocationManager(){
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager,
            didUpdateLocations locations: [CLLocation]) {
        userLoc = manager.location!.coordinate
        //print("locations = \(userLoc.latitude) \(userLoc.longitude)")
        //locationManager.stopUpdatingLocation()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        // 2
        return dosimeters.count
    }
    
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 3
        let cell = tableView.dequeueReusableCellWithIdentifier("DosimeterCell", forIndexPath: indexPath) as! DosimeterCell
        
        let dosimeter = dosimeters[indexPath.row] as Dosimeter
        cell.dosimeter = dosimeter
            
        /*if let titleLabel = cell.viewWithTag(100) as? UILabel { //4
            titleLabel.text = dosimeters[indexPath.row].name
        }
        
        if let subtitleLabel = cell.viewWithTag(101) as? UILabel { //5
            let km = dosimeters[indexPath.row].distance
            let detailText = String(format:"%.0f", km!*0.621371) + " mi / " + String(format:"%.0f", km!) + " km"
            subtitleLabel.text = detailText
        }*/
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        main()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class DosimeterCell: UITableViewCell { //http://www.raywenderlich.com/113388/storyboards-tutorial-in-ios-9-part-1
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var dosimeter : Dosimeter! {
        didSet {
            let km = dosimeter.distance
            let detailText = String(format:"%.0f", km!*0.621371) + " mi / " + String(format:"%.0f", km!) + " km"
            titleLabel.text = dosimeter.name
            subtitleLabel.text = detailText
        }
    }
}