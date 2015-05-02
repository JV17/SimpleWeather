//
//  WeatherHelper.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-02.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit

class WeatherHelper: NSObject {

    func tempToCelcius(tempKelvin: NSNumber) -> NSNumber {
        return (tempKelvin.floatValue - 273.15)
    }
    
    func tempToFahrenheit(tempKelvin: NSNumber) -> NSNumber {
        return ((tempKelvin.floatValue * 9/5) - 459.67)
    }
}