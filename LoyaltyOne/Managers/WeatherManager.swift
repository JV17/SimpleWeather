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
    func weatherRequestFinishedWithError(weatherManager: WeatherManager, error: NSError, errorMessage: String, cityRequested: String)

    // this function allows us to know when we get the cities from open weather map
    func citiesRequestFinishedWithJSON(weatherManager: WeatherManager, citiesJSON: JSON)
    
    // this function allows us to get notify if an error occurred while doing the API call
    func citiesRequestFinishedWithError(weatherManage: WeatherManager, error: NSError)

    // this function allows us to know when we get the forecast weather from open weather map
    func forecastWeatherRequestFinishedWithJSON(weatherManager: WeatherManager, forecastJSON: JSON)

    // this function allows us to get notify if an error occurred while doing the API call
    func forecastWeatherRequestFinishedWithError(weatherManager: WeatherManager, error: NSError)
}


class WeatherManager: NSObject {
    
    //MARK:
    //MARK: Properties
    
    let request = HTTPTask()
    let weatherURL: String = "http://api.openweathermap.org/data/2.5/weather?"
    let weatherForecastURL: String = "http://api.openweathermap.org/data/2.5/forecast?"
    let citiesURL: String = "http://api.openweathermap.org/data/2.5/find?"
    let apiKey: String = "432dbd419b713483bc99b3cbcd13d5ab"
    var weatherJSON: JSON?
    var forecastJSON: JSON?
    var citiesJSON: JSON?
    var delegate: WeatherDataSource?
    
    
    //MARK:
    //MARK: Weather Manager requests
    
    func requestWeatherForCity(city: String) {
        
        if(city.isEmpty) {
            // telling the delegate we have received an error
            let error = NSError(domain: "Weather Services Error.", code: 404, userInfo: [NSLocalizedDescriptionKey : "Weather services are inaccessible without a city"])
            self.delegate?.weatherRequestFinishedWithError(self, error: error, errorMessage: error.localizedDescription, cityRequested: !city.isEmpty ? city : "Toronto")
            return
        }
        
        self.request.GET(self.weatherURL, parameters: ["q" : city, "APPID" : self.apiKey], success: {(response: HTTPResponse) in
            if let data = response.responseObject as? NSData {
                
                self.weatherJSON = JSON(data: data)
                
                // we need to avoid delays from our download task
                dispatch_async(Constants.MultiThreading.mainQueue) {
                    self.checkForValidWeatherDataWithCity(!city.isEmpty ? city : "Toronto")
                }
            }
            },failure: {(error: NSError, response: HTTPResponse?) in
                println("error: \(error)")

                dispatch_async(Constants.MultiThreading.mainQueue) {
                    // telling the delegate we have received an error
                    self.delegate?.weatherRequestFinishedWithError(self, error: error, errorMessage: error.localizedDescription, cityRequested: !city.isEmpty ? city : "Toronto")
                }
        })
    }
    
    func requestWeatherForecastForCity(city: String) {
        
        if(city.isEmpty) {
            // telling the delegate we have received an error
            let error = NSError(domain: "Weather Services Error.", code: 404, userInfo: [NSLocalizedDescriptionKey : "Weather services are inaccessible without a city"])
            self.delegate?.weatherRequestFinishedWithError(self, error: error, errorMessage: error.localizedDescription, cityRequested: !city.isEmpty ? city : "Toronto")
            return
        }
        
        self.request.GET(self.weatherForecastURL, parameters: ["q" : city, "APPID" : self.apiKey], success: {(response: HTTPResponse) in
            if let data = response.responseObject as? NSData {
                
                self.forecastJSON = JSON(data: data)
                
                println("\(self.forecastJSON?.dictionary)")
                
                // we need to avoid delays from our download task
                dispatch_async(Constants.MultiThreading.mainQueue) {
                    self.delegate?.forecastWeatherRequestFinishedWithJSON(self, forecastJSON: self.forecastJSON!)
                }
            }
            },failure: {(error: NSError, response: HTTPResponse?) in
                println("error: \(error)")
                
                dispatch_async(Constants.MultiThreading.mainQueue) {
                    // telling the delegate we have received an error
                    self.delegate?.forecastWeatherRequestFinishedWithError(self, error: error)
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
        
        self.request.GET(self.citiesURL, parameters: ["q" : searchString, "type" : "like"], success: {(response: HTTPResponse) in
            if let data = response.responseObject as? NSData {
                
                self.citiesJSON = JSON(data: data)
                
                // we need to avoid delays from our download task
                dispatch_async(Constants.MultiThreading.mainQueue) {
                    self.delegate?.citiesRequestFinishedWithJSON(self, citiesJSON: self.citiesJSON!)
                }
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
    
    func checkForValidWeatherDataWithCity(city: String) {

        // we need to check if we have weather data
        if((self.weatherJSON?.isEmpty) == nil) {
            self.requestWeatherForCity("")
        }
        
        if ((self.weatherJSON!["message"].string) != nil) {
            // error handling
            let errorMessage = self.weatherJSON!["message"].stringValue + ","
            let errorCode = self.weatherJSON!["cod"].intValue
            let error = NSError(domain: errorMessage, code: errorCode, userInfo: nil)

            // tells the delegate we couldn't find the city
            self.delegate?.weatherRequestFinishedWithError(self, error: error, errorMessage: error.localizedDescription, cityRequested: city)
        }
        else {
            // saving current weather condition to match with proper icons
            self.saveCurrentWeatherConditionFromJSON(self.weatherJSON!)
            
            // telling the delegate we have received data from our API call
            self.delegate?.weatherRequestFinishedWithJSON(self, weatherJSON: self.weatherJSON!)
        }
    }
    
    func getWeatherCondition() -> Dictionary<String, String> {
        
        // we need to check if we have weather data
        if((self.weatherJSON?.isEmpty) == nil) {
            self.requestWeatherForCity("")
        }
        
        var dictionary = Dictionary<String, String>()
        
        if ((self.weatherJSON!["weather"].string) != nil) {
            dictionary = ["id": self.weatherJSON!["id"].stringValue,
                          "main": self.weatherJSON!["main"].stringValue,
                          "icon": self.weatherJSON!["icon"].stringValue,
                          "description": self.weatherJSON!["description"].stringValue]
        }
        else {
            dictionary = ["id": "n/a",
                          "main": "n/a",
                          "icon": "n/a",
                          "description": "n/a"]
        }
        
        return dictionary
    }
    
    func getWeatherMain() -> Dictionary<String, String> {
        
        // we need to check if we have weather data
        if((self.weatherJSON?.isEmpty) == nil) {
            self.requestWeatherForCity("")
        }
        
        var dictionary = Dictionary<String, String>()
        
        if ((self.weatherJSON!["main"].string) != nil) {
            dictionary = ["humidity": self.weatherJSON!["humidity"].stringValue,
                          "temp_min": self.weatherJSON!["temp_min"].stringValue,
                          "temp_max": self.weatherJSON!["temp_max"].stringValue,
                          "temp": self.weatherJSON!["temp"].stringValue,
                          "pressure": self.weatherJSON!["pressure"].stringValue,
                          "sea_level": self.weatherJSON!["sea_level"].stringValue,
                          "grnd_level": self.weatherJSON!["grnd_level"].stringValue]
        }
        else {
            dictionary = ["humidity": "n/a",
                          "temp_min": "n/a",
                          "temp_max": "n/a",
                          "temp": "n/a",
                          "pressure": "n/a",
                          "sea_level": "n/a",
                          "grnd_level": "n/a"]
        }
        
        return dictionary
    }
    
    func saveCurrentWeatherConditionFromJSON(weatherJSON: JSON) {
        
        // we need to check if we have weather data
        if((self.weatherJSON?.isEmpty) == nil) {
            self.requestWeatherForCity("")
        }
        
        if (!weatherJSON.isEmpty) {
            // getting current condition from json
            let currentCondition = weatherJSON["weather"][0]["main"].stringValue
            let currentConditionDesc = weatherJSON["weather"][0]["description"].stringValue
            
            // saving current condition to defaults
            NSUserDefaults.standardUserDefaults().setObject(currentCondition, forKey: Constants.UserDefaults.currentConditionKey)
            NSUserDefaults.standardUserDefaults().setObject(currentCondition, forKey: Constants.UserDefaults.currentCondtionDescKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    
    //MARK:
    //MARK: Temperature conversation
    
    func tempToCelcius(tempKelvin: NSNumber) -> String {
        return self.numberFormatterWithNumber((tempKelvin.floatValue - 273.15))
    }
    
    func tempToFahrenheit(tempKelvin: NSNumber) -> String {
        return self.numberFormatterWithNumber((((tempKelvin.floatValue - 273.15) * 1.8) + 32.00))
    }
    
    func numberFormatterWithNumber(number: NSNumber) -> String {
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

    func getSavedKelvinMaxTemperature() -> NSNumber {

        if let tempDic = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.UserDefaults.dicTempKey) {
            if let maxTemp = tempDic[Constants.UserDefaults.maxTempKey] as? NSNumber {
                return maxTemp
            }
        }
        
        return 0
    }
    
    func getSavedKelvinLowTemperature() -> NSNumber {
        
        if let tempDic = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.UserDefaults.dicTempKey) {
            if let lowTemp = tempDic[Constants.UserDefaults.lowTempKey] as? NSNumber {
                return lowTemp
            }
        }
        
        return 0
    }

    func getSavedKelvinCurrentTemperature() -> NSNumber {
        
        if let tempDic = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.UserDefaults.dicTempKey) {
            if let currentTemp = tempDic[Constants.UserDefaults.currentTempKey] as? NSNumber {
                return currentTemp
            }
        }
        
        return 0
    }
}