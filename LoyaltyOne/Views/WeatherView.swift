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
    //MARK: Lazy loading
    
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
        
        return tmpLabel
    }()
    
    lazy var currentTempLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(Constants.WeatherView.tempX,
                                                          CGRectGetMaxY(self.maxTempLabel.frame),
                                                          self.frame.width-Constants.WeatherView.labelsX,
                                                          Constants.WeatherView.tempHeight))
        
        tmpLabel.font = UIFont(name: Constants.WeatherView.fontFamily, size: Constants.WeatherView.tempFontSize)
        tmpLabel.backgroundColor = UIColor.clearColor()
        tmpLabel.textColor = self.appHelper.colorWithHexString(Constants.WeatherView.fontColor)
        tmpLabel.textAlignment = NSTextAlignment.Left
        tmpLabel.text = " ..."
        
        return tmpLabel
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
    
        // adding labels to view
        self.addSubview(self.conditionImageView)
        self.addSubview(self.conditionLabel)
        self.addSubview(self.maxTempImageView)
        self.addSubview(self.maxTempLabel)
        self.addSubview(self.lowTempImageView)
        self.addSubview(self.lowTempLabel)
        self.addSubview(self.currentTempLabel)
    }
    
    
    //MARK:
    //MARK: Weather View animations
    
    func updateWeatherLabelsAnimated(condition: String, maxTemp: String, lowTemp: String, currentTemp: String) {
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {

            // animations
            self.conditionImageView.alpha = 0.0
            self.conditionLabel.alpha = 0.0
            self.maxTempImageView.alpha = 0.0
            self.maxTempLabel.alpha = 0.0
            self.lowTempImageView.alpha = 0.0
            self.lowTempLabel.alpha = 0.0
            self.currentTempLabel.alpha = 0.0
            
            }, completion: { finished in
                
                // after completion
                self.conditionLabel.text = condition
                self.maxTempLabel.text = maxTemp
                self.lowTempLabel.text = lowTemp
                self.currentTempLabel.text = currentTemp + "º"
                
                UIView.animateWithDuration(3.0, delay: 0.0, options: .CurveEaseOut, animations: {
                    
                    // animations
                    self.conditionImageView.alpha = 1.0
                    self.conditionLabel.alpha = 1.0
                    self.maxTempImageView.alpha = 1.0
                    self.maxTempLabel.alpha = 1.0
                    self.lowTempImageView.alpha = 1.0
                    self.lowTempLabel.alpha = 1.0
                    self.currentTempLabel.alpha = 1.0
                    
                    }, completion: { finished in
                        // after completion
                })
        })
    }

}