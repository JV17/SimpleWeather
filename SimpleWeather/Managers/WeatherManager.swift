//
//  WeatherManager.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-02.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit

protocol WeatherDataSource {
    
    //MARK:
    //MARK: WeatherDataSource Protocol

    // this function allows us to know when we get the weather data from open weather map
    func weatherRequestFinishedWithJSON(weatherManager: WeatherManager, weatherJSON: JSON)
    
    // this function allows us to get notify if an error occurred while doing the API call
    func weatherRequestFinishedWithError(weatherManager: WeatherManager, error: NSError, serverError: Bool, city: String, state: String, locationId: String)

    // this function allows us to know when we get the cities from open weather map
    func citiesRequestFinishedWithJSON(weatherManager: WeatherManager, citiesJSON: JSON)
    
    // this function allows us to get notify if an error occurred while doing the API call
    func citiesRequestFinishedWithError(weatherManage: WeatherManager, error: NSError)

    // this function allows us to know when we get the forecast weather from open weather map
    func forecastWeatherRequestFinishedWithJSON(weatherManager: WeatherManager, forecastJSON: JSON)

    // this function allows us to get notify if an error occurred while doing the API call
    func forecastWeatherRequestFinishedWithError(weatherManager: WeatherManager, error: NSError, city: String, state: String, locationId: String)
}


//MARK:
//MARK: WeatherManager

class WeatherManager: NSObject {
    
    //MARK: Properties
    
    lazy var appHelper: AppHelper = {
        var tmpAppHelper: AppHelper = AppHelper()
        return tmpAppHelper
    }()

    lazy var httpRequest: HTTPTask = {
        var tmpRequest: HTTPTask = HTTPTask()
        return tmpRequest
    }()
    
    var weatherJSON: JSON?
    var forecastJSON: JSON?
    var citiesJSON: JSON?
    var delegate: WeatherDataSource?
    
    
    //MARK: Weather Manager requests
    
    func requestWeatherForCity(requestCity: String, requestState: String, requestLocationId: String, forCity: Bool) {
    
        if(requestCity.isEmpty && requestState.isEmpty && requestLocationId.isEmpty) {
            // telling the delegate we have received an error
            let error = NSError(domain: "Weather Services Error.", code: 404, userInfo: [NSLocalizedDescriptionKey : "Weather services are inaccessible without a City, State or location Id"])
            self.delegate?.weatherRequestFinishedWithError(self, error: error, serverError: false, city: "", state: "", locationId: "")
            return
        }
        
        var strURL = String()
        var requestURL = String()

        // setting the url request
        if(forCity) {
            strURL = Constants.WeatherUnderground.weatherURL + "/q/" + requestState + "/" + requestCity + ".json"
            requestURL = strURL.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        else {
            requestURL = Constants.WeatherUnderground.weatherURL + requestLocationId + ".json"
        }
        
        // setting the GET request
        self.httpRequest.GET(requestURL, parameters: nil) { (response: HTTPResponse) -> Void in
         
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                
                dispatch_async(Constants.MultiThreading.mainQueue) {
                    // telling the delegate we have received an error
                    self.delegate?.weatherRequestFinishedWithError(self, error: err, serverError: false, city: requestCity, state: requestState, locationId: requestLocationId)
                }
                
                return;
            }
            
            if let data = response.responseObject as? NSData {
                
                dispatch_async(Constants.MultiThreading.backgroundQueue, {

                    // extracting the data from NSData
                    self.weatherJSON = JSON(data: data)
                    
                    // we need to avoid delays from our download task
                    dispatch_async(Constants.MultiThreading.mainQueue) {
                        self.checkValidWeatherDataWithCity(requestCity, state: requestState, locationId: requestLocationId)
                    }
                })
            }
        }
    }
    
    
    func requestWeatherForecastForCity(city: String, state: String, locationId: String, forCity: Bool) {
        
        if(city.isEmpty && state.isEmpty && locationId.isEmpty) {
            // telling the delegate we have received an error
            let error = NSError(domain: "Weather Services Error.", code: 404, userInfo: [NSLocalizedDescriptionKey : "Weather services are inaccessible without a City, State or location Id"])
            self.delegate?.forecastWeatherRequestFinishedWithError(self, error: error, city: city, state: state, locationId: locationId)
            return
        }
        
        var strURL = String()
        var requestURL = String()
        
        // setting the url request
        if(forCity) {
            strURL = Constants.WeatherUnderground.weatherForecastURL + "/q/" + state + "/" + city + ".json"
            requestURL = strURL.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        else {
            requestURL = Constants.WeatherUnderground.weatherForecastURL + locationId + ".json"
        }
        
        // setting the GET request
        self.httpRequest.GET(requestURL, parameters: nil) { (response: HTTPResponse) -> Void in

            if let err = response.error {
                print("error: \(err.localizedDescription)")
                
                dispatch_async(Constants.MultiThreading.mainQueue) {
                    // telling the delegate we have received an error
                    self.delegate?.forecastWeatherRequestFinishedWithError(self, error: err, city: city, state: state, locationId: locationId)
                }
                return;
            }
            
            if let data = response.responseObject as? NSData {
                
                dispatch_async(Constants.MultiThreading.backgroundQueue, {
                    
                    // extracting the data from NSData
                    self.forecastJSON = JSON(data: data)
                    
                    // we need to avoid delays from our download task
                    dispatch_async(Constants.MultiThreading.mainQueue) {
                        self.delegate?.forecastWeatherRequestFinishedWithJSON(self, forecastJSON: self.forecastJSON!)
                    }
                })
            }
        }
    }
    
    
    func requestCitiesFromString(searchString: String) {
        
        if(searchString.isEmpty) {
            // telling the delegate we have received an error
            let error = NSError(domain: "City Services Error.", code: 404, userInfo: [NSLocalizedDescriptionKey : "City services are inaccessible without a string/city to search for"])
            self.delegate?.citiesRequestFinishedWithError(self, error: error)
            return
        }
        
        // setting the GET request
        self.httpRequest.GET(Constants.WeatherUnderground.citiesURL, parameters: ["query" : searchString]) { (response: HTTPResponse) -> Void in
            
            if let err = response.error {
                print("error: \(err.localizedDescription)")
            
                dispatch_async(Constants.MultiThreading.mainQueue) {
                    // telling the delegate we have received an error
                    self.delegate?.citiesRequestFinishedWithError(self, error: err)
                }
            }

            if let data = response.responseObject as? NSData {

                dispatch_async(Constants.MultiThreading.backgroundQueue, {

                    // extracting the data from NSData
                    self.citiesJSON = JSON(data: data)
                    
                    // we need to avoid delays from our download task
                    dispatch_async(Constants.MultiThreading.mainQueue) {
                        self.delegate?.citiesRequestFinishedWithJSON(self, citiesJSON: self.citiesJSON!)
                    }
                })
            }
        }
    }
    
    
    //MARK: Weather Manager helper functions
    
    func checkValidWeatherDataWithCity(city: String, state: String, locationId: String) {

        // we received a json with error
        if ((self.weatherJSON!["response"]["error"]) != nil) {
            // error handling
            let errorTitle = self.weatherJSON!["response"]["error"]["type"].stringValue + " Error"
            let errorMessage = self.weatherJSON!["response"]["error"]["description"].stringValue
            let error = NSError(domain: errorTitle.capitalizeFirst, code: 500, userInfo: [NSLocalizedDescriptionKey : errorMessage.capitalizeFirst])

            // tells the delegate we couldn't find the city
            self.delegate?.weatherRequestFinishedWithError(self, error: error, serverError: true, city: city, state: state, locationId: locationId)
        }
        else {
            // saving current weather condition to match with proper icons
            self.saveCurrentWeatherConditionFromJSON(self.weatherJSON!)
            
            // telling the delegate we have received data from our API call
            self.delegate?.weatherRequestFinishedWithJSON(self, weatherJSON: self.weatherJSON!)
        }
    }
    
        
    func saveCurrentWeatherConditionFromJSON(weatherJSON: JSON) {
        
        if (!weatherJSON.isEmpty) {
            // getting current condition from json
            let currentCondition = weatherJSON["current_observation"]["weather"].stringValue
            
            // saving current condition to defaults
            NSUserDefaults.standardUserDefaults().setObject(currentCondition, forKey: Constants.UserDefaults.currentConditionKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    
    //MARK: Temperature conversation
    
    func tempToCelciusFromKelvin(tempKelvin: NSNumber) -> String {
        return self.numberFormatterWithNumber((tempKelvin.floatValue - 273.15))
    }
    
        
    func tempToFahrenheitFromKelvin(tempKelvin: NSNumber) -> String {
        return self.numberFormatterWithNumber((((tempKelvin.floatValue - 273.15) * 1.8) + 32.00))
    }
    
        
    func tempToCelcius(temp: NSNumber) -> String {
        return self.numberFormatterWithNumber(temp.floatValue) // we are storing the value as celcius so nothing to do here
    }
    
        
    func tempToFahrenheit(temp: NSNumber) -> String {
        return self.numberFormatterWithNumber((temp.floatValue*(9/5)) + 32.0)
    }
        
    
    func numberFormatterWithNumber(number: NSNumber) -> String {
        // formatting weather temp to display number without decimals
        let formatter = NSNumberFormatter()
        formatter.roundingMode = NSNumberFormatterRoundingMode.RoundDown
        formatter.positiveFormat = "0"
        
        return formatter.stringFromNumber(number)!
    }
    
    
    //MARK: Saved temperature getters
    
    func getSavedTemperatureCondition() -> String {
        
        if let tempDic = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.UserDefaults.dicTempKey) {
            if let condition = tempDic[Constants.UserDefaults.conditionKey] as? String {
                return String(format: "\(condition)")
            }
        }
        
        return ""
    }
        

    func getSavedMaxTemperature() -> NSNumber {

        if let tempDic = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.UserDefaults.dicTempKey) {
            if let maxTemp = tempDic[Constants.UserDefaults.maxTempKey] as? NSNumber {
                return maxTemp
            }
        }
        
        return 0
    }
    
        
    func getSavedLowTemperature() -> NSNumber {
        
        if let tempDic = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.UserDefaults.dicTempKey) {
            if let lowTemp = tempDic[Constants.UserDefaults.lowTempKey] as? NSNumber {
                return lowTemp
            }
        }
        
        return 0
    }
        

    func getSavedCurrentTemperature() -> NSNumber {
        
        if let tempDic = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.UserDefaults.dicTempKey) {
            if let currentTemp = tempDic[Constants.UserDefaults.currentTempKey] as? NSNumber {
                return currentTemp
            }
        }
        
        return 0
    }
    
    
    //MARK: Weather condition icons
    
    func getWeatherImageForCondition(conditionStr: String) -> UIImage {
        
        var image: UIImage?
        
        // weather condition image icon switch
        switch conditionStr
        {
            
        // case for light rain days
        case "Light Drizzle",
             "Light Rain",
             "Light Freezing Drizzle",
             "Light Freezing Rain",
             "Light Rain Showers",
             "Light Rain Mist":
            
            image = UIImage(named: "little_rain-50")
            
        // case for heavy rain days
        case "Heavy Rain",
             "Heavy Drizzle",
             "Heavy Freezing Drizzle",
             "Heavy Freezing Rain",
             "Heavy Rain Showers",
             "Heavy Rain Mist":
            
            image = UIImage(named: "rain-50")
            
        // case for fog days
        case "Patches of Fog",
             "Shallow Fog",
             "Partial Fog",
             "Light Fog",
             "Light Fog",
             "Heavy Fog",
             "Heavy Fog Patches",
             "Light Fog Patches":
            
            // getting image depending on the current time
            if(self.appHelper.isCurrentTimeDayTime()) {
                image = UIImage(named: "fog_day-50")
            }
            else {
                image = UIImage(named: "fog_night-50")
            }
        
        // case for clear days
        case "Clear",
             "Overcast",
             "Scattered Clouds":
            
            // getting image depending on the current time
            if(self.appHelper.isCurrentTimeDayTime()) {
                image = UIImage(named: "summer-50")
            }
            else {
                image = UIImage(named: "moon-50")
            }
        
        // case for cloudy days
        case "Partly Cloudy",
             "Mostly Cloudy",
             "Scattered Clouds",
             "Funnel Cloud":
            
            // getting image depending on the current time
            if(self.appHelper.isCurrentTimeDayTime()) {
                image = UIImage(named: "partly_cloudy_day-50")
            }
            else {
                image = UIImage(named: "partly_cloudy_night-50")
            }
            
        // case for heavy snow days
        case "Heavy Snow",
             "Heavy Snow Grains",
             "Heavy Ice Crystals",
             "Heavy Ice Pellets",
             "Heavy Blowing Snow",
             "Heavy Low Drifting Snow",
             "Heavy Snow Showers",
             "Heavy Snow Blowing Snow Mist":
            
            image = UIImage(named: "snow-50")
            
        // case for light snow days
        case "Light Snow",
             "Light Snow Grains",
             "Light Ice Crystals",
             "Light Ice Pellets",
             "Light Blowing Snow",
             "Light Low Drifting Snow",
             "Light Snow Showers",
             "Light Snow Blowing Snow Mist":

            image = UIImage(named: "light_snow-50")
            
        // default case
        default:
            
            // getting image depending on the current time
            if(self.appHelper.isCurrentTimeDayTime()) {
                image = UIImage(named: "summer-50")
            }
            else {
                image = UIImage(named: "moon-50")
            }
        }
        
        return image!
    }

}
