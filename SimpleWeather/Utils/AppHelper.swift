//
//  AppHelper.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-01.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit

class AppHelper: NSObject {
    
    let screenSize = UIScreen.mainScreen().bounds
    
    func applyBlurToView(view: UIView, withBlurEffectStyle:UIBlurEffectStyle) {

        //only apply the blur if the user hasn't disabled transparency effects
        if(!UIAccessibilityIsReduceTransparencyEnabled()) {
            
            let blurEffect = UIBlurEffect(style: withBlurEffectStyle)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds;
            
            view.addSubview(blurEffectView)
            
        }
        else {
            
            view.backgroundColor = UIColor(patternImage: UIImage(named: "background1")!)

        }
    }
    
    
    func reSizeBackgroundImageIfNeeded(image: UIImage, newSize: CGSize) -> UIImage {
        
        if(image.size.height != newSize.height || image.size.width != newSize.width) {

            // resize the background image only if neeeded
            return self.reSizeImage(image, newSize: newSize)
        }

        // we don't need to resize the image so return it
        return image
    }
    
    
    func reSizeImage(image: UIImage, newSize: CGSize) -> UIImage {
        
        let image = image.CGImage
        
        let width = Int(newSize.width) //CGImageGetWidth(image) / 2
        let height = Int(newSize.height) //CGImageGetHeight(image) / 2
        let bitsPerComponent = CGImageGetBitsPerComponent(image)
        let bytesPerRow = CGImageGetBytesPerRow(image)
        let colorSpace = CGImageGetColorSpace(image)
        let bitmapInfo = CGImageGetBitmapInfo(image).rawValue
        
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
        
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.High)
        
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), image)
        
        let scaledImage = UIImage(CGImage: CGBitmapContextCreateImage(context)!)
        
        return scaledImage
    }
    
    func stringContainsKeyword(text: NSString, keyword: String) -> Bool
    {
        // string search
        return text.rangeOfString(keyword, options:NSStringCompareOptions.CaseInsensitiveSearch).location != NSNotFound
    }

    
    func applyGradientFromColors(colors: Array<AnyObject>, view: UIView) {
        let gradient : CAGradientLayer = CAGradientLayer()
        
        gradient.frame = view.bounds
        gradient.colors = colors
        
        view.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#"))
        {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if (cString.characters.count != 6)
        {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    func removeProvinceFromCityName(cityName: String) -> String {
        
        if(!cityName.isEmpty) {
            let cityArr = cityName.characters.split {$0 == ","}.map { String($0) }
            
            if(cityArr.count > 0) {
                return cityArr[0] as String
            }
        }
        
        return ""
    }
    
    func removeSpaceFromString(cityName: NSString) -> String {
        
        var city: String = ""
        
        if cityName.rangeOfString(" ").location != NSNotFound {
            city = cityName.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: NSMakeRange(0, cityName.length))
        }
        
        return city
    }
    
    func isCurrentTimeDayTime() -> Bool {
        // we get current timestamp
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: date)
        let hour = components.hour
        
        if(hour >= 19) {
            return false
        }
        
        return true
    }
    
    func displayFontFamilies() {
        
        for family in UIFont.familyNames() {
            // prints the family font
            print("Family :\(family)")
            for name in UIFont.fontNamesForFamilyName(family ) {
                // prints the family name
                print("\t\(name)")
            }
            print("")
        }
    }

}