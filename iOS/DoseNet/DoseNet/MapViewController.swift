//
//  MapViewController.swift
//  DoseNet
//
//  Created by Navrit Bal on 30/12/2015.
//  Copyright © 2015 navrit. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftSpinner
import JLToast
import CoreLocation

let url:String! = "https://radwatch.berkeley.edu/sites/default/files/output.geojson"
let unit:String! = " µSv/hr"
var closestDosimeter:String! = ""
var numberOfDosimeters:Int! = 0
var userLoc:CLLocationCoordinate2D!

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    let locationManager = CLLocationManager()
    
    func main(){
        initCLLocationManager()
        initToast()
        SwiftSpinner.show("Loading...", animated: true)
        
        networkRequest()
    }
    
    func networkRequest(){
        Alamofire.request(.GET, url).responseJSON { response in
            switch response.result {
                
            case .Success:
                
                SwiftSpinner.hide()
                
                if let value = response.result.value {
                    let features:JSON = JSON(value)["features"]
                    var lastDistance = CLLocationDistance(20037500)
                    
                    self.map.rotateEnabled = false
                    self.map.pitchEnabled = false
                    
                    numberOfDosimeters = features.count
                    JLToast.makeText("\(numberOfDosimeters) Dosimeters are available", duration: JLToastDelay.LongDelay).show()
                    
                    for var i=0; i < numberOfDosimeters; ++i {
                        let this:JSON = features[i]
                        let prop:JSON = this["properties"]
                        let name:JSON = prop["Name"]
                        let dose:JSON = prop["Latest dose (&microSv/hr)"]
                        let doseString:String = String(format:"%.3f",dose.double!)
                        let time:JSON = prop["Latest measurement"]
                        let timeString:String = time.string!
                        let subtitle = doseString + unit + " @ " + timeString
                        let lon = this["geometry"]["coordinates"][0]
                        let lat = this["geometry"]["coordinates"][1]
                        let CLlon = CLLocationDegrees(lon.double!)
                        let CLlat = CLLocationDegrees(lat.double!)
                        let pinLocation = CLLocationCoordinate2DMake(CLlat,CLlon)
                        let annotation = MKPointAnnotation()
                        
                        annotation.title = name.string
                        annotation.coordinate = pinLocation
                        annotation.subtitle = subtitle
                        self.map.addAnnotation(annotation)
                        
                        let fromLoc = CLLocation(latitude: CLlat, longitude: CLlon)
                        let toLoc = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
                        let distance = fromLoc.distanceFromLocation(toLoc)
                        if (distance < lastDistance) {
                            lastDistance = distance
                            closestDosimeter = name.string
                        }
                    }
                    JLToast.makeText("\(closestDosimeter) is your closest dosimeter", duration: JLToastDelay.LongDelay).show()
                    let tabItem = self.tabBarController?.tabBar.items![1]
                    tabItem!.badgeValue = String(numberOfDosimeters)
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
    
    func initToast(){
        JLToastView.setDefaultValue(
            NSNumber(double: 50),
            forAttributeName: JLToastViewPortraitOffsetYAttributeName,
            userInterfaceIdiom: .Phone
        )
        
        JLToastView.setDefaultValue(
            NSNumber(double: 50),
            forAttributeName: JLToastViewLandscapeOffsetYAttributeName,
            userInterfaceIdiom: .Phone
        )
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
    
    func mapSetup(){
        let centerLocation = CLLocationCoordinate2DMake(userLoc.latitude, userLoc.longitude)
        let mapSpan = MKCoordinateSpanMake(10, 10)
        let mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
        
        map.setRegion(mapRegion, animated: true)
        map.showsUserLocation = true
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLoc = manager.location!.coordinate
        //print("locations = \(userLoc.latitude) \(userLoc.longitude)")
        locationManager.stopUpdatingLocation()
        
        mapSetup()
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