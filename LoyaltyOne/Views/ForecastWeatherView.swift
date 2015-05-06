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
    let appHelper = AppHelper()
    var daysLabels = Array<UILabel>()
    var iconsImageViews = Array<UIImageView>()
    var tempsLabels = Array<UILabel>()
    var dividersViews = Array<UIView>()
    var forecastViewIsAnimating = Bool()
    
    //MARK:
    //MARK: Lazy loading properties
    
    lazy var tableView: UITableView = {
        var tmpTableView: UITableView = UITableView(frame: CGRectMake(0, 0, self.frame.width, self.frame.height-1), style: UITableViewStyle.Plain)
        tmpTableView.backgroundColor = UIColor.clearColor()
        tmpTableView.separatorStyle = .None
        tmpTableView.bounces = true
        tmpTableView.scrollEnabled = true
        tmpTableView.delegate = self
        tmpTableView.dataSource = self
        tmpTableView.tableHeaderView = UIView(frame: CGRectZero)
        tmpTableView.tableFooterView = UIView(frame: CGRectZero)
        tmpTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "forecastTableViewCell")
        
        let k90DegreesAngle = (CGFloat(M_PI)/2)
        tmpTableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
        tmpTableView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height-1)
        
        return tmpTableView
    }()
    
    lazy var divider: UIView = {
        var view: UIView = UIView(frame: CGRectMake(35, CGRectGetMaxY(self.tableView.frame), self.frame.width-70, 0.5))
        
        return view
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

        let daysFrame = CGRectMake(0, 60, 58, 20)
        let iconsFrame = CGRectMake(14, 25, 30, 30)
        let tempsFrame = CGRectMake(0, 0, 58, 20)
        let dividersFrame = CGRectMake(0, 5, 0.7, 66)
        
        var x: Int = 0
        for(; x < Constants.ForecastView.numDays; x++) {
            // creating all labels and images
            self.daysLabels.append(self.createLabelsWithText("Mon", frame: daysFrame))
            self.iconsImageViews.append(self.createImageViewsWithImage(UIImage(named: "summer-50")!, frame: iconsFrame))
            self.tempsLabels.append(self.createLabelsWithText("18º", frame: tempsFrame))
            
            if(x == Constants.ForecastView.numDays-1) {
                break
            }
            
            self.dividersViews.append(self.createViews(dividersFrame))
        }
        
        self.addSubview(self.tableView)
        
//        self.divider.backgroundColor = self.appHelper.colorWithHexString(Constants.ForecastView.fontColor)
//        self.addSubview(self.divider)
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
        
        cell.contentView.addSubview(self.daysLabels[indexPath.row])
        cell.contentView.addSubview(self.iconsImageViews[indexPath.row])
        cell.contentView.addSubview(self.tempsLabels[indexPath.row])
        
        if(indexPath.row < Constants.ForecastView.numDays-1) {
            cell.contentView.addSubview(self.dividersViews[indexPath.row])
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
        view.backgroundColor = self.appHelper.colorWithHexString(Constants.ForecastView.dividerColor)
        view.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI))
        
        return view
    }
    
    
    //MARK:
    //MARK: Show and Hide animations
    
    func showForecastWeatherViewWithButton(button: UIButton) {
        
        if(self.forecastViewIsAnimating) {
            return
        }
        
        self.forecastViewIsAnimating = true
        
        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .CurveEaseIn, animations: {
            // forecast view show animations
            let oldFrame = self.frame
            self.frame = CGRectMake(oldFrame.origin.x, 0, oldFrame.size.width, oldFrame.size.height)
            self.alpha = 1.0
            
            if((button.window) != nil) {
                // forecast button animations
                button.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
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
        
        self.forecastViewIsAnimating = true
        
        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .CurveEaseIn, animations: {
            // forecast view hide animations
            let oldFrame = self.frame
            self.frame = CGRectMake(oldFrame.origin.x, Constants.ForecastView.viewHeight/2, oldFrame.size.width, oldFrame.size.height)
            self.alpha = 0.0
            
            if((button.window) != nil) {
                // forecast button animations
                button.transform = CGAffineTransformIdentity
            }
            
            }, completion: { finished in
                // completion handling
                self.forecastViewIsAnimating = false
        })
    }

}
