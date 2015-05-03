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
    
    lazy var conditionLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(Constants.WeatherView.labelsX,
                                                          0,
                                                          self.appHelper.screenSize.width,
                                                          Constants.WeatherView.conditionHeight))
        
        tmpLabel.font = UIFont(name: Constants.WeatherView.fontFamily, size: Constants.WeatherView.conditionFontSize)
        tmpLabel.backgroundColor = UIColor.clearColor()
        tmpLabel.textColor = self.appHelper.colorWithHexString(Constants.WeatherView.fontColor)
        tmpLabel.textAlignment = NSTextAlignment.Left
        tmpLabel.text = "Loading..."

        return tmpLabel
    }()
    
    lazy var maxTempLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(Constants.WeatherView.labelsX,
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
    
    lazy var lowTempLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(CGRectGetMaxX(self.maxTempLabel.frame),
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
                                                          self.appHelper.screenSize.width,
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
        self.addSubview(self.conditionLabel)
        self.addSubview(self.maxTempLabel)
        self.addSubview(self.lowTempLabel)
        self.addSubview(self.currentTempLabel)
    }
    
    func updateConditionLabel(string: String) {
    }

}