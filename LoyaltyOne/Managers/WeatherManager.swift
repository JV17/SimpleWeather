//
//  WeatherManager.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-02.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit

protocol WeatherDataSource {
    // this function allows us to know when we get the weather data from open weather map
    func weatherRequestFinishedWithJSON(weatherManager: WeatherManager, weatherJSON: JSON)
    
    // this function allows us to get notify if an error occurred while doing the API call
    func weatherRequestFinishedWithError(weatherManager: WeatherManager, error: NSError)

    // this function allows us to know when we get the cities from open weather map
    func citiesRequestFinishedWithJSON(weatherManager: WeatherManager, citiesJSON: JSON)
    
    // this function allows us to get notify if an error occurred while doing the API call
    func citiesRequestFinishedWithError(weatherManage: WeatherManager, error: NSError)
}

class WeatherManager: NSObject {
    
    // url call for cities by country name
    // "http://ws.geonames.org/searchJSON?country=usa&maxRows=1000&username=jvdev"
    
    // url call for weather underground
    // "http://api.wunderground.com/api/87c31015035f8c5b/conditions/q/ON/Toronto.json"
    
    // url call for open weather map
    // "http://api.openweathermap.org/data/2.5/weather?q=Toronto,ca"
    
    let request = HTTPTask()
    let weatherURL: String = "http://api.openweathermap.org/data/2.5/weather?q="
    let citiesURL: String = "http://api.openweathermap.org/data/2.5/find?q="
    let apiKey: String = "&APPID=432dbd419b713483bc99b3cbcd13d5ab"
    var weatherJSON: JSON?
    var citiesJSON: JSON?
    var delegate: WeatherDataSource?
    
    
    //MARK:
    //MARK: Request Weather
    
    func requestWeatherForCity(city: String) {
        
        var url = String()
        
        if(city.isEmpty) {
            url = self.weatherURL + "Toronto" + self.apiKey
        }
        else {
            url = self.weatherURL + city + self.apiKey
        }
        
        self.request.GET(url, parameters: nil, success: {(response: HTTPResponse) in
            if let data = response.responseObject as? NSData {
                
                self.weatherJSON = JSON(data: data)
                
                // we need to avoid delays from our download task
                dispatch_async(dispatch_get_main_queue()) {
                    self.checkForValidWeatherData()
                }
            }
            },failure: {(error: NSError, response: HTTPResponse?) in
                println("error: \(error)")

                dispatch_async(dispatch_get_main_queue()) {
                    // telling the delegate we have received an error
                    self.delegate?.weatherRequestFinishedWithError(self, error: error)
                }
        })
    }
    
    func requestCitiesFromString(string: String) {
        
        var url = String()
        
        if(string.isEmpty) {
            return
        }
        else {
            url = self.citiesURL + string + "&type=like"
        }
        
        self.request.GET(url, parameters: nil, success: {(response: HTTPResponse) in
            if let data = response.responseObject as? NSData {
                
                self.citiesJSON = JSON(data: data)
                
                println("\(self.citiesJSON)")
                
                // we need to avoid delays from our download task
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.citiesRequestFinishedWithJSON(self, citiesJSON: self.citiesJSON!)
                }
            }
            },failure: {(error: NSError, response: HTTPResponse?) in
                println("error: \(error)")
                
                dispatch_async(dispatch_get_main_queue()) {
                    // telling the delegate we have received an error
                    self.delegate?.citiesRequestFinishedWithError(self, error: error)
                }
        })
    }
    
    func checkForValidWeatherData() {

        // we need to check if we have weather data
        if((self.weatherJSON?.isEmpty) == nil) {
            self.requestWeatherForCity("")
        }
        
        if ((self.weatherJSON!["message"].string) != nil) {
            // error handling
            let errorMessage = self.weatherJSON!["message"].stringValue
            println("\(errorMessage)")
        }
        else {
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
    
    func tempToCelcius(tempKelvin: NSNumber) -> String {
        return self.numberFormatterWithNumber((tempKelvin.floatValue - 273.15))
    }
    
    func tempToFahrenheit(tempKelvin: NSNumber) -> String {
        return self.numberFormatterWithNumber(((tempKelvin.floatValue * 9/5) - 459.67))
    }
    
    func numberFormatterWithNumber(number: NSNumber) -> String {
        let formatter = NSNumberFormatter()
        formatter.positiveFormat = "0"
        
        return formatter.stringFromNumber(number)!
    }

}