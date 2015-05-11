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
    //MARK: Protocol

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


class WeatherManager: NSObject {
    
    //MARK:
    //MARK: Properties

    var appHelper: AppHelper = {
        var tmpAppHelper: AppHelper = AppHelper()
        return tmpAppHelper
    }()

    var request: HTTPTask = {
        var tmpRequest: HTTPTask = HTTPTask()
        return tmpRequest
    }()
    
    var weatherJSON: JSON?
    var forecastJSON: JSON?
    var citiesJSON: JSON?
    var delegate: WeatherDataSource?
    
    
    //MARK:
    //MARK: Weather Manager requests
    
    func requestWeatherForCity(city: String, state: String, locationId: String, forCity: Bool) {
    
        if(city.isEmpty && state.isEmpty && locationId.isEmpty) {
            // telling the delegate we have received an error
            let error = NSError(domain: "Weather Services Error.", code: 404, userInfo: [NSLocalizedDescriptionKey : "Weather services are inaccessible without a City, State or location Id"])
            self.delegate?.weatherRequestFinishedWithError(self, error: error, serverError: false, city: "", state: "", locationId: "")
            return
        }
        
        var strURL = String()
        var requestURL = String()

        // setting the url request
        if(forCity) {
            strURL = Constants.WeatherUnderground.weatherURL + "/q/" + state + "/" + city + ".json"
            requestURL = strURL.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        else {
            requestURL = Constants.WeatherUnderground.weatherURL + locationId + ".json"
        }
        
        // setting the GET request
        self.request.GET(requestURL, parameters: nil, success: {(response: HTTPResponse) in
            if let data = response.responseObject as? NSData {
                
                dispatch_async(Constants.MultiThreading.backgroundQueue, {

                    // extracting the data from NSData
                    self.weatherJSON = JSON(data: data)
                    
                    // we need to avoid delays from our download task
                    dispatch_async(Constants.MultiThreading.mainQueue) {
                        self.checkForValidWeatherDataWithCity(city, state: state, locationId: locationId)
                    }
                })
            }
            },failure: {(error: NSError, response: HTTPResponse?) in
                println("error: \(error)")

                dispatch_async(Constants.MultiThreading.mainQueue) {
                    // telling the delegate we have received an error
                    self.delegate?.weatherRequestFinishedWithError(self, error: error, serverError: false, city: city, state: state, locationId: locationId)
                }
        })
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
        self.request.GET(requestURL, parameters: nil, success: {(response: HTTPResponse) in
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
            },failure: {(error: NSError, response: HTTPResponse?) in
                println("error: \(error)")
                
                dispatch_async(Constants.MultiThreading.mainQueue) {
                    // telling the delegate we have received an error
                    self.delegate?.forecastWeatherRequestFinishedWithError(self, error: error, city: city, state: state, locationId: locationId)
                }
        })
    }
    
    func requestCitiesFromString(searchString: String) {
        
        if(searchString.isEmpty) {
            // telling the delegate we have received an error
            let error = NSError(domain: "City Services Error.", code: 404, userInfo: [NSLocalizedDescriptionKey : "City services are inaccessible without a string/city to search for"])
            self.delegate?.citiesRequestFinishedWithError(self, error: error)
            return
        }
        
        // setting the GET request
        self.request.GET(Constants.WeatherUnderground.citiesURL, parameters: ["query" : searchString], success: {(response: HTTPResponse) in
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
            },failure: {(error: NSError, response: HTTPResponse?) in
                println("error: \(error)")
                
                dispatch_async(Constants.MultiThreading.mainQueue) {
                    // telling the delegate we have received an error
                    self.delegate?.citiesRequestFinishedWithError(self, error: error)
                }
        })
    }
    
    
    //MARK:
    //MARK: Weather Manager helper functions
    
    func checkForValidWeatherDataWithCity(city: String, state: String, locationId: String) {

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
    
    
    //MARK:
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
    
    
    //MARK:
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
    
    
    //MARK:
    //MARK: Weather condition icons
    
    func getWeatherImageForCondition(condition: String) -> UIImage {
        
        var image: UIImage?
        
        if(condition == "Light Drizzle" || condition == "Light Rain" || condition == "Light Freezing Drizzle" ||
            condition == "Light Freezing Rain" || condition == "Light Rain Showers" || condition == "Light Rain Mist")
        {
            image = UIImage(named: "little_rain-50")
        }
        else if(condition == "Heavy Rain" || condition == "Heavy Drizzle" || condition == "Heavy Freezing Drizzle" ||
            condition == "Heavy Freezing Rain" || condition == "Heavy Rain Showers" || condition == "Heavy Rain Mist")
        {
            image = UIImage(named: "rain-50")
        }
        else if(condition == "Patches of Fog" || condition == "Shallow Fog" || condition == "Partial Fog" || condition == "Light Fog" ||
            condition == "Heavy Fog" || condition == "Heavy Fog Patches" || condition == "Light Fog Patches")
        {
            if(self.appHelper.isCurrentTimeDayTime())
            {
                image = UIImage(named: "fog_day-50")
            }
            else
            {
                image = UIImage(named: "fog_night-50")
            }
        }
        else if(condition == "Clear" || condition == "Overcast" || condition == "Scattered Clouds")
        {
            if(self.appHelper.isCurrentTimeDayTime())
            {
                image = UIImage(named: "summer-50")
            }
            else
            {
                image = UIImage(named: "moon-50")
            }
        }
        else if(condition == "Partly Cloudy" || condition == "Mostly Cloudy" || condition == "Scattered Clouds" || condition == "Funnel Cloud")
        {
            if(self.appHelper.isCurrentTimeDayTime())
            {
                image = UIImage(named: "partly_cloudy_day-50")
            }
            else
            {
                image = UIImage(named: "partly_cloudy_night-50")
            }
        }
        else if(condition == "Heavy Snow" || condition == "Heavy Snow Grains" || condition == "Heavy Ice Crystals" || condition == "Heavy Ice Pellets" ||
            condition == "Heavy Blowing Snow" || condition == "Heavy Low Drifting Snow" || condition == "Heavy Snow Showers" || condition == "Heavy Snow Blowing Snow Mist")
        {
                image = UIImage(named: "snow-50")
        }
        else if(condition == "Light Snow" || condition == "Light Snow Grains" || condition == "Light Ice Crystals" || condition == "Light Ice Pellets" ||
            condition == "Light Blowing Snow" || condition == "Light Low Drifting Snow" || condition == "Light Snow Showers" || condition == "Light Snow Blowing Snow Mist")
        {
            image = UIImage(named: "light_snow-50")
        }
        else
        {
            if(self.appHelper.isCurrentTimeDayTime())
            {
                image = UIImage(named: "summer-50")
            }
            else
            {
                image = UIImage(named: "moon-50")
            }
        }
        
        return image!
    }

}