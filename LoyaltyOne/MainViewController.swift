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
    
    var currentCity: String = String()
    var currentState: String = String()
    var locationID: String = String()
    var backgroundImage: UIImage?
    var isAutocompleteViewAnimating = Bool()

    //MARK:
    //MARK: Lazy loading
    
    var appHelper: AppHelper = {
        var tmpAppHelper: AppHelper = AppHelper()
        return tmpAppHelper
    }()
    
    var weatherManager: WeatherManager = {
        var tmpWeatherManager: WeatherManager = WeatherManager()
        return tmpWeatherManager
    }()
    
    var locationManager: LocationManager = {
        var tmpLocationManager: LocationManager = LocationManager()
        return tmpLocationManager
    }()
    
    lazy var fromBackgroundImageView: UIImageView = {
        var tmpImageView: UIImageView = UIImageView(frame: self.view.frame)
        return tmpImageView
    }()
    
    lazy var toBackgroundImageView: UIImageView = {
        var tmpImageView: UIImageView = UIImageView(frame: self.view.frame)
        return tmpImageView
    }()

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
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(0, 5, self.appHelper.screenSize.width, 26))
        tmpLabel.font = UIFont(name: "Lato-Light", size: 22)
        tmpLabel.backgroundColor = UIColor.clearColor()
        tmpLabel.textColor = self.appHelper.colorWithHexString("F7F7F7")
        tmpLabel.textAlignment = NSTextAlignment.Center

        return tmpLabel
    }()
    
    lazy var timeLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(0, CGRectGetMaxY(self.cityLabel.frame), self.appHelper.screenSize.width, 16))
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
        
        self.weatherManager.delegate = self
        
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
    
    func performNewWeatherServiceCallWithCity(city: String, state: String, locationId: String) {
        
        // making a new services call for city
        if(!city.isEmpty || !state.isEmpty) {
            dispatch_async(Constants.MultiThreading.backgroundQueue, {
                self.weatherManager.requestWeatherForCity(city, state: state, locationId: locationId, forCity: true)
            })
        }
        else if(!locationId.isEmpty) {
            dispatch_async(Constants.MultiThreading.backgroundQueue, {
                self.weatherManager.requestWeatherForCity(city, state: state, locationId: locationId, forCity: false)
            })
        }
        
    }
    
    func performNewWeatherForecastServiceCallWithCity(city: String, state: String, locationId: String) {

        // making a new services call for city
        if(!city.isEmpty || !state.isEmpty) {
            dispatch_async(Constants.MultiThreading.backgroundQueue, {
                self.weatherManager.requestWeatherForecastForCity(city, state: state, locationId: locationId, forCity: true)
            })
        }
        else if(!locationId.isEmpty) {
            dispatch_async(Constants.MultiThreading.backgroundQueue, {
                self.weatherManager.requestWeatherForecastForCity(city, state: state, locationId: locationId, forCity: false)
            })
        }
    }
    
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
        self.backgroundImage = appHelper.reSizeBackgroundImageIfNeeded(UIImage(named: "background1")!, newSize: self.appHelper.screenSize.size)

        self.fromBackgroundImageView.image = self.backgroundImage
        self.view.insertSubview(self.fromBackgroundImageView, atIndex: 0)
        
        // creating blurred view
        self.blurredView.backgroundColor = UIColor(patternImage: self.backgroundImage!)
        appHelper.applyBlurToView(self.blurredView, withBlurEffectStyle: .Dark)
        self.blurredView.alpha = 0.5
        
        self.view.addSubview(self.blurredView)
        
        // saving the first background image used
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: Constants.UserDefaults.backgroundImageNum)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func updateBackgroundImage() {
        
        // we check which background image we currently have
        var imageNum = NSUserDefaults.standardUserDefaults().integerForKey(Constants.UserDefaults.backgroundImageNum)

        switch imageNum {
        case 1:
            imageNum = 2
        case 2:
            imageNum = 3
        case 3:
            imageNum = 4
        case 4:
            imageNum = 5
        case 5:
            imageNum = 6
        case 6:
            imageNum = 7
        case 7:
            imageNum = 8
        case 8:
            imageNum = 9
        case 9:
            imageNum = 10
        case 10:
            imageNum = 1
        default:
            imageNum = 1
            
            // saving the new selected image
            NSUserDefaults.standardUserDefaults().setInteger(imageNum, forKey: Constants.UserDefaults.backgroundImageNum)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            return
        }
        
        let newImageName = "background" + "\(imageNum)"
        self.backgroundImage = appHelper.reSizeBackgroundImageIfNeeded(UIImage(named: newImageName)!, newSize: self.appHelper.screenSize.size)
        
        if((self.fromBackgroundImageView.window) != nil) {
            // switching between background images fromImageView toImageView
            self.toBackgroundImageView.alpha = 1.0
            self.toBackgroundImageView.image = self.backgroundImage
            self.view.insertSubview(self.toBackgroundImageView, belowSubview: self.fromBackgroundImageView)
            
            UIView.animateWithDuration(0.6, delay: 0.0, options: .CurveEaseOut, animations: {
                // animations
                self.fromBackgroundImageView.alpha = 0.0
                
                }, completion: { finished in
                    // after completion
                    self.fromBackgroundImageView.removeFromSuperview()
            })
        }
        else {
            // switching between background images toImageView fromImageView
            self.fromBackgroundImageView.alpha = 1.0
            self.fromBackgroundImageView.image = self.backgroundImage
            self.view.insertSubview(self.fromBackgroundImageView, belowSubview: self.toBackgroundImageView)
            
            UIView.animateWithDuration(0.6, delay: 0.0, options: .CurveEaseOut, animations: {
                // animations
                self.toBackgroundImageView.alpha = 0.0
                
                }, completion: { finished in
                    // after completion
                    self.toBackgroundImageView.removeFromSuperview()
            })
        }
        
        // saving the new selected image
        NSUserDefaults.standardUserDefaults().setInteger(imageNum, forKey: Constants.UserDefaults.backgroundImageNum)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getCurrentTime() -> String {
        
        // we get current timestamp
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        
        return formatter.stringFromDate(date)
    }
    
    func showAutocompleteView(button: UIButton) {
        
        if(self.isAutocompleteViewAnimating) {
            return
        }
        
        self.isAutocompleteViewAnimating = true
        
        if(self.autocompleteBtn.tag == 1) {
            
            // showing the keyboard as soon as the animation finished
            self.autocompleteView.textField.becomeFirstResponder()

            // autocomplete show animations
            UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .CurveEaseIn, animations: {
                
                self.autocompleteView.alpha = 1.0

                // show autocomplete from offset
                let oldFrame: CGRect = self.autocompleteView.frame
                self.autocompleteView.frame = CGRectMake(oldFrame.origin.x, CGRectGetMaxY(self.timeLabel.frame)+30, oldFrame.size.width, oldFrame.size.height)
                
                // auto complete button animations
                let transfrom: CGFloat = (CGFloat(M_PI*3)/4)
                self.autocompleteBtn.transform = CGAffineTransformRotate(CGAffineTransformIdentity, transfrom)
                
            }, completion: { finished in
                // completion handling
                self.autocompleteBtn.tag = 2
                self.isAutocompleteViewAnimating = false
            })
        }
        else {
            
            // hidding the keyboard
            self.autocompleteView.textField.resignFirstResponder()

            // autocomplete hide animations
            UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .CurveEaseIn, animations: {
                
                self.autocompleteView.alpha = 0.0
                
                // show autocomplete from offset
                let oldFrame: CGRect = self.autocompleteView.frame
                self.autocompleteView.frame = CGRectMake(oldFrame.origin.x, -80, oldFrame.size.width, oldFrame.size.height)
                
                // auto complete button animations
                let transfrom: CGFloat = (CGFloat(-M_PI*3)/4)
                self.autocompleteBtn.transform = CGAffineTransformRotate(self.autocompleteBtn.transform, transfrom)

            }, completion: { finished in
                // completion handling
                self.autocompleteView.clearAutocompleteTextField()
                self.autocompleteBtn.tag = 1
                self.isAutocompleteViewAnimating = false
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
    
    func locationFinishedUpdatingWithCity(locationManager: LocationManager, city: String, postalCode: String, state: String, country: String, countryCode: String) {
        // get user location
        
        println("state: " + state)
        
        // making service call with location data
        self.performNewWeatherServiceCallWithCity(city, state: country, locationId: "")
        self.currentCity = city
        self.currentState = country
        
        // saving current city to user defaults
        NSUserDefaults.standardUserDefaults().setObject(self.currentCity, forKey: Constants.UserDefaults.currentCity)
        NSUserDefaults.standardUserDefaults().setObject(self.currentState, forKey: Constants.UserDefaults.currentState)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func locationFinishedWithError(locationMAnager: LocationManager, error: NSError, errorMessage: String) {
        // error handling
        self.showLocationAlertControllerWithError(error, errorMessage: errorMessage)
    }
    
    
    //MARK:
    //MARK: Weather Helper delegate
    
    func weatherRequestFinishedWithJSON(weatherManager: WeatherManager, weatherJSON: JSON) {
        
        if(!weatherJSON.isEmpty) {
            // extracting values from json
            let condition = weatherJSON["current_observation"]["weather"].stringValue
            let max = weatherJSON["current_observation"]["temp_c"].numberValue
            let low = weatherJSON["current_observation"]["temp_c"].numberValue
            let currentTemp = weatherJSON["current_observation"]["temp_c"].numberValue
            self.currentCity = weatherJSON["current_observation"]["display_location"]["city"].stringValue
            self.currentState = weatherJSON["current_observation"]["display_location"]["state_name"].stringValue
            
            // loading forescast data
            if(self.locationID.isEmpty) {
                self.performNewWeatherForecastServiceCallWithCity(self.currentCity, state: self.currentState, locationId: "")
            }
            else {
                self.performNewWeatherForecastServiceCallWithCity("", state: "", locationId: self.locationID)
            }
            
            var newMax: Float = max.floatValue
            var newLow: Float = low.floatValue
            let ran = Float(rand() % 4)
            
            if(currentTemp.floatValue == newMax || currentTemp.floatValue == newLow) {
                newMax += ran
                newLow -= ran
            }
            
            // saving current temperature to user defaults
            let saveTempDic: [NSObject : AnyObject] = [Constants.UserDefaults.conditionKey : condition,
                                                       Constants.UserDefaults.maxTempKey : newMax,
                                                       Constants.UserDefaults.lowTempKey : newLow,
                                                       Constants.UserDefaults.currentTempKey : currentTemp]
            
            NSUserDefaults.standardUserDefaults().setObject(saveTempDic, forKey: Constants.UserDefaults.dicTempKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            // updating background image
            self.updateBackgroundImage()
            
            // updating labels animated
            self.weatherView.updateWeatherLabelsAnimated(condition,
                                                         maxTemp: self.weatherManager.numberFormatterWithNumber(newMax),
                                                         lowTemp: self.weatherManager.numberFormatterWithNumber(newLow),
                                                         currentTemp: self.weatherManager.numberFormatterWithNumber(currentTemp))
            
            // updating city label animated
            self.updateCityLabelAnimated(self.currentCity)
        }
    }
    
    func weatherRequestFinishedWithError(weatherManager: WeatherManager, error: NSError, serverError: Bool, city: String, state: String, locationId: String) {
        // error handling
        println("Error: \(error)")
        self.showWeatherAlertControllerWithError(error, serverError: serverError, city: city, state: state, locationId: locationId)
    }
    
    func citiesRequestFinishedWithJSON(weatherManager: WeatherManager, citiesJSON: JSON) {
        // empty delegate
    }
    
    func citiesRequestFinishedWithError(weatherManage: WeatherManager, error: NSError) {
        // empty delegate
    }

    func forecastWeatherRequestFinishedWithJSON(weatherManager: WeatherManager, forecastJSON: JSON) {
        // forecast finished with JSON
        if(!forecastJSON.isEmpty) {
            self.weatherView.loadForecastViewWithJSON(forecastJSON)
        }
    }
    
    func forecastWeatherRequestFinishedWithError(weatherManager: WeatherManager, error: NSError, city: String, state: String, locationId: String) {
        // error handling
        println("Error: \(error)")
        self.showWeatherForecastAlertControllerWithError(error, city: city, state: state, locationId: locationId)
    }
    
    //MARK:
    //MARK: Autocomplete Search View delegate
    
    func autocompleteFinishedWithLocationId(autocompleteView: AutoCompleteSearchView, locationId: String) {
        // make a new service call with the new city
        if(!locationId.isEmpty) {
            self.locationID = locationId
            self.performNewWeatherServiceCallWithCity("", state: "", locationId: locationId)
        }
    }
    
    
    //MARK:
    //MARK: Error handling
    
    func showLocationAlertControllerWithError(error: NSError, errorMessage: String) {
        
        let alert = UIAlertController(title: "Location Service Error", message: "\(errorMessage)", preferredStyle: UIAlertControllerStyle.Alert)
        
        // retry getting users location
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { action in
            switch action.style{
            case .Default:
                // retry getting users location
                self.locationManager.requestLocation()
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        
        // cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
            switch action.style{
            case .Default:
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func showWeatherAlertControllerWithError(error: NSError, serverError: Bool, city: String, state: String, locationId: String) {
        
        let alert = UIAlertController(title: "Weather Services Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)

        let title: String?
        
        if(serverError) {
            title = "Ok"
        }
        else {
            title = "Retry"
        }
        
        // retry getting weather from services action
        alert.addAction(UIAlertAction(title: title!, style: UIAlertActionStyle.Default, handler: { action in
            switch action.style {
            case .Default:
                if(title == "Ok") {
                    break
                }
                // retry getting weather from services
                if(!city.isEmpty && !state.isEmpty) {
                    self.performNewWeatherServiceCallWithCity(city, state: state, locationId: "")
                }
                else if(!locationId.isEmpty) {
                    self.performNewWeatherServiceCallWithCity("", state: "", locationId: locationId)
                }
                else if(!self.currentCity.isEmpty && !self.currentState.isEmpty) {
                    self.performNewWeatherServiceCallWithCity(self.currentCity, state: self.currentState, locationId: "")
                }
                else if(!self.locationID.isEmpty) {
                    self.performNewWeatherServiceCallWithCity("", state: "", locationId: self.locationID)
                }
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        
        // cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
            switch action.style {
            case .Default:
                println("default")
                
            case .Cancel:
                // show search bar to allow the user find a new location
                self.autocompleteBtn.tag = 1
                self.showAutocompleteView(self.autocompleteBtn)
                
            case .Destructive:
                println("destructive")
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showWeatherForecastAlertControllerWithError(error: NSError, city: String, state: String, locationId: String) {
        
        let alert = UIAlertController(title: "Weather Service Error", message: "\(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
        
        // retry getting weather from services action
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { action in
            switch action.style {
            case .Default:
                // retry getting weather from services
                if(!city.isEmpty && !state.isEmpty) {
                    self.performNewWeatherForecastServiceCallWithCity(city, state: state, locationId: "")
                }
                else if(!locationId.isEmpty) {
                    self.performNewWeatherForecastServiceCallWithCity("", state: "", locationId: locationId)
                }
                else if(!self.currentCity.isEmpty && !self.currentState.isEmpty) {
                    self.performNewWeatherForecastServiceCallWithCity(self.currentCity, state: self.currentState, locationId: "")
                }
                else if(!self.locationID.isEmpty) {
                    self.performNewWeatherForecastServiceCallWithCity("", state: "", locationId: self.locationID)
                }
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        
        // cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
            switch action.style {
            case .Default:
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}