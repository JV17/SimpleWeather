//
//  ForecastWeatherView.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-05.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit
import Darwin

class ForecastWeatherView: UIView, UITableViewDelegate, UITableViewDataSource {

    //MARK:
    //MARK: Properties
    
    var forecastViewIsAnimating = Bool()
    var city: String?
    var referenceToForecastBtn: UIButton?
    
    //MARK:
    //MARK: Lazy loading properties
    
    var appHelper: AppHelper = {
        var tmpAppHelper: AppHelper = AppHelper()
        return tmpAppHelper
    }()
    
    var weatherManager: WeatherManager = {
        var tmpWeatherManager: WeatherManager = WeatherManager()
        return tmpWeatherManager
    }()
    
    var daysLabels: Array<UILabel> = {
        var tmpArr: Array<UILabel> = Array<UILabel>()
        return tmpArr
    }()
    
    var iconsImageViews: Array<UIImageView> = {
        var tmpArr: Array<UIImageView> = Array<UIImageView>()
        return tmpArr
    }()
    
    var tempsLabels: Array<UILabel> = {
        var tmpArr: Array<UILabel> = Array<UILabel>()
        return tmpArr
    }()
    
    var dividersViews: Array<UIView> = {
        var tmpArr: Array<UIView> = Array<UIView>()
        return tmpArr
    }()
    
    lazy var tableView: UITableView = {
        var tmpTableView: UITableView = UITableView(frame: CGRectMake(0, 0, self.frame.width, self.frame.height-1), style: UITableViewStyle.Plain)
        tmpTableView.backgroundColor = UIColor.clearColor()
        tmpTableView.separatorStyle = .None
        tmpTableView.bounces = true
        tmpTableView.scrollEnabled = true
        tmpTableView.tableHeaderView = UIView(frame: CGRectZero)
        tmpTableView.tableFooterView = UIView(frame: CGRectZero)
        tmpTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "forecastTableViewCell")
        
        let k90DegreesAngle = (CGFloat(M_PI)/2)
        tmpTableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
        tmpTableView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height-1)
        
        return tmpTableView
    }()
    
    lazy var divider: UIView = {
        var view: UIView = UIView(frame: CGRectMake(0, CGRectGetMaxY(self.tableView.frame)+2, self.frame.width, 0.7))
        
        return view
    }()
    
    
    //MARK:
    //MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInitWithJSON(forecastJSON: JSON) {
        
        self.divider.backgroundColor = self.appHelper.colorWithHexString(Constants.ForecastView.fontColor).colorWithAlphaComponent(0.6)
        self.addSubview(self.divider)
        
        // check if we have any valid data
        if (!forecastJSON.isEmpty) {
            
            // check if we have enough data for the 7 days forecast
            if(forecastJSON["forecast"]["simpleforecast"]["forecastday"].count > 0) {
                            
                if(daysLabels.count > 0) {
                        self.removeAllSubViewsFromForecastView()
                        self.daysLabels.removeAll()
                        self.iconsImageViews.removeAll()
                        self.tempsLabels.removeAll()
                        self.dividersViews.removeAll()
                }
                
                var tempsArray = Array<NSNumber>()
                
                var x: Int = 0
                for(; x < Constants.ForecastView.numDays; x++) {
                    
                    // extracting data from json
                    let day = forecastJSON["forecast"]["simpleforecast"]["forecastday"][x]["date"]["weekday_short"].stringValue
                    let temp = forecastJSON["forecast"]["simpleforecast"]["forecastday"][x]["high"]["celsius"].numberValue
                    let condition = forecastJSON["forecast"]["simpleforecast"]["forecastday"][x]["conditions"].stringValue

//                    println()
//                    println("*********************")
//                    println(day)
//                    println(temp)
//                    println(condition)
                    
                    // creating all labels and images
                    tempsArray.append(temp)
                    self.daysLabels.append(self.createLabelsWithText(day, frame: Constants.ForecastView.daysFrame))
                    self.iconsImageViews.append(self.createImageViewsWithImage(self.weatherManager.getWeatherImageForCondition(condition), frame: Constants.ForecastView.iconsFrame))
                    self.tempsLabels.append(self.createLabelsWithText(self.weatherManager.tempToCelcius(temp) + "º", frame: Constants.ForecastView.tempsFrame))
                    
                    if(x == Constants.ForecastView.numDays-1) {
                        break
                    }
                    
                    self.dividersViews.append(self.createViews(Constants.ForecastView.dividersFrame))
                }
                
                NSUserDefaults.standardUserDefaults().setObject(tempsArray, forKey: Constants.UserDefaults.forecastViewTemps)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                // adding table view
                if((self.tableView.window) == nil) {
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.addSubview(self.tableView)
                }
                else {
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    
    //MARK:
    //MARK: TableView delegate and datasource
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        // setting up table view cell
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("forecastTableViewCell") as! UITableViewCell
        
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.userInteractionEnabled = false
        
        if(self.daysLabels.count > 0) {
            cell.addSubview(self.daysLabels[indexPath.row])
            cell.addSubview(self.iconsImageViews[indexPath.row])
            cell.addSubview(self.tempsLabels[indexPath.row])
            
            if(indexPath.row < Constants.ForecastView.numDays-1) {
                cell.addSubview(self.dividersViews[indexPath.row])
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // selected row code
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows
        return Constants.ForecastView.numDays
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // row height
        return Constants.ForecastView.rowHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // header for tableview
        return UIView.new()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // height for header
        return 0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // footer for tableview
        return UIView.new()
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // height for footer
        return 0
    }
    
    //MARK:
    //MARK: Forecast view helper functions
    
    func createLabelsWithText(text: String, frame: CGRect) -> UILabel {
        // creating days labels
        let label: UILabel = UILabel(frame: frame)
        label.font = UIFont(name: Constants.ForecastView.fontFamily, size: Constants.ForecastView.fontSize)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = self.appHelper.colorWithHexString(Constants.ForecastView.fontColor)
        label.textAlignment = NSTextAlignment.Center
        label.text = text
        label.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI))

        return label
    }
    
    func createImageViewsWithImage(image: UIImage, frame: CGRect) -> UIImageView {
        // creating temps icons
        let imageView: UIImageView = UIImageView(frame: frame)
        imageView.image = image
        imageView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI))
        
        return imageView
    }
    
    func createViews(frame: CGRect) -> UIView {
        // creating dividers views
        let view: UIView = UIView(frame: frame)
        view.backgroundColor = self.appHelper.colorWithHexString(Constants.ForecastView.dividerColor).colorWithAlphaComponent(0.6)
        view.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI))
        
        return view
    }
    
    func getDayFromUnixTimestamp(unixTimestamp: String) -> String {
        
        let timestampVal = ((unixTimestamp as NSString).doubleValue)
        let timestamp = timestampVal as NSTimeInterval
        let date = NSDate(timeIntervalSince1970: timestamp)
        let calendar = NSCalendar.currentCalendar()
        let components: NSDateComponents = calendar.components(NSCalendarUnit.CalendarUnitWeekday | NSCalendarUnit.CalendarUnitDay, fromDate: date)
        let day = components.weekday
        
        // getting the date of the week
        switch day {
        case 1:
            return "Sun"
        case 2:
            return "Mon"
        case 3:
            return "Tues"
        case 4:
            return "Wed"
        case 5:
            return "Thur"
        case 6:
            return "Fri"
        case 7:
            return "Sat"
        default:
            return ""
        }
    }
    
    func changeTemperatureToCelcius() {
        
        // removing current temps from view
        for tempLabel in self.tempsLabels {
            tempLabel.removeFromSuperview()
        }
        
        self.tempsLabels.removeAll(keepCapacity: false)
        
        let tempsArray: Array<NSNumber> = NSUserDefaults.standardUserDefaults().objectForKey(Constants.UserDefaults.forecastViewTemps) as! Array<NSNumber>
        
        for temp in tempsArray {
            self.tempsLabels.append(self.createLabelsWithText(self.weatherManager.tempToCelcius(temp) + "º", frame: Constants.ForecastView.tempsFrame))
        }
        
        self.tableView.reloadData()
    }
    
    func changeTemperatureToFahranheit() {

        // removing current temps from view
        for tempLabel in self.tempsLabels {
            tempLabel.removeFromSuperview()
        }

        self.tempsLabels.removeAll(keepCapacity: false)
        
        let tempsArray: Array<NSNumber> = NSUserDefaults.standardUserDefaults().objectForKey(Constants.UserDefaults.forecastViewTemps) as! Array<NSNumber>
        
        for temp in tempsArray {
            self.tempsLabels.append(self.createLabelsWithText(self.weatherManager.tempToFahrenheit(temp) + "º", frame: Constants.ForecastView.tempsFrame))
        }
        
        self.tableView.reloadData()
    }
    
    func reloadTableViewAnimated() {

        if(self.forecastViewIsAnimating) {
            return
        }
        
        self.forecastViewIsAnimating = true
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .CurveEaseIn, animations: {
            // animations
            self.alpha = 0.0
            
            }, completion: { finished in
                // completion handling
                self.tableView.reloadData()
                
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .CurveEaseIn, animations: {
                    // animations
                    self.alpha = 1.0
                    
                    }, completion: { finished in
                        // completion handling
                        self.forecastViewIsAnimating = false
                })
        })
    }
    
    func removeAllSubViewsFromForecastView() {
        
        if(self.daysLabels.count == 0 || self.iconsImageViews.count == 0 || self.tempsLabels.count == 0 || self.dividersViews.count == 0) {
            return
        }
        
        for label in self.daysLabels {
            label.removeFromSuperview()
        }
        
        for imageView in self.iconsImageViews {
            imageView.removeFromSuperview()
        }
        
        for tempLabel in self.tempsLabels {
            tempLabel.removeFromSuperview()
        }
        
        for view in self.dividersViews {
            view.removeFromSuperview()
        }
    }
    
    //MARK:
    //MARK: Show and Hide animations
    
    func showForecastWeatherViewWithButton(button: UIButton) {
        
        if(self.forecastViewIsAnimating) {
            return
        }
        
        if(self.referenceToForecastBtn == nil) {
            self.referenceToForecastBtn = button
        }

        self.forecastViewIsAnimating = true
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .CurveEaseIn, animations: {
            // forecast view show animations
            self.alpha = 1.0
            
            let oldFrame = self.frame
            self.frame = CGRectMake(oldFrame.origin.x, 0, oldFrame.size.width, oldFrame.size.height)
            
            if((self.referenceToForecastBtn!.window) != nil) {
                // forecast button animations
                self.referenceToForecastBtn!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            }
            
            }, completion: { finished in
                // completion handling
                self.forecastViewIsAnimating = false
        })
    }
    
    func hideForecastWeatherViewWithButton(button: UIButton) {
        
        if(self.forecastViewIsAnimating) {
            return
        }
        
        if(self.referenceToForecastBtn == nil) {
            self.referenceToForecastBtn = button
        }
        
        self.forecastViewIsAnimating = true
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .CurveEaseIn, animations: {
            // forecast view hide animations
            self.alpha = 0.0

            let oldFrame = self.frame
            self.frame = CGRectMake(oldFrame.origin.x, Constants.ForecastView.viewHeight/2, oldFrame.size.width, oldFrame.size.height)
            
            if((self.referenceToForecastBtn!.window) != nil) {
                // forecast button animations
                self.referenceToForecastBtn!.transform = CGAffineTransformIdentity
            }
            
            }, completion: { finished in
                // completion handling
                self.forecastViewIsAnimating = false
        })
    }
    
}
