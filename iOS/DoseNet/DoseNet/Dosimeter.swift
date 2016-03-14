//
//  Dosimeter.swift
//  DoseNet
//
//  Created by Navrit Bal on 06/01/2016.
//  Copyright © 2016 navrit. All rights reserved.
//

import Foundation
import MapKit

class Dosimeter {
    let name : String!
    let lastDose_uSv : Double!
    let lastDose_mRem : Double!
    let lastTime : String!
    let distance : Double?
    let CLLat : CLLocation?
    let CLLon : CLLocation?
    
    init(name:String, lastDose_uSv: Double, distance: Double) {
            self.name = name
            self.lastDose_uSv = lastDose_uSv
            self.lastDose_mRem = nil
            self.lastTime = nil
            self.distance = distance
            self.CLLat = nil
            self.CLLon = nil
    }
    
    init(name:String, lastDose_uSv: Double, lastDose_mRem: Double,
        lastTime: String) {
            self.name = name
            self.lastDose_uSv = lastDose_uSv
            self.lastDose_mRem = lastDose_mRem
            self.lastTime = lastTime
            self.distance = nil
            self.CLLat = nil
            self.CLLon = nil
    }
    
    init(name:String, lastDose_uSv: Double, lastDose_mRem: Double,
        lastTime: String, distance: Double) {
            self.name = name
            self.lastDose_uSv = lastDose_uSv
            self.lastDose_mRem = lastDose_mRem
            self.lastTime = lastTime
            self.distance = distance
            self.CLLat = nil
            self.CLLon = nil
    }
    
    init(name:String, lastDose_uSv: Double, lastDose_mRem: Double,
        lastTime: String, distance: Double, CLLat:CLLocation, CLLon:CLLocation) {
            self.name = name
            self.lastDose_uSv = lastDose_uSv
            self.lastDose_mRem = lastDose_mRem
            self.lastTime = lastTime
            self.distance = distance
            self.CLLat = CLLat
            self.CLLon = CLLon
    }
    
}