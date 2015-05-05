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
    func locationFinishedUpdatingWithCity(locationManager: LocationManager, city: String, postalCode: String, state: String, country: String, countryCode: String)
    
    // tells if we got an error from our location service
    func locationFinishedWithError(locationMAnager: LocationManager, error: NSError, errorMessage: String)
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
                self.delegate?.locationFinishedWithError(self, error: error, errorMessage: error.localizedDescription)
            }

            // avoiding delays from block
            dispatch_async(dispatch_get_main_queue()) {
                
                if(placemarks.count > 0) {
                    let pm = placemarks[0] as! CLPlacemark
                    self.displayLocationInfo(pm)
                }
                else {
                    println("Error with data")
                    let error: NSError = NSError(domain: "Location Services", code: 1, userInfo: nil)
                    self.delegate?.locationFinishedWithError(self, error: error, errorMessage: "Error with the location services information, please try again.")
                }
                
                // stop updating location
                self.stopUpdationgLocation()
            }
            
        })
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
        self.delegate?.locationFinishedWithError(self, error: error, errorMessage: error.localizedDescription)
    }
    
    
    //MARK:
    //MARK: Location Manager helper functions
    
    func requestLocation() {
        
        self.alreadyUpdatedLocation = false
        
        // ask for location
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if(CLLocationManager.locationServicesEnabled()) {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
        }
        else {
            // user location services is off
            let error: NSError = NSError(domain: "Location Services Unavailable", code: 1, userInfo: nil)
            self.delegate?.locationFinishedWithError(self, error: error, errorMessage: "Please enabled your location services within your device settings.")
        }
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        
        if(self.alreadyUpdatedLocation) {
            return
        }
        
        self.delegate?.locationFinishedUpdatingWithCity(self, city: placemark.locality, postalCode: placemark.postalCode, state: placemark.administrativeArea, country: placemark.country, countryCode: placemark.ISOcountryCode)
        
    }
    
    func stopUpdationgLocation() {
        dispatch_async(dispatch_get_main_queue()) {
            self.locationManager.stopUpdatingLocation()
            self.alreadyUpdatedLocation = true
        }
    }
    
}