//
//  ViewController.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-01.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    //MARK:
    //MARK: Properties

    let appHelper = AppHelper()
    var cities = Array<String>()
    var autoCompleteCities = Array<String>()

    let screenSize = UIScreen.mainScreen().bounds
    var numRows: Int = 1
    let rowHeight: CGFloat = 50.0
    
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
    
    lazy var textField: UITextField = {
        var tmpTextField: UITextField = UITextField(frame: CGRectMake(15, CGRectGetMaxY(self.timeLabel.frame)+15, self.screenSize.width-30, 52))

        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        leftPaddingView.backgroundColor = UIColor.clearColor()
        
        tmpTextField.leftView = leftPaddingView
        tmpTextField.delegate = self
        tmpTextField.font = UIFont(name: "Lato-Light", size: 22)
        tmpTextField.leftViewMode = .Always
        tmpTextField.textColor = UIColor.whiteColor()
        tmpTextField.placeholder = NSLocalizedString("Enter your city", comment: "")
        tmpTextField.returnKeyType = .Done
        tmpTextField.clearButtonMode = .Never
        tmpTextField.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        
        return tmpTextField
    }()
    
    lazy var tableView: UITableView = {
        var tmpTableView: UITableView = UITableView(frame: CGRectMake(15, CGRectGetMaxY(self.textField.frame), self.screenSize.width-30, 150), style: UITableViewStyle.Plain)
        tmpTableView.backgroundColor = .clearColor()
        tmpTableView.separatorStyle = .SingleLine
        tmpTableView.bounces = true
        tmpTableView.scrollEnabled = true
        tmpTableView.delegate = self
        tmpTableView.dataSource = self
        tmpTableView.alpha = 0.0 // this is for animations purposes
        tmpTableView.tableHeaderView = UIView(frame: CGRectZero)
        tmpTableView.tableFooterView = UIView(frame: CGRectZero)
        tmpTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
    
        return tmpTableView
    }()

    
    //MARK:
    //MARK: Initializers

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // getting canadian cities/provinces
        self.getCanadianCities()
        
        // setup controller
        self.commonInit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func getCanadianCities() {
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
    
            let path = NSBundle.mainBundle().pathForResource("canadian_cities_ provinces", ofType: "txt")
            
            if let content = String(contentsOfFile:path!, encoding: NSUTF8StringEncoding, error: nil) {
    
                dispatch_async(dispatch_get_main_queue()) {
                    self.cities = content.componentsSeparatedByString("\n")
                }
                
            }
        }
    }
    
    func commonInit() {
        
        // setting up the blurred background image
        self.setupBackgroundImage()
        
        self.timeLabel.font = UIFont(name: "Lato-Light", size: 52)
        self.timeLabel.backgroundColor = UIColor.clearColor()
        self.timeLabel.textColor = appHelper.colorWithHexString("F7F7F7")
        self.timeLabel.textAlignment = NSTextAlignment.Center
        self.timeLabel.text = self.getCurrentTime()
        
        self.view.addSubview(self.timeLabel)
        
        self.textField.backgroundColor = appHelper.colorWithHexString("8E8E93").colorWithAlphaComponent(0.4)
        self.view.addSubview(self.textField)
    }
    
    
    //MARK:
    //MARK: TableView delegate and datasource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        // table view cell setup
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("tableViewCell") as! UITableViewCell
        
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.textLabel?.font = UIFont(name: "Lato-Light", size: 20)
        cell.textLabel?.textColor = appHelper.colorWithHexString("F7F7F7")
        
        if(self.autoCompleteCities.count > 0) {
            cell.textLabel?.text = self.autoCompleteCities[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // selected row code
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.textField.text = self.autoCompleteCities[indexPath.row]
        
        // dismiss keyboard and table view
        self.textField.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows
        return self.autoCompleteCities.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // row height
        return self.rowHeight
    }
    
    
    // MARK:
    // MARK: UITextFieldDelegate & search helper
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // auto complete logic
        let subString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        self.searchAutocompleteEntriesWithSubstring(subString)
        
        return true
    }
    
    func searchAutocompleteEntriesWithSubstring(subString: String) {
        // cleaning any previous cities
        self.autoCompleteCities.removeAll(keepCapacity: true)
        
        // loops over all the cities
        for city in self.cities {
            
            // create range to check
            let range: NSRange = (city as NSString).rangeOfString(subString)
            
            // if contains the the subString then add the city
            if(range.location == 0) {
                self.autoCompleteCities.append(city)
            }
        }
        
        self.tableView.reloadData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // dismissing keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // perform search & add table view
        self.showTableViewAnimated()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // dismiss table view
        if((self.tableView.window) != nil) {
            self.dismissTableViewAnimated()
        }
    }
    
    
    //MARK:
    //MARK: Controller helper functions
    
    func dismissTableViewAnimated() {
        
        UIView.animateWithDuration(0.4, delay: 0.2, options: .CurveEaseOut, animations: {
            self.tableView.alpha = 0.0
        }, completion: { finished in
            self.tableView.removeFromSuperview()
        })
    }
    
    func showTableViewAnimated() {
        
        if((self.tableView.window) == nil) {
            self.view.addSubview(self.tableView)
        }

        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {
            self.tableView.alpha = 1.0
            }, completion: { finished in
        })
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
    
}