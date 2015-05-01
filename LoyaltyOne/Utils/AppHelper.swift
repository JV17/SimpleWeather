//
//  AppHelper.swift
//  LoyaltyOne
//
//  Created by Jorge Valbuena on 2015-05-01.
//  Copyright (c) 2015 Jorge Valbuena. All rights reserved.
//

import UIKit

class AppHelper: NSObject {
    
    
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
        let bitmapInfo = CGImageGetBitmapInfo(image)
        
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
        
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), image)
        
        let scaledImage = UIImage(CGImage: CGBitmapContextCreateImage(context))!
        
        return scaledImage
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
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (count(cString) != 6)
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
    
    func displayFontFamilies() {
        
        for family in UIFont.familyNames() {
            
            println("\(family)")
            
            for name in UIFont.fontNamesForFamilyName(family as! String) {
                println("\(name)")
            }
        }
    }

}