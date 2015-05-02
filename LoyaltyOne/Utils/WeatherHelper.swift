//
//  WeatherHelper.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-02.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit

class WeatherHelper: NSObject {

    let defaultURL: String = "http://api.openweathermap.org/data/2.5/weather?q=Toronto,ca"
    
    var json: JSON?
    
    //MARK:
    //MARK: Request Weather
    
    func requestWeatherFromAPIUrl(urlRequest: String) {
        
        var url = urlRequest
        var request = HTTPTask()
        
        if(url.isEmpty) {
            url = self.defaultURL
        }
        
        request.GET(url, parameters: nil, success: {(response: HTTPResponse) in
            if let data = response.responseObject as? NSData {
                
                self.json = JSON(data: data)
                
                println("response: \(self.json)")
                
            }
            },failure: {(error: NSError, response: HTTPResponse?) in
                println("error: \(error)")
        })
    }
    
    func getWeatherCondition() -> Dictionary<String, String> {
        
        if((self.json?.isEmpty) != nil) {
            self.requestWeatherFromAPIUrl("")
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
        
        if((self.json?.isEmpty) != nil) {
            self.requestWeatherFromAPIUrl("")
        }
        
        println("testing json: \(self.json)")
        
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
    
    func tempToCelcius(tempKelvin: NSNumber) -> NSNumber {
        return (tempKelvin.floatValue - 273.15)
    }
    
    func tempToFahrenheit(tempKelvin: NSNumber) -> NSNumber {
        return ((tempKelvin.floatValue * 9/5) - 459.67)
    }

}