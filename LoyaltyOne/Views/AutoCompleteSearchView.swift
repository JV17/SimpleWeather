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
    func autocompleteFinishedWithSelectedCity(autocompleteView: AutoCompleteSearchView, selectedCity: String)

}


class AutoCompleteSearchView: UIView, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    //MARK:
    //MARK: Properties
 
    let appHelper = AppHelper()
    var cities = Array<String>()
    var autoCompleteCities = Array<String>()
    var delegate: AutoCompleteDelegate?
    
    var numRows: Int = 1
    let rowHeight: CGFloat = 50.0
    
    
    //MARK:
    //MARK: Lazy loading
    
    lazy var textField: UITextField = {
        var tmpTextField: UITextField = UITextField(frame: CGRectMake(0, 0, self.frame.width, 52))
        
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
        tmpTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        
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
        
        // getting canadian cities/provinces
        self.getCanadianCities()
        
        self.textField.backgroundColor = appHelper.colorWithHexString("8E8E93").colorWithAlphaComponent(0.4)
        self.addSubview(self.textField)
        
        // post notifications
        self.postNotifications()
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
        self.delegate?.autocompleteFinishedWithSelectedCity(self, selectedCity: self.appHelper.removeProvinceFromCityName(self.autoCompleteCities[indexPath.row]))
        
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
            
            // if contains the the subString then add the city
            if(self.containsKeyword(city, keyword: subString)) {
                self.autoCompleteCities.append(city)
            }
        }
        
        self.tableView.reloadData()
    }
    
    func containsKeyword(text: NSString, keyword: String) -> Bool
    {
        return text.rangeOfString(keyword, options:NSStringCompareOptions.CaseInsensitiveSearch).location != NSNotFound
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // dismissing keyboard
        textField.resignFirstResponder()
        
        // if there is only 1 city left in our auto complete array then auto selected
        if(self.autoCompleteCities.count == 1) {
            textField.text = self.autoCompleteCities[0]
            self.delegate?.autocompleteFinishedWithSelectedCity(self, selectedCity: self.appHelper.removeProvinceFromCityName(self.autoCompleteCities[0]))
        }
        else if(!textField.text.isEmpty) {
            self.delegate?.autocompleteFinishedWithSelectedCity(self, selectedCity: textField.text)
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
            let newHeight: CGFloat = self.appHelper.screenSize.height-self.frame.origin.y-self.textField.frame.height-keyboardSize.height-4
 
            // setting the new height for table view
            self.tableView.frame = CGRectMake(oldCGPoint.x, oldCGPoint.y, oldCGSize.width, newHeight)
            
            // calculating new frame for view
            let newViewHeight = self.textField.frame.height+self.tableView.frame.height+5
            
            // setting the new frame for view
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.width, newViewHeight)
        
            // removing notification since we won't need to update the table view anymore
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "keyboardWillShow:", object: nil)
        }
    }
    
    
    //MARK:
    //MARK: View helper functions
    
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

}
