//
//  WeatherManager.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-02.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit

protocol WeatherDataSource {
    // this function allows us to know when we get data from our API call
    func weatherRequestFinishedWithJSON(weatherHelper: WeatherManager, weatherJSON: JSON)
    
    // this function allows us to get notify if an error occurred while doing the API call
    func weatherRequestFinishedWithError(weatherHelper: WeatherManager, error: NSError)
}

class WeatherManager: NSObject {
    
    // url call for cities by country name
    // "http://ws.geonames.org/searchJSON?country=usa&maxRows=1000&username=jvdev"
    
    // url call for weather underground
    // "http://api.wunderground.com/api/87c31015035f8c5b/conditions/q/ON/Toronto.json"
    
    // url call for open weather map
    // "http://api.openweathermap.org/data/2.5/weather?q=Toronto,ca"
    
    let defaultURL: String = "http://api.openweathermap.org/data/2.5/weather?q="
    var json: JSON?
    var delegate: WeatherDataSource?
    
    
    //MARK:
    //MARK: Request Weather
    
    func requestWeatherForCity(city: String) {
        
        var url = String()
        var request = HTTPTask()
        
        if(city.isEmpty) {
            url = self.defaultURL+"Toronto"
        }
        else {
            url = self.defaultURL+city
        }
        
        request.GET(url, parameters: nil, success: {(response: HTTPResponse) in
            if let data = response.responseObject as? NSData {
                
                self.json = JSON(data: data)
                
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
    
    func checkForValidWeatherData() {

        // we need to check if we have weather data
        if((self.json?.isEmpty) == nil) {
            self.requestWeatherForCity("")
        }
        
        if ((self.json!["message"].string) != nil) {
            // error handling
            let errorMessage = self.json!["message"].stringValue
            println("\(errorMessage)")
        }
        else {
            // telling the delegate we have received data from our API call
            self.delegate?.weatherRequestFinishedWithJSON(self, weatherJSON: self.json!)
        }
    }
    
    func getWeatherCondition() -> Dictionary<String, String> {
        
        // we need to check if we have weather data
        if((self.json?.isEmpty) == nil) {
            self.requestWeatherForCity("")
        }
        
        var dictionary = Dictionary<String, String>()
        
        if ((self.json!["weather"].string) != nil) {
            dictionary = ["id": self.json!["id"].stringValue,
                          "main": self.json!["main"].stringValue,
                          "icon": self.json!["icon"].stringValue,
                          "description": self.json!["description"].stringValue]
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
        if((self.json?.isEmpty) == nil) {
            self.requestWeatherForCity("")
        }
        
        var dictionary = Dictionary<String, String>()
        
        if ((self.json!["main"].string) != nil) {
            dictionary = ["humidity": self.json!["humidity"].stringValue,
                          "temp_min": self.json!["temp_min"].stringValue,
                          "temp_max": self.json!["temp_max"].stringValue,
                          "temp": self.json!["temp"].stringValue,
                          "pressure": self.json!["pressure"].stringValue,
                          "sea_level": self.json!["sea_level"].stringValue,
                          "grnd_level": self.json!["grnd_level"].stringValue]
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