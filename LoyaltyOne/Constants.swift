//
//  Constants.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-03.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import Foundation
import UIKit

struct Constants {

    //MARK:
    //MARK: Weather view constants

    struct WeatherView {
        // height for weather view in main view controller
        static let height: CGFloat = 140
        
        // labels x origin in weather view
        static let labelsX: CGFloat = 15

        // condition label height
        static let conditionHeight: CGFloat = 25
        
        // labels low temp and high temp width in weather view
        static let lowHightWidth: CGFloat = 40
        static let lowHightHeigt: CGFloat = 30
        
        // temp label height
        static let tempHeight: CGFloat = 70
        static let tempX: CGFloat = 5
        
        // font size
        static let conditionFontSize: CGFloat = 20
        static let lowHighFontSize: CGFloat = 18
        static let tempFontSize: CGFloat = 80
        
        // font family
        static let fontFamily = "Lato-Light"
        
        // font color
        static let fontColor = "F7F7F7"
    }

    
    
}

extension String {
    
    var capitalizeFirst:String {
        var result = self
        result.replaceRange(startIndex...startIndex, with: String(self[startIndex]).capitalizedString)
        return result
    }
    
}