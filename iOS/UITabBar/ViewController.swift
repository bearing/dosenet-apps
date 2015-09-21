//
//  ViewController.swift
//  UITabBar
//
//  Created by Navrit Bal on 25/07/15.
//  Copyright (c) 2015 navrit. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

let dURL:String! = "https://radwatch.berkeley.edu/sites/default/files/output.geojson"

class ViewController: UIViewController, NSURLConnectionDelegate {
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request(.GET, dURL, parameters: nil)
            .responseJSON { (req, res, json, error) in
                if(error != nil) {
                    NSLog("Error: \(error)")
                    println(req)
                    println(res)
                }
                else {
                    NSLog("Success: \(dURL)")
                    var json = JSON(json!)
                    NSLog("Live JSON:\n \(json)")
                    let features:JSON = json["features"]
                    let unit = " µSv/hr"
                    
                    var centerLocation = CLLocationCoordinate2DMake(37.8706454, -122.2602171)
                    var mapSpan = MKCoordinateSpanMake(0.1, 0.1)
                    var mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
                    self.map.setRegion(mapRegion, animated: true)
                    self.map.rotateEnabled = false
                    self.map.pitchEnabled = false

                    for var i=0; i<features.count; ++i {
                        let this:JSON = features[i]
                        let name:JSON = this["properties"]["Name"]
                        let dose:JSON = this["properties"]["Latest dose (&microSv/hr)"]
                        var doseString:String = String(format:"%.1f",dose.double!)
                        let time:JSON = this["properties"]["Latest measurement"]
                        var timeString:String = time.string!
                        let subtitle = doseString + unit + " @ " + timeString
                        let lon = this["geometry"]["coordinates"][0]
                        let lat = this["geometry"]["coordinates"][1]
                        let CLlat = CLLocationDegrees(lat.double!)
                        let CLlon = CLLocationDegrees(lon.double!)
                        let pinLocation = CLLocationCoordinate2DMake(CLlat,CLlon)
                        let annotation = MKPointAnnotation()
                        annotation.title = name.string
                        annotation.coordinate = pinLocation
                        annotation.subtitle = subtitle
                        self.map.addAnnotation(annotation)
                    }
                }
        }
        
        
        //let longPress = UILongPressGestureRecognizer(target: self, action: "action:")
        //longPress.minimumPressDuration = 0.5
        //map.addGestureRecognizer(longPress)
        
        var rightCalloutAccesoryView: UIView //UIButton
    }
    
    func action(gestureRecognizer:UIGestureRecognizer){
        
        /*var touchPoint = gestureRecognizer.locationInView(self.map)
        var newCoord:CLLocationCoordinate2D = map.convertPoint(touchPoint, toCoordinateFromView: self.map)
        
        var newAnotation = MKPointAnnotation()
        newAnotation.coordinate = newCoord
        newAnotation.title = "New Location"
        newAnotation.subtitle = "New Subtitle"
        map.addAnnotation(newAnotation)*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

