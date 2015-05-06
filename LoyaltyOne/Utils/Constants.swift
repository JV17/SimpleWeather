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
        static let height: CGFloat = 160 + ForecastView.viewHeight
        
        // labels x origin in weather view
        static let labelsX: CGFloat = 15

        // condition label height
        static let conditionHeight: CGFloat = 30
        
        // labels low temp and high temp width in weather view
        static let lowHightWidth: CGFloat = 40
        static let lowHightHeigt: CGFloat = 35
        
        // temp label height
        static let tempHeight: CGFloat = 80
        static let tempX: CGFloat = 10
        
        // the buttons size
        static let buttonSize: CGFloat = 50
        static let buttonColor: String = "F7F7F7"
        static let buttonHighlightedColor: String = "898C90"
        
        // the divider line between the buttons
        static let dividerLineHeight: CGFloat = 30

        // font size
        static let loadingFontSize: CGFloat = 40
        static let conditionFontSize: CGFloat = 24
        static let lowHighFontSize: CGFloat = 22
        static let tempFontSize: CGFloat = 90
        static let buttonFontSize: CGFloat = 26
        
        // font family
        static let fontFamily = "Lato-Light"
        
        // font color
        static let fontColor = "F7F7F7"
    }

    
    //MARK:
    //MARK: Forecast weather view
    
    struct ForecastView {
        // font
        static let fontFamily: String = "Lato-Light"
        static let fontSize: CGFloat = 16
        static let fontColor: String = "F7F7F7"
        
        static let numDays: Int = 7
        
        static let rowHeight: CGFloat = 59
        
        static let dividerColor: String = "F7F7F7"
        
        static let viewHeight: CGFloat = 80
        static let subtractY: CGFloat = WeatherView.height + ForecastView.viewHeight + 5
    }

    
    //MARK:
    //MARK: User defaults constants
    
    struct UserDefaults {
        
        static let dicTempKey: String = "temperature"
        static let conditionKey: String = "condition"
        static let maxTempKey: String = "max"
        static let lowTempKey: String = "low"
        static let currentTempKey: String = "current"
        
        // weather manager defaults
        static let currentConditionKey: String = "currentCondition"
        static let currentCondtionDescKey: String = "currentConditionDesc"
        
        static let selectedCity: String = "selectedCity"
        
        static let backgroundImageNum: String = "backgroundImageNum"
    }
    
    
    //MARK:
    //MARK: Autocomplete view constants
    
    struct AutocompleteView {
        static let viewYoffSet: CGFloat = 36.0
    }

}