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

let unit:String! = " µSv/hr"
let timeZone:String! = " (Local)"
var closestDosimeter:String! = ""

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    func main(){
        initToast()
        SwiftSpinner.show("Loading...", animated: true)
        mapSetup()
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
                    
                    JLToast.makeText("\(numberOfDosimeters) Dosimeters are available", duration: JLToastDelay.LongDelay).show()
                    
                    for i in 0..<numberOfDosimeters {
                        let this:JSON = features[i]
                        let prop:JSON = this["properties"]
                        let name:JSON = prop["Name"]
                        let dose:JSON = prop["Latest dose (&microSv/hr)"]
                        let doseString:String = String(format:"%.3f",dose.double!)
                        let time:JSON = prop["Latest measurement"]
                        let timeString:String = time.string! + timeZone
                        let subtitle = doseString + unit + " @ " + timeString

                        let CLlon = CLLocationDegrees(this["geometry"]["coordinates"][0].double!)
                        let CLlat = CLLocationDegrees(this["geometry"]["coordinates"][1].double!)
                        let pinLocation = CLLocationCoordinate2DMake(CLlat,CLlon)
                        let annotation = MKPointAnnotation()
                        
                        annotation.title = name.string
                        annotation.coordinate = pinLocation
                        annotation.subtitle = subtitle
                        self.mapView.addAnnotation(annotation)
                        
                        let fromLoc = CLLocation(latitude: CLlat, longitude: CLlon)
                        let toLoc = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
                        let distance = fromLoc.distanceFromLocation(toLoc)
                        if (distance < lastDistance) {
                            lastDistance = distance
                            closestDosimeter = name.string
                        }
                    }
                    JLToast.makeText("\(closestDosimeter) is your closest dosimeter", duration: JLToastDelay.LongDelay).show()

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
    
    func mapSetup(){
        let centerLocation = CLLocationCoordinate2DMake(userLoc.latitude, userLoc.longitude)
        let mapSpan = MKCoordinateSpanMake(10, 10)
        let mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
        
        mapView.rotateEnabled = false
        mapView.pitchEnabled = false
        mapView.setRegion(mapRegion, animated: true)
        mapView.showsUserLocation = true
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