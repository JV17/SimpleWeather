//
//  ViewController.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-01.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WeatherDataSource {

    //MARK:
    //MARK: Properties

    let appHelper = AppHelper()
    let weatherHelper = WeatherHelper()
    let screenSize = UIScreen.mainScreen().bounds
    
    
    //MARK:
    //MARK: Lazy loading

    lazy var autocompleteView: AutoCompleteSearchView = {
        var tmpView: AutoCompleteSearchView = AutoCompleteSearchView(frame: CGRectMake(15, CGRectGetMaxY(self.timeLabel.frame)+30, self.screenSize.width-30, 250))

        return tmpView
    }()
    
    lazy var blurredView: UIView = {
        var tmpView: UIView = UIView(frame: UIScreen.mainScreen().bounds)
        
        return tmpView
    }()
    
    lazy var cityLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(0, 5, self.screenSize.width, 22))
        
        return tmpLabel
    }()
    
    lazy var timeLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(0, 30, self.screenSize.width, 16))
        
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
        
        // making service call
        self.weatherHelper.delegate = self
        self.weatherHelper.requestWeatherFromAPIUrl("")
        
        // setting up the blurred background image
        self.setupBackgroundImage()
        
        // setting up current city and time labels
        self.setCityTimeLabels()
        
        self.view.addSubview(self.autocompleteView)
        
    }
    

    //MARK:
    //MARK: Controller helper functions
    
    func setCityTimeLabels() {
        // setting city label
        self.cityLabel.font = UIFont(name: "Lato-Light", size: 22)
        self.cityLabel.backgroundColor = UIColor.clearColor()
        self.cityLabel.textColor = appHelper.colorWithHexString("F7F7F7")
        self.cityLabel.textAlignment = NSTextAlignment.Center
        self.cityLabel.text = "Toronto"
        
        self.view.addSubview(self.cityLabel)
        
        // setting time label
        self.timeLabel.font = UIFont(name: "Lato-Light", size: 16)
        self.timeLabel.backgroundColor = UIColor.clearColor()
        self.timeLabel.textColor = appHelper.colorWithHexString("F7F7F7")
        self.timeLabel.textAlignment = NSTextAlignment.Center
        self.timeLabel.text = self.getCurrentTime()
        
        self.view.addSubview(self.timeLabel)
    }
    
    func setupBackgroundImage() {
       
        // we need to check if we have a correct image size to use as our background image
        let bgImage = appHelper.reSizeBackgroundImageIfNeeded(UIImage(named: "background1")!, newSize: self.screenSize.size)
        
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
    //MARK: Weather Helper delegate
    
    func weatherRequestFinishedWithJSON(weatherHelper: WeatherHelper, weatherJSON: JSON) {
        // let weather = self.weatherHelper.getWeatherMain()
        println("\n\ndelegate: \(weatherJSON)")
    }
    
    func weatherRequestFinishedWithError(weatherHelper: WeatherHelper, error: NSError) {
        // error handling
    }
    
}