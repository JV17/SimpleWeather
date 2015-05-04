//
//  LocationManager.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-03.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit
import CoreLocation


protocol LocationManagerDelegate {
    
    // tells the users city, postal code, state, country, country code
    func locationFinishedUpdatingWithCity(cityName: String, postalCode: String, state: String, country: String, countryCode: String)
    
}


class LocationManager: NSObject, CLLocationManagerDelegate {

    //MARK:
    //MARK: Properties

    let locationManager = CLLocationManager()
    var delegate: LocationManagerDelegate?
    var alreadyUpdatedLocation = Bool()
    
    //MARK:
    //MARK: Location Manager delegate
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        // this send a request to apple servers and we get back the placemarks if they found a matching address in their server
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            
            if(error != nil) {
                println("Error:" + error.localizedDescription)
            }

            // avoiding delays from block
            dispatch_async(dispatch_get_main_queue()) {
                
                if(placemarks.count > 0) {
                    let pm = placemarks[0] as! CLPlacemark
                    self.displayLocationInfo(pm)
                }
                else {
                    println("Error with data")
                }
                
                // stop updating location
                self.stopUpdationgLocation()
            }
            
        })
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }
    
    
    //MARK:
    //MARK: Location Manager helper functions
    
    func requestLocation() {
        // ask for location
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if(CLLocationManager.locationServicesEnabled()) {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        
        if(self.alreadyUpdatedLocation) {
            return
        }
        
        self.delegate?.locationFinishedUpdatingWithCity(placemark.locality, postalCode: placemark.postalCode, state: placemark.administrativeArea, country: placemark.country, countryCode: placemark.ISOcountryCode)
        
    }
    
    func stopUpdationgLocation() {
        dispatch_async(dispatch_get_main_queue()) {
            self.locationManager.stopUpdatingLocation()
            self.alreadyUpdatedLocation = true
        }
    }
}