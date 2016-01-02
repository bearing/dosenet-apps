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

let url:String! = "https://radwatch.berkeley.edu/sites/default/files/output.geojson"
let unit = " µSv/hr"

class MapViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    
    
    func main(){
        
        SwiftSpinner.show("Loading...", animated: true)
        
        Alamofire.request(.GET, url).responseJSON { response in
            switch response.result {
            case .Success:
                
                SwiftSpinner.hide()
                
                if let value = response.result.value {
                    let json = JSON(value)
                    let features:JSON = json["features"]
                    
                    let centerLocation = CLLocationCoordinate2DMake(37.8706454, -122.2602171)
                    let mapSpan = MKCoordinateSpanMake(1, 1)
                    let mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
                    self.map.setRegion(mapRegion, animated: true)
                    self.map.rotateEnabled = false
                    self.map.pitchEnabled = false
                    
                    for var i=0; i<features.count; ++i {
                        let this:JSON = features[i]
                        let name:JSON = this["properties"]["Name"]
                        let dose:JSON = this["properties"]["Latest dose (&microSv/hr)"]
                        let doseString:String = String(format:"%.3f",dose.double!)
                        let time:JSON = this["properties"]["Latest measurement"]
                        let timeString:String = time.string!
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
            case .Failure(let error):
                SwiftSpinner.hide()
                
                SwiftSpinner.show("Failed update...").addTapHandler({
                    SwiftSpinner.hide()
                    }, subtitle: "Tap to hide, try again later!")
                print(error)
            }
        }
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