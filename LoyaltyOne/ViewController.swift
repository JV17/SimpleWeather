//
//  ViewController.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-01.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK:
    //MARK: Properties

    let appHelper = AppHelper()
    let screenSize = UIScreen.mainScreen().bounds
    
    //MARK:
    //MARK: Lazy loading

    lazy var blurredView: UIView = {
        var tmpView: UIView = UIView(frame: UIScreen.mainScreen().bounds)
        return tmpView
    }()
    
    lazy var timeLabel: UILabel = {
        var tmpLabel: UILabel = UILabel(frame: CGRectMake(0, 30, self.screenSize.width, 42))
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

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func commonInit() {
        
        // setting up the blurred background image
        self.setupBackgroundImage()
        
        appHelper.displayFontFamilies()
        
        timeLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 52)
        timeLabel.backgroundColor = UIColor.yellowColor()
        timeLabel.textColor = UIColor.blackColor()
        timeLabel.textAlignment = NSTextAlignment.Center
        timeLabel.text = self.getCurrentTime()
        
        self.view.addSubview(self.timeLabel)
    }
    
    
    
    //MARK:
    //MARK: Controller helper functions
    
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
    
}

