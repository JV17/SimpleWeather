//
//  WeatherView.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-03.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit

class WeatherView: UIView {

    //MARK:
    //MARK: Properties
    
    let appHelper = AppHelper()

    //MARK:
    //MARK: Lazy loading properties
    
    lazy var loadingLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.height))
        
        tmpLabel.font = UIFont(name: Constants.WeatherView.fontFamily, size: Constants.WeatherView.loadingFontSize)
        tmpLabel.backgroundColor = UIColor.clearColor()
        tmpLabel.textColor = self.appHelper.colorWithHexString(Constants.WeatherView.fontColor)
        tmpLabel.textAlignment = NSTextAlignment.Center
        tmpLabel.text = "Loading..."
        
        return tmpLabel
    }()
    
    lazy var conditionImageView: UIImageView = {
        var tmpImgView: UIImageView = UIImageView(frame: CGRectMake(Constants.WeatherView.labelsX,
                                                                    0,
                                                                    Constants.WeatherView.conditionHeight,
                                                                    Constants.WeatherView.conditionHeight))
        tmpImgView.image = UIImage(named: "summer-50")
        tmpImgView.alpha = 0.0
        
        return tmpImgView
    }()
    
    lazy var conditionLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(CGRectGetMaxX(self.conditionImageView.frame)+4,
                                                          0,
                                                          self.frame.width-self.conditionImageView.frame.width-Constants.WeatherView.labelsX,
                                                          Constants.WeatherView.conditionHeight))
        
        tmpLabel.font = UIFont(name: Constants.WeatherView.fontFamily, size: Constants.WeatherView.conditionFontSize)
        tmpLabel.backgroundColor = UIColor.clearColor()
        tmpLabel.textColor = self.appHelper.colorWithHexString(Constants.WeatherView.fontColor)
        tmpLabel.textAlignment = NSTextAlignment.Left
        tmpLabel.text = "Loading..."
        tmpLabel.alpha = 0.0

        return tmpLabel
    }()
    
    lazy var maxTempImageView: UIImageView = {
        var tmpImgView: UIImageView = UIImageView(frame: CGRectMake(Constants.WeatherView.labelsX,
                                                                    CGRectGetMaxY(self.conditionLabel.frame)+10,
                                                                    Constants.WeatherView.lowHightHeigt/2,
                                                                    Constants.WeatherView.lowHightHeigt/2))
        tmpImgView.image = UIImage(named: "up-50")
        tmpImgView.alpha = 0.0
        
        return tmpImgView
    }()
    
    lazy var maxTempLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(CGRectGetMaxX(self.maxTempImageView.frame),
                                                          CGRectGetMaxY(self.conditionLabel.frame),
                                                          Constants.WeatherView.lowHightWidth,
                                                          Constants.WeatherView.lowHightHeigt))
        
        tmpLabel.font = UIFont(name: Constants.WeatherView.fontFamily, size: Constants.WeatherView.lowHighFontSize)
        tmpLabel.backgroundColor = UIColor.clearColor()
        tmpLabel.textColor = self.appHelper.colorWithHexString(Constants.WeatherView.fontColor)
        tmpLabel.textAlignment = NSTextAlignment.Left
        tmpLabel.text = "  ..."
        tmpLabel.alpha = 0.0
        
        return tmpLabel
    }()
    
    lazy var lowTempImageView: UIImageView = {
        var tmpImgView: UIImageView = UIImageView(frame: CGRectMake(CGRectGetMaxX(self.maxTempLabel.frame)+4,
                                                                    CGRectGetMaxY(self.conditionLabel.frame)+10,
                                                                    Constants.WeatherView.lowHightHeigt/2,
                                                                    Constants.WeatherView.lowHightHeigt/2))
        tmpImgView.image = UIImage(named: "down-50")
        tmpImgView.alpha = 0.0
        
        return tmpImgView
    }()
    
    lazy var lowTempLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(CGRectGetMaxX(self.lowTempImageView.frame),
                                                          CGRectGetMaxY(self.conditionLabel.frame),
                                                          Constants.WeatherView.lowHightWidth,
                                                          Constants.WeatherView.lowHightHeigt))
        
        tmpLabel.font = UIFont(name: Constants.WeatherView.fontFamily, size: Constants.WeatherView.lowHighFontSize)
        tmpLabel.backgroundColor = UIColor.clearColor()
        tmpLabel.textColor = self.appHelper.colorWithHexString(Constants.WeatherView.fontColor)
        tmpLabel.textAlignment = NSTextAlignment.Left
        tmpLabel.text = " ..."
        tmpLabel.alpha = 0.0
        
        return tmpLabel
    }()
    
    lazy var currentTempLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(Constants.WeatherView.tempX,
                                                          CGRectGetMaxY(self.maxTempLabel.frame),
                                                          self.frame.width/2,
                                                          Constants.WeatherView.tempHeight))
        
        tmpLabel.font = UIFont(name: Constants.WeatherView.fontFamily, size: Constants.WeatherView.tempFontSize)
        tmpLabel.backgroundColor = UIColor.clearColor()
        tmpLabel.textColor = self.appHelper.colorWithHexString(Constants.WeatherView.fontColor)
        tmpLabel.textAlignment = NSTextAlignment.Left
        tmpLabel.text = " ..."
        tmpLabel.alpha = 0.0
        
        return tmpLabel
    }()
    
    lazy var celciusButton: UIButton = {
        var tmpButton: UIButton = UIButton(frame: CGRectMake(self.frame.width-Constants.WeatherView.buttonSize*2-10,
                                                             CGRectGetMaxY(self.currentTempLabel.frame)-Constants.WeatherView.buttonSize+5,
                                                             Constants.WeatherView.buttonSize,
                                                             Constants.WeatherView.buttonSize))
        
        tmpButton.backgroundColor = UIColor.clearColor()
        tmpButton.titleLabel?.font = UIFont(name: Constants.WeatherView.fontFamily, size: Constants.WeatherView.buttonFontSize)
        tmpButton.titleLabel?.textColor = self.appHelper.colorWithHexString(Constants.WeatherView.fontColor)
        tmpButton.titleLabel?.textAlignment = NSTextAlignment.Right
        tmpButton.setTitle("ºC", forState: UIControlState.Normal)
        tmpButton.setTitleColor(self.appHelper.colorWithHexString(Constants.WeatherView.buttonColor), forState: UIControlState.Normal)
        tmpButton.setTitleColor(self.appHelper.colorWithHexString(Constants.WeatherView.buttonHighlightedColor), forState: UIControlState.Highlighted)
        tmpButton.setTitleColor(self.appHelper.colorWithHexString(Constants.WeatherView.buttonHighlightedColor), forState: UIControlState.Selected)
        tmpButton.addTarget(self, action: "changeTemperatureToCelcius:", forControlEvents: UIControlEvents.TouchUpInside)
        tmpButton.alpha = 0.0
        
        return tmpButton
    }()
    
    lazy var dividerLine: UIView = {
        var tmpView: UIView = UIView(frame: CGRectMake(CGRectGetMaxX(self.celciusButton.frame),
                                                       CGRectGetMaxY(self.currentTempLabel.frame)-Constants.WeatherView.buttonSize+15,
                                                       1,
                                                       Constants.WeatherView.dividerLineHeight))
        
        tmpView.backgroundColor = self.appHelper.colorWithHexString(Constants.WeatherView.fontColor)
        tmpView.alpha = 0.0
        
        return tmpView
    }()
    
    lazy var fahranheitButton: UIButton = {
        var tmpButton: UIButton = UIButton(frame: CGRectMake(CGRectGetMaxX(self.celciusButton.frame)+1,
                                                             CGRectGetMaxY(self.currentTempLabel.frame)-Constants.WeatherView.buttonSize+5,
                                                             Constants.WeatherView.buttonSize,
                                                             Constants.WeatherView.buttonSize))
        
        tmpButton.backgroundColor = UIColor.clearColor()
        tmpButton.titleLabel?.font = UIFont(name: Constants.WeatherView.fontFamily, size: Constants.WeatherView.buttonFontSize)
        tmpButton.titleLabel?.textColor = self.appHelper.colorWithHexString(Constants.WeatherView.fontColor)
        tmpButton.titleLabel?.textAlignment = NSTextAlignment.Left
        tmpButton.setTitle("ºF", forState: UIControlState.Normal)
        tmpButton.setTitleColor(self.appHelper.colorWithHexString(Constants.WeatherView.buttonColor), forState: UIControlState.Normal)
        tmpButton.setTitleColor(self.appHelper.colorWithHexString(Constants.WeatherView.buttonHighlightedColor), forState: UIControlState.Highlighted)
        tmpButton.setTitleColor(self.appHelper.colorWithHexString(Constants.WeatherView.buttonHighlightedColor), forState: UIControlState.Selected)
        tmpButton.addTarget(self, action: "changeTemperatureToFahranheit:", forControlEvents: UIControlEvents.TouchUpInside)
        tmpButton.alpha = 0.0
        
        return tmpButton
    }()
    
    
    //MARK:
    //MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // setting up view
        self.commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        
        // celcius is by default the temp measurement
        self.celciusButton.selected = true
        
        // adding labels to view
        self.addSubview(self.conditionImageView)
        self.addSubview(self.conditionLabel)
        self.addSubview(self.maxTempImageView)
        self.addSubview(self.maxTempLabel)
        self.addSubview(self.lowTempImageView)
        self.addSubview(self.lowTempLabel)
        self.addSubview(self.currentTempLabel)
        self.addSubview(self.celciusButton)
        self.addSubview(self.dividerLine)
        self.addSubview(self.fahranheitButton)
        
        // adding default label
        self.addSubview(self.loadingLabel)
    
    }
    
    
    //MARK:
    //MARK: Weather View animations
    
    func updateWeatherLabelsAnimated(condition: String, maxTemp: String, lowTemp: String, currentTemp: String) {
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {

            // animations
            self.alpha = 0.0
            self.loadingLabel.alpha = 0.0
            
            }, completion: { finished in
                
                // after completion
                self.loadingLabel.removeFromSuperview()
                self.conditionLabel.text = condition
                self.maxTempLabel.text = maxTemp
                self.lowTempLabel.text = lowTemp
                self.currentTempLabel.text = currentTemp + "º"
                
                UIView.animateWithDuration(1.5, delay: 0.0, options: .CurveEaseOut, animations: {
                    
                    // animations
                    self.alpha = 1.0
                    self.conditionImageView.alpha = 1.0
                    self.conditionLabel.alpha = 1.0
                    self.maxTempImageView.alpha = 1.0
                    self.maxTempLabel.alpha = 1.0
                    self.lowTempImageView.alpha = 1.0
                    self.lowTempLabel.alpha = 1.0
                    self.currentTempLabel.alpha = 1.0
                    self.celciusButton.alpha = 1.0
                    self.dividerLine.alpha = 1.0
                    self.fahranheitButton.alpha = 1.0
                    
                    }, completion: { finished in
                        // after completion
                })
        })
    }
    
    func updateWeatherTemperatureLabelsAnimated(maxTemp: String, lowTemp: String, currentTemp: String) {
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {
            
            // animations
            self.maxTempLabel.alpha = 0.0
            self.lowTempLabel.alpha = 0.0
            self.currentTempLabel.alpha = 0.0
            
            }, completion: { finished in
                
                // after completion
                self.maxTempLabel.text = maxTemp
                self.lowTempLabel.text = lowTemp
                self.currentTempLabel.text = currentTemp + "º"
                
                UIView.animateWithDuration(1.5, delay: 0.0, options: .CurveEaseOut, animations: {
                    
                    // animations
                    self.maxTempLabel.alpha = 1.0
                    self.lowTempLabel.alpha = 1.0
                    self.currentTempLabel.alpha = 1.0
                    
                    }, completion: { finished in
                        // after completion
                })
        })
    }
    
    
    //MARK:
    //MARK: Temperature Celcius/Fahranheit helper buttons
    
    func changeTemperatureToCelcius(button: UIButton) {
        // re-setting buttons state
        self.celciusButton.selected = true
        self.fahranheitButton.selected = false

        let weatherManager = WeatherManager()
        
        // updating labels animated
        self.updateWeatherTemperatureLabelsAnimated(weatherManager.tempToCelcius(weatherManager.getSavedKelvinMaxTemperature()),
                                                    lowTemp: weatherManager.tempToCelcius(weatherManager.getSavedKelvinLowTemperature()),
                                                    currentTemp: weatherManager.tempToCelcius(weatherManager.getSavedKelvinCurrentTemperature()))
    }

    func changeTemperatureToFahranheit(button: UIButton) {
        // re-setting buttons state
        self.celciusButton.selected = false
        self.fahranheitButton.selected = true
    
        let weatherManager = WeatherManager()
        
        // updating labels animated
        self.updateWeatherTemperatureLabelsAnimated(weatherManager.tempToFahrenheit(weatherManager.getSavedKelvinMaxTemperature()),
                                                    lowTemp: weatherManager.tempToFahrenheit(weatherManager.getSavedKelvinLowTemperature()),
                                                    currentTemp: weatherManager.tempToFahrenheit(weatherManager.getSavedKelvinCurrentTemperature()))
    }
    
}