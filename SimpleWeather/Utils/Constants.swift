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
    //MARK: Multi-threading
    
    struct WeatherManager {
        // requests urls
        static let weatherURL: String = "http://api.openweathermap.org/data/2.5/weather"
        static let weatherForecastURL: String = "http://api.openweathermap.org/data/2.5/forecast/daily"
        static let citiesURL: String = "http://api.openweathermap.org/data/2.5/find"
        static let apiKey: String = "432dbd419b713483bc99b3cbcd13d5ab"
    }
    
    struct WeatherUnderground {
        static let weatherURL: String = "http://api.wunderground.com/api/" + WeatherUnderground.apiKey + "/conditions"
        static let weatherForecastURL: String = "http://api.wunderground.com/api/" + WeatherUnderground.apiKey + "/forecast10day"
        static let citiesURL: String = "http://autocomplete.wunderground.com/aq"
        static let apiKey: String = "87c31015035f8c5b"
    }
    
    //MARK:
    //MARK: Multi-threading
    
    struct MultiThreading {
        // priorities
        static let quality_class_interactive = Int(QOS_CLASS_USER_INTERACTIVE.rawValue)
        static let quality_class_initiated = Int(QOS_CLASS_USER_INITIATED.rawValue)
        static let quality_class_default = Int(QOS_CLASS_DEFAULT.rawValue)
        static let quality_class_utility = Int(QOS_CLASS_UTILITY.rawValue)
        static let quality_class_background = Int(QOS_CLASS_BACKGROUND.rawValue)
        static let quality_class_min = Int(QOS_MIN_RELATIVE_PRIORITY)
        
        // dispatchs
        static let interactiveQueue = dispatch_get_global_queue(quality_class_interactive, 0)
        static let initiatedQueue = dispatch_get_global_queue(quality_class_initiated, 0)
        static let defaultQueue = dispatch_get_global_queue(quality_class_default, 0)
        static let utilityQueue = dispatch_get_global_queue(quality_class_utility, 0)
        static let backgroundQueue = dispatch_get_global_queue(quality_class_background, 0)
        static let minPriorityQueue = dispatch_get_global_queue(quality_class_min, 0)
        
        static let mainQueue = dispatch_get_main_queue()
    }

    
    //MARK:
    //MARK: Weather view constants

    struct WeatherView {
        // height for weather view in main view controller
        static let height: CGFloat = 165 + ForecastView.viewHeight
        
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
        
        static let viewHeight: CGFloat = 82
        static let subtractY: CGFloat = WeatherView.height + ForecastView.viewHeight + 5
        
        static let daysFrame = CGRectMake(0, 60, 58, 20)
        static let iconsFrame = CGRectMake(14, 25, 30, 30)
        static let tempsFrame = CGRectMake(0, 0, 58, 20)
        static let dividersFrame = CGRectMake(0, 5, 0.7, 66)

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
        
        static let currentCity: String = "currentCity"
        static let currentState: String = "currentCity"
        static let selectedCity: String = "selectedCity"
        
        static let backgroundImageNum: String = "backgroundImageNum"
        
        static let forecastViewTemps: String = "forecastViewTemps"
    }
    
    
    //MARK:
    //MARK: Autocomplete view constants
    
    struct AutocompleteView {
        static let viewYoffSet: CGFloat = 36.0
    }

}