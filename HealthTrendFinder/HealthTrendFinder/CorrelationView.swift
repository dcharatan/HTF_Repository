//
//  CorrelationView.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 8/5/15.
//
//

import UIKit

@IBDesignable class CorrelationView: UIView {
    @IBInspectable var r: CGFloat = 0.8
    @IBInspectable var cornerRadius: CGFloat = 8
    @IBInspectable var numberBackgroundColor: UIColor = ColorManager.colorForRGB(red: 0xEE, green: 0xEE, blue: 0xEE)
    @IBInspectable var numberSize: CGFloat = 20
    @IBInspectable var numberSpacing: CGFloat = 8
    @IBInspectable var descriptionColor: UIColor = UIColor.whiteColor()
    @IBInspectable var descriptionSize: CGFloat = 14
    @IBInspectable var descriptionSpacing: CGFloat = 8
    @IBInspectable var shadowColor: UIColor = UIColor(white: 0, alpha: 0.1)
    @IBInspectable var shadowSize: CGFloat = 1
    
    let correlationGroups: [(rUpperBound: CGFloat, color: UIColor, description: String)] = [
        (0.125, ColorManager.colorForRGB(red: 0xFF, green: 0x3B, blue: 0x30), "Very Weak"),
        (0.375, ColorManager.colorForRGB(red: 0xFF, green: 0x95, blue: 0x00), "Weak"),
        (0.625, ColorManager.colorForRGB(red: 0xFF, green: 0xCC, blue: 0x00), "Moderate"),
        (0.875, ColorManager.colorForRGB(red: 0x4C, green: 0xD9, blue: 0x64), "Strong"),
        (1.000, ColorManager.colorForRGB(red: 0x34, green: 0xAA, blue: 0xDC), "Very Strong")
    ]
    
    override func drawRect(rect: CGRect) {
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        
        // This sets up the clipping path.
        let clippingPath: UIBezierPath = UIBezierPath(roundedRect: CGRect(
            x: 0,
            y: 0,
            width: self.bounds.width,
            height: self.bounds.height
            ), cornerRadius: cornerRadius)
        clippingPath.addClip()
        
        // This sets up the number.
        var numberLabel: UILabel = UILabel(frame: CGRectIntegral(CGRect(
            x: numberSpacing,
            y: (self.bounds.height - numberSize * 1.125) * 0.5,
            width: self.bounds.width,
            height: numberSize * 1.25)))
        numberLabel.font = UIFont(name: "Helvetica Neue", size: numberSize)
        numberLabel.text = "\(r)"
        numberLabel.sizeToFit()
        numberLabel.textColor = colorForR(r)
        
        // This sets up the background shadow rects.
        let numberBackgroundWidth: CGFloat = numberLabel.frame.width + 2 * numberSpacing
        let numberBackgroundWithShadowRect: CGRect = CGRect(x: 0, y: 0, width: numberBackgroundWidth, height: self.bounds.height)
        let descriptionBackgroundWithShadowRect: CGRect = CGRect(x: numberBackgroundWidth, y: 0, width: self.bounds.width - numberBackgroundWidth, height: self.bounds.height)
        let shadowRect: CGRect = CGRect(x: 0, y: cornerRadius, width: self.bounds.width, height: self.bounds.height - cornerRadius)
        
        // This draws the background rects and covers them in shadow.
        CGContextSetFillColorWithColor(context, numberBackgroundColor.CGColor)
        CGContextAddRect(context, numberBackgroundWithShadowRect)
        CGContextFillRect(context, numberBackgroundWithShadowRect)
        
        CGContextSetFillColorWithColor(context, colorForR(r).CGColor)
        CGContextAddRect(context, descriptionBackgroundWithShadowRect)
        CGContextFillRect(context, descriptionBackgroundWithShadowRect)
        
        CGContextSetFillColorWithColor(context, shadowColor.CGColor)
        CGContextAddRect(context, shadowRect)
        CGContextFillRect(context, shadowRect)
        
        // This draws the background.
        let numberBackgroundRect: CGRect = CGRect(x: 0, y: cornerRadius, width: numberBackgroundWidth, height: self.bounds.height - shadowSize - cornerRadius)
        let descriptionBackgroundRect: CGRect = CGRect(x: numberBackgroundWidth, y: cornerRadius, width: self.bounds.width - numberBackgroundWidth, height: self.bounds.height - shadowSize - cornerRadius)
        
        let numberBackgroundPath: UIBezierPath = UIBezierPath(roundedRect: numberBackgroundRect, byRoundingCorners: UIRectCorner.BottomLeft, cornerRadii: CGSizeMake(cornerRadius, cornerRadius))
        let descriptionBackgroundPath: UIBezierPath = UIBezierPath(roundedRect: descriptionBackgroundRect, byRoundingCorners: UIRectCorner.BottomRight, cornerRadii: CGSizeMake(cornerRadius, cornerRadius))
        
        numberBackgroundColor.setFill()
        numberBackgroundPath.fill()
        
        colorForR(r).setFill()
        descriptionBackgroundPath.fill()
        
        // This actually adds the number.
        addSubview(numberLabel)
        
        // This draws the description.
        var descriptionLabel: UILabel = UILabel(frame: CGRectIntegral(CGRect(
            x: numberSpacing * 2 + descriptionSpacing + numberLabel.frame.width,
            y: (self.bounds.height - descriptionSize * 1.25) * 0.5,
            width: self.bounds.width,
            height: descriptionSize * 1.25)))
        descriptionLabel.font = UIFont(name: "Helvetica Neue", size: descriptionSize)
        descriptionLabel.text = descriptionForR(r)
        descriptionLabel.textColor = descriptionColor
        addSubview(descriptionLabel)
    }
    
    // This function is needed to prevent black backgrounds from appearing when drawRect is overridden.
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.clearColor()
    }
    
    private func colorForR(r: CGFloat) -> UIColor {
        var returnValue: UIColor = UIColor()
        
        for i: Int in 0..<correlationGroups.count {
            if abs(r) <= correlationGroups[i].rUpperBound {
                returnValue = correlationGroups[i].color
                break
            }
        }
        
        return returnValue
    }
    
    private func descriptionForR(r: CGFloat) -> String {
        var returnValue: String = ""
        
        for i: Int in 0..<correlationGroups.count {
            if abs(r) <= correlationGroups[i].rUpperBound {
                returnValue = correlationGroups[i].description
                break
            }
        }
        
        return returnValue
    }
}
