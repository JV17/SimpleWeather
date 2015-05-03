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
                    // telling the delegate we have received data from our API call
                    self.delegate?.weatherRequestFinishedWithJSON(self, weatherJSON: self.json!)
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
    
    func getWeatherCondition() -> Dictionary<String, String> {
        
        // we need to check if we have weather data
        if((self.json?.isEmpty) == nil) {
            self.requestWeatherForCity("")
        }
        
        var dictionary = Dictionary<String, String>()
        
        if let weatherDic = self.json?["weather"] {
            dictionary = ["id": weatherDic["id"].stringValue,
                          "main": weatherDic["main"].stringValue,
                          "icon": weatherDic["icon"].stringValue,
                          "description": weatherDic["description"].stringValue]
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
        
        if let weatherDic = self.json?["main"] {
            dictionary = ["humidity": weatherDic["humidity"].stringValue,
                          "temp_min": weatherDic["temp_min"].stringValue,
                          "temp_max": weatherDic["temp_max"].stringValue,
                          "temp": weatherDic["temp"].stringValue,
                          "pressure": weatherDic["pressure"].stringValue,
                          "sea_level": weatherDic["sea_level"].stringValue,
                          "grnd_level": weatherDic["grnd_level"].stringValue]
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
        formatter.positiveFormat = "0.#"
        
        return formatter.stringFromNumber(number)!
    }

}