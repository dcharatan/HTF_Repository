//
//  DataColorLabel.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 8/4/15.
//
//

import UIKit

@IBDesignable class DataColorLabel: UIView {
    @IBInspectable var color: UIColor = UIColor.redColor()
    @IBInspectable var text: String = "Data Type"
    
    override func drawRect(rect: CGRect) {
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        let circleDiameter: CGFloat = self.bounds.height
        
        // This gets the color's components.
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // This draws the background.
        let backgroundRect: UIBezierPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: circleDiameter * 0.5)
        UIColor(red: r + (1 - r) * 0.75, green: g + (1 - g) * 0.75, blue: b + (1 - b) * 0.75, alpha: 1).setFill()
        backgroundRect.fill()
        
        // This draws the circle to the left.
        let circleRect: CGRect = CGRect(
            x: 0,
            y: 0,
            width: circleDiameter,
            height: circleDiameter
        )
        CGContextAddEllipseInRect(context, circleRect)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillPath(context)
    }
}
