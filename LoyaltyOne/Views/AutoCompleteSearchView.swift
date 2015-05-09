//
//  AutoCompleteSearchView.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-02.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit

protocol AutoCompleteDelegate {
    
    // tells when the use has selected a new city from the autocomplete search view
    func autocompleteFinishedWithLocationId(autocompleteView: AutoCompleteSearchView, locationId: String)

}


class AutoCompleteSearchView: UIView, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, WeatherDataSource {

    //MARK:
    //MARK: Properties
 
    var delegate: AutoCompleteDelegate?
    var numRows: Int = 1
    let rowHeight: CGFloat = 50.0
    
    
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
    
    var cities: Array<String> = {
        var tmpArr: Array<String> = Array<String>()
        return tmpArr
    }()
    
    var countriesDic: Dictionary<String, String> = {
        var tmpDic: Dictionary<String, String> = Dictionary<String, String>()
        return tmpDic
    }()
    
    var autoCompleteCities: Array<Array<String>> = {
        var tmpArr: Array<Array<String>> = Array<Array<String>>()
        return tmpArr
    }()
    
    lazy var textField: UITextField = {
        var tmpTextField: UITextField = UITextField(frame: CGRectMake(0, 0, self.frame.width, 52))
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        leftPaddingView.backgroundColor = UIColor.clearColor()
        
        tmpTextField.leftView = leftPaddingView
        tmpTextField.delegate = self
        tmpTextField.font = UIFont(name: "Lato-Light", size: 22)
        tmpTextField.leftViewMode = .Always
        tmpTextField.textColor = UIColor.whiteColor()
        tmpTextField.attributedPlaceholder = NSAttributedString(string:"Enter city",
                                                                attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor().colorWithAlphaComponent(0.6)])
        tmpTextField.returnKeyType = .Done
        tmpTextField.clearButtonMode = .Never
        tmpTextField.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        
        return tmpTextField
    }()
    
    lazy var tableView: UITableView = {
        var tmpTableView: UITableView = UITableView(frame: CGRectMake(0, CGRectGetMaxY(self.textField.frame), self.frame.width, 250), style: UITableViewStyle.Plain)
        tmpTableView.backgroundColor = UIColor.clearColor()
        tmpTableView.separatorStyle = .SingleLine
        tmpTableView.bounces = true
        tmpTableView.scrollEnabled = true
        tmpTableView.delegate = self
        tmpTableView.dataSource = self
        tmpTableView.alpha = 0.0 // this is for animations purposes
        tmpTableView.tableHeaderView = UIView(frame: CGRectZero)
        tmpTableView.tableFooterView = UIView(frame: CGRectZero)
        tmpTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "autoCompleteTableViewCell")
        
        return tmpTableView
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
        
        self.textField.backgroundColor = appHelper.colorWithHexString("1F1F21").colorWithAlphaComponent(0.7)
        self.addSubview(self.textField)
        
        // post notifications
        self.postNotifications()
        
        self.weatherManager.delegate = self
    }
    
    
    //MARK:
    //MARK: TableView delegate and datasource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // table view cell setup
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("autoCompleteTableViewCell") as! UITableViewCell
        
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.textLabel?.font = UIFont(name: "Lato-Light", size: 20)
        cell.textLabel?.textColor = appHelper.colorWithHexString("F7F7F7")
        
        if(self.autoCompleteCities.count > 0) {
            cell.textLabel?.text = self.autoCompleteCities[indexPath.row][0]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // selected row code
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.textField.text = self.autoCompleteCities[indexPath.row][0]
        self.delegate?.autocompleteFinishedWithLocationId(self, locationId: self.autoCompleteCities[indexPath.row][1])
        
        // dismiss keyboard and table view
        self.textField.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows
        if(self.autoCompleteCities.count > 50) {
            return 50
        }
        
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
        if((textField.text as NSString).length > 1) {
            let subString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            self.searchAutocompleteEntriesWithSubstring(subString)
        }
        return true
    }
    
    func searchAutocompleteEntriesWithSubstring(subString: String) {
        // making api calls for cities
        dispatch_async(Constants.MultiThreading.backgroundQueue, {
            self.weatherManager.requestCitiesFromString(subString)
        })
    }
    
    func containsKeyword(text: NSString, keyword: String) -> Bool
    {
        return text.rangeOfString(keyword, options:NSStringCompareOptions.CaseInsensitiveSearch).location != NSNotFound
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // dismissing keyboard
        textField.resignFirstResponder()
        
        // if there is only 1 city left in our auto complete array then auto selected
        if(self.autoCompleteCities.count > 0) {
            textField.text = self.autoCompleteCities[0][0]
            self.delegate?.autocompleteFinishedWithLocationId(self, locationId: self.autoCompleteCities[0][1])
        }
        else if(!textField.text.isEmpty) {
            self.delegate?.autocompleteFinishedWithLocationId(self, locationId: textField.text)
        }
        
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
    //MARK: Table view animations
    
    func dismissTableViewAnimated() {
        
        UIView.animateWithDuration(0.4, delay: 0.2, options: .CurveEaseOut, animations: {
            
            // animations
            self.tableView.alpha = 0.0
            
            }, completion: { finished in
                
                // after completion
                self.tableView.removeFromSuperview()
        })
    }
    
    func showTableViewAnimated() {
        
        if((self.tableView.window) == nil) {
            self.addSubview(self.tableView)
        }
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {
            
            // animations
            self.tableView.alpha = 1.0
            
            }, completion: { finished in
                // after completion
        })
    }
    
    
    //MARK:
    //MARK: Keyboard notifications
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            
            // calculating new frame for table view
            let oldCGPoint = self.tableView.frame.origin
            let oldCGSize = self.tableView.frame.size
            let newHeight: CGFloat = self.appHelper.screenSize.height-Constants.AutocompleteView.viewYoffSet-self.textField.frame.height-keyboardSize.height-41.0
 
            // setting the new height for table view
            self.tableView.frame = CGRectMake(oldCGPoint.x, oldCGPoint.y, oldCGSize.width, newHeight)
            
            // calculating new frame for view
            let newViewHeight = self.textField.frame.size.height+self.tableView.frame.size.height
            
            // setting the new frame for view
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.width, newViewHeight)
            
            // removing notification since we won't need to update the table view anymore
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        }
    }
    
    
    //MARK:
    //MARK: View helper functions
    
    func getCountriesWithCountryCodes() {
        // getting the files from our main bundle
        let countryCodesFilePath = NSBundle.mainBundle().pathForResource("country-codes", ofType: "txt")
        let countriesFilePath = NSBundle.mainBundle().pathForResource("countries", ofType: "txt")
        
        // getting the content from the files
        if let countryCodesString = String(contentsOfFile: countryCodesFilePath!, encoding: NSUTF8StringEncoding, error: nil) {
            if let countriesString = String(contentsOfFile: countriesFilePath!, encoding: NSUTF8StringEncoding, error: nil) {

                dispatch_async(dispatch_get_main_queue()) {
                    // getting the country codes and contries content
                    let indexes = countryCodesString.componentsSeparatedByString("\n")
                    let values = countriesString.componentsSeparatedByString("\n")
                    
                    // creating a dictionary with all the country codes and countries
                    for(var x: Int = 0; x < indexes.count; x++) {
                        self.countriesDic[indexes[x]] = (values[x].lowercaseString)
                    }
                }
            }
        }
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
    
    func postNotifications() {
        // keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func clearAutocompleteTextField() {
        // clear all content of our custom search bar
        self.textField.text = ""
        self.autoCompleteCities.removeAll(keepCapacity: false)
        self.tableView.reloadData()
    }
    
    
    //MARK:
    //MARK: Weather Manager delegate
    
    func citiesRequestFinishedWithJSON(weatherManager: WeatherManager, citiesJSON: JSON) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.autoCompleteCities.removeAll(keepCapacity: false)
            
            var x: Int = 0
            // loops over all the cities in JSON
            for (; x < citiesJSON["RESULTS"].count; x++) {
                let city: String = citiesJSON["RESULTS"][x]["name"].stringValue
                let locationId: String = citiesJSON["RESULTS"][x]["l"].stringValue
                var values: Array<String> = Array<String>()
                values.append(city)
                values.append(locationId)
                self.autoCompleteCities.insert(values, atIndex: x)
            }
            
            self.tableView.reloadData()
        }

    }

    func citiesRequestFinishedWithError(weatherManage: WeatherManager, error: NSError) {
        // error handling
        println("Cities request ERROR: \(error)")
    }
    
    func weatherRequestFinishedWithJSON(weatherManager: WeatherManager, weatherJSON: JSON) {
        // empty delegate
    }
    
    func weatherRequestFinishedWithError(weatherManager: WeatherManager, error: NSError, serverError: Bool, city: String, state: String, locationId: String) {
        // empty delegate
    }
    
    func forecastWeatherRequestFinishedWithJSON(weatherManager: WeatherManager, forecastJSON: JSON) {
        // empty delegate
    }
    
    func forecastWeatherRequestFinishedWithError(weatherManager: WeatherManager, error: NSError, city: String, state: String, locationId: String) {
        // empty delegate
    }
}
