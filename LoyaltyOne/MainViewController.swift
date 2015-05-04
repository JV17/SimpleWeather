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
        var tmpView: AutoCompleteSearchView = AutoCompleteSearchView(frame: CGRectMake(15, -250, self.appHelper.screenSize.width-30, 250))
        tmpView.delegate = self
        
        return tmpView
    }()
    
    lazy var weatherView: WeatherView = {
        var tmpView: WeatherView = WeatherView(frame: CGRectMake(0, CGRectGetHeight(self.view.frame)-Constants.WeatherView.height, self.appHelper.screenSize.width, Constants.WeatherView.height))
        
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
    
    lazy var autocompleteBtn: UIButton = {
        var tmpBtn: UIButton = UIButton(frame: CGRectMake(CGRectGetMaxX(self.view.frame)-60, 10, 50, 50))
        tmpBtn.backgroundColor = UIColor.clearColor()
        tmpBtn.tag = 1
        tmpBtn.setImage(UIImage(named: "plus-48"), forState: UIControlState.Normal)
        tmpBtn.addTarget(self, action: "showAutocompleteView:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return tmpBtn
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
        
        // setting up the blurred background image
        self.setupBackgroundImage()
        
        // setting up current city and time labels
        self.setCityTimeLabels()
        
        self.view.addSubview(self.weatherView)
        self.view.addSubview(self.autocompleteView)
        self.view.addSubview(self.autocompleteBtn)
    }
    

    //MARK:
    //MARK: Controller helper functions
    
    func setCityTimeLabels() {

        // setting city label
        self.cityLabel.text = "Loading..."
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
        self.blurredView.alpha = 0.7
        
        self.view.addSubview(self.blurredView)
    }
    
    func getCurrentTime() -> String {
        
        // we get current timestamp
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        
        return formatter.stringFromDate(date)
    }
    
    func showAutocompleteView(button: UIButton) {
        
        if(button.tag == 1) {
            
            // showing the keyboard as soon as the animation finished
            self.autocompleteView.textField.becomeFirstResponder()

            // autocomplete show animations
            UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .CurveEaseIn, animations: {
                
                self.autocompleteView.alpha = 1.0
                
                // show autocomplete from offset
                let oldFrame: CGRect = self.autocompleteView.frame
                self.autocompleteView.frame = CGRectMake(oldFrame.origin.x, CGRectGetMaxY(self.timeLabel.frame)+30, oldFrame.size.width, oldFrame.size.height)
                
            }, completion: { finished in
                // completion handling
                self.autocompleteBtn.tag = 2
            })
        }
        else {
            
            // hidding the keyboard
            self.autocompleteView.textField.resignFirstResponder()

            // autocomplete hide animations
            UIView.animateWithDuration(1.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: .CurveEaseIn, animations: {
                
                self.autocompleteView.alpha = 0.0
                
                // show autocomplete from offset
                let oldFrame: CGRect = self.autocompleteView.frame
                self.autocompleteView.frame = CGRectMake(oldFrame.origin.x, -100, oldFrame.size.width, oldFrame.size.height)
                
            }, completion: { finished in
                // completion handling
                self.autocompleteView.clearAutocompleteTextField()
                self.autocompleteBtn.tag = 1
            })
        }
    }
    
    func updateCityLabelAnimated(city: String) {
        
        if(city.isEmpty) {
            return
        }
        
        // city animation
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseIn, animations: {
            
            self.cityLabel.alpha = 0.0
            
            }, completion: { finished in

                // completion handling
                self.cityLabel.text = city
                
                // fade in animation
                UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseIn, animations: {
                    
                    self.cityLabel.alpha = 1.0
                    
                    }, completion: { finished in
                        // completion handling
                })
        })
    }
    
    
    //MARK:
    //MARK: Location Manager delegate
    
    func locationFinishedUpdatingWithCity(cityName: String, postalCode: String, state: String, country: String, countryCode: String) {
        // get user location
        
        // making service call with location data
        self.weatherManager.delegate = self
        self.weatherManager.requestWeatherForCity(cityName)
        
        // print location info
        println("\(cityName)")
        println("\(postalCode)")
        println("\(state)")
        println("\(country)")
        println("\(countryCode)")
    }
    
    
    //MARK:
    //MARK: Weather Helper delegate
    
    func weatherRequestFinishedWithJSON(weatherManager: WeatherManager, weatherJSON: JSON) {
        // let weather = self.weatherHelper.getWeatherMain()
        println("\n\ndelegate: \(weatherJSON)")
        
        if(!weatherJSON.isEmpty) {
            // extracting values from json
            let condition = weatherJSON["weather"][0]["description"].stringValue
            let max = weatherJSON["main"]["temp_max"].numberValue
            let low = weatherJSON["main"]["temp_min"].numberValue
            let currentTemp = weatherJSON["main"]["temp"].numberValue
            let city = weatherJSON["name"].stringValue
            
            // saving current temperature to user defaults
            let saveTempDic: [NSObject : AnyObject] = [Constants.UserDefaults.conditionKey : condition,
                                                       Constants.UserDefaults.maxTempKey : max,
                                                       Constants.UserDefaults.lowTempKey : low,
                                                       Constants.UserDefaults.currentTempKey : currentTemp]
            
            NSUserDefaults.standardUserDefaults().setObject(saveTempDic, forKey: Constants.UserDefaults.dicTempKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            // updating labels animated
            self.weatherView.updateWeatherLabelsAnimated(condition.capitalizeFirst,
                                                         maxTemp: self.weatherManager.tempToCelcius(max),
                                                         lowTemp: self.weatherManager.tempToCelcius(low),
                                                         currentTemp: self.weatherManager.tempToCelcius(currentTemp))
            
            // updating city label animated
            self.updateCityLabelAnimated(city)
        }
    }
    
    func weatherRequestFinishedWithError(weatherManager: WeatherManager, error: NSError) {
        // error handling
        println("Request Error: \(error)")
    }
    
    func citiesRequestFinishedWithJSON(weatherManager: WeatherManager, citiesJSON: JSON) {
        // empty delegate
    }
    
    func citiesRequestFinishedWithError(weatherManage: WeatherManager, error: NSError) {
        // empty delegate
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