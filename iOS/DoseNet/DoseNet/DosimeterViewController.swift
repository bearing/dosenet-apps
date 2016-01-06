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

let url:String! = "https://radwatch.berkeley.edu/sites/default/files/output.geojson?" + randomAlphaNumericString(10)
var userLoc:CLLocationCoordinate2D!
var numberOfDosimeters:Int! = 0

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
    
    var items = [String]()
    var itemsDistances = [Double]()
    
    /*
    https://stackoverflow.com/questions/30446812/sort-swift-array-of-dictionaries-by-value-of-a-key
    var myArray = Array<AnyObject>()
    var dict = Dictionary<String, AnyObject>()
    
    myArray.sort{
    (($0 as! Dictionary<String, AnyObject>)["i"] as? Int) < (($1 as! Dictionary<String, AnyObject>)["i"] as? Int)
    }
    */
    
    
    var newitem: String = ""
    let locationManager = CLLocationManager()
    
    func main() {
        print(url)
        initCLLocationManager()
        SwiftSpinner.show("Loading...", animated: true)
        networkRequest()
    }
    
    func networkRequest() {
        Alamofire.request(.GET, url).responseJSON { response in
            switch response.result {
                
            case .Success:
                SwiftSpinner.hide()
                
                if let value = response.result.value {
                    let features:JSON = JSON(value)["features"]
                    var lastDistance = CLLocationDistance(20037500)
                    
                    numberOfDosimeters = features.count
                    
                    for var i=0; i < numberOfDosimeters; ++i {
                        let this:JSON = features[i]
                        let prop:JSON = this["properties"]
                        let name:JSON = prop["Name"]
                        let lon = this["geometry"]["coordinates"][0]
                        let lat = this["geometry"]["coordinates"][1]
                        let CLlon = CLLocationDegrees(lon.double!)
                        let CLlat = CLLocationDegrees(lat.double!)
                        
                        let fromLoc = CLLocation(latitude: CLlat, longitude: CLlon)
                        let toLoc = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
                        let distance = fromLoc.distanceFromLocation(toLoc)
                        if (distance < lastDistance) {
                            lastDistance = distance
                            closestDosimeter = name.string
                        }
                        
                        self.items.append(name.string!)
                        self.itemsDistances.append(distance/1000)
                    }
                    let tabItem = self.tabBarController?.tabBar.items![1]
                    tabItem!.badgeValue = String(numberOfDosimeters)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
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
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLoc = manager.location!.coordinate
        //print("locations = \(userLoc.latitude) \(userLoc.longitude)")
        locationManager.stopUpdatingLocation()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        return self.items.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 3
        let cell = tableView.dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath)
        cell.textLabel!.text = self.items[indexPath.row]
        var detailText : String
        let km = self.itemsDistances[indexPath.row]
        detailText = String(format:"%.0f", Double(km)*0.621371) + " mi / " + String(format:"%.0f", km) + " km"
        cell.detailTextLabel!.text = detailText
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

