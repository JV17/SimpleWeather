//
//  MainViewController.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-01.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, WeatherDataSource, AutoCompleteDelegate, LocationManagerDelegate {

    //MARK:
    //MARK: Properties

    let appHelper = AppHelper()
    let weatherManager = WeatherManager()
    let locationManager = LocationManager()

    //MARK:
    //MARK: Lazy loading

    lazy var autocompleteView: AutoCompleteSearchView = {
        var tmpView: AutoCompleteSearchView = AutoCompleteSearchView(frame: CGRectMake(15, CGRectGetMaxY(self.timeLabel.frame)+30, self.appHelper.screenSize.width-30, 250))
        tmpView.delegate = self
        
        return tmpView
    }()
    
    lazy var weatherView: WeatherView = {
        var tmpView: WeatherView = WeatherView(frame: CGRectMake(0, CGRectGetHeight(self.view.frame)-Constants.WeatherView.height, self.appHelper.screenSize.width-30, Constants.WeatherView.height))
        
        return tmpView
    }()
    
    lazy var blurredView: UIView = {
        var tmpView: UIView = UIView(frame: UIScreen.mainScreen().bounds)
        
        return tmpView
    }()
    
    lazy var cityLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(0, 5, self.appHelper.screenSize.width, 22))
        tmpLabel.font = UIFont(name: "Lato-Light", size: 22)
        tmpLabel.backgroundColor = UIColor.clearColor()
        tmpLabel.textColor = self.appHelper.colorWithHexString("F7F7F7")
        tmpLabel.textAlignment = NSTextAlignment.Center

        return tmpLabel
    }()
    
    lazy var timeLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(0, 30, self.appHelper.screenSize.width, 16))
        tmpLabel.font = UIFont(name: "Lato-Light", size: 16)
        tmpLabel.backgroundColor = UIColor.clearColor()
        tmpLabel.textColor = self.appHelper.colorWithHexString("F7F7F7")
        tmpLabel.textAlignment = NSTextAlignment.Center

        return tmpLabel
    }()
    
    
    //MARK:
    //MARK: Initializers

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup controller
        self.commonInit()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func commonInit() {
        
        self.locationManager.delegate = self
        self.locationManager.requestLocation()
        
        // making service call
        self.weatherManager.delegate = self
        self.weatherManager.requestWeatherForCity("Toronto,Ontario")
        
        // setting up the blurred background image
        self.setupBackgroundImage()
        
        // setting up current city and time labels
        self.setCityTimeLabels()
        
        self.view.addSubview(self.autocompleteView)
        
        self.view.addSubview(self.weatherView)
    }
    

    //MARK:
    //MARK: Controller helper functions
    
    func setCityTimeLabels() {

        // setting city label
        self.cityLabel.text = "Toronto"
        self.view.addSubview(self.cityLabel)
        
        // setting time label
        self.timeLabel.text = self.getCurrentTime()
        self.view.addSubview(self.timeLabel)
    }
    
    func setupBackgroundImage() {
       
        // we need to check if we have a correct image size to use as our background image
        let bgImage = appHelper.reSizeBackgroundImageIfNeeded(UIImage(named: "background1")!, newSize: self.appHelper.screenSize.size)
        
        self.view.backgroundColor = UIColor(patternImage: bgImage)
        
        // creating blurred view
        self.blurredView.backgroundColor = UIColor(patternImage: bgImage)
        appHelper.applyBlurToView(self.blurredView, withBlurEffectStyle: .Dark)
        self.blurredView.alpha = 0.9
        
        self.view.addSubview(self.blurredView)
    }
    
    func getCurrentTime() -> String {
        
        // we get current timestamp
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        
        return formatter.stringFromDate(date)
    }
    
    
    //MARK:
    //MARK: Location Manager delegate
    
    func locationFinishedUpdatingWithCity(cityName: String, postalCode: String, state: String, country: String, countryCode: String) {
        // get user location
        
        // print location info
        println("\(cityName)")
        println("\(postalCode)")
        println("\(state)")
        println("\(country)")
        println("\(countryCode)")
    }
    
    
    //MARK:
    //MARK: Weather Helper delegate
    
    func weatherRequestFinishedWithJSON(weatherHelper: WeatherManager, weatherJSON: JSON) {
        // let weather = self.weatherHelper.getWeatherMain()
        println("\n\ndelegate: \(weatherJSON)")
        
        if(!weatherJSON.isEmpty) {
            // extracting values from json
            let condition = weatherJSON["weather"][0]["description"].stringValue
            let max = weatherJSON["main"]["temp_max"].numberValue
            let low = weatherJSON["main"]["temp_min"].numberValue
            let currentTemp = weatherJSON["main"]["temp"].numberValue
            
            // updating labels
            self.weatherView.conditionLabel.text = "\(condition.capitalizeFirst)"
            self.weatherView.maxTempLabel.text = "\(self.weatherManager.tempToCelcius(max))"
            self.weatherView.lowTempLabel.text = "\(self.weatherManager.tempToCelcius(low))"
            self.weatherView.currentTempLabel.text = "\(self.weatherManager.tempToCelcius(currentTemp))"
        }

    }
    
    func weatherRequestFinishedWithError(weatherHelper: WeatherManager, error: NSError) {
        // error handling
        println("Request Error: \(error)")
    }

    
    //MARK:
    //MARK: Autocomplete Search View delegate
    
    func autocompleteFinishedWithSelectedCity(autocompleteView: AutoCompleteSearchView, selectedCity: String) {
        // make a new service call with the new city
        if(!selectedCity.isEmpty) {
            self.weatherManager.requestWeatherForCity(selectedCity)
        }
    }
    
}