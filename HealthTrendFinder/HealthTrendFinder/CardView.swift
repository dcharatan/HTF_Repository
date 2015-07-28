//
//  CardView.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 6/29/15.
//
//

import UIKit

class CardView: UIView {
    
    // Variables used to aid in dragging CardView
    internal var lastLocation: CGPoint = CGPointMake(0.0, 0.0)
    internal var originalLocation: CGPoint = CGPointMake(0.0, 0.0)
    internal var panGestureRecognizerReference: UIPanGestureRecognizer? = nil
    
    // Variables used to reference other things
    internal var headerText: String = ""
    internal let headerBarSize: CGFloat = 44
    
    override func drawRect(rect: CGRect) {
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        let cornerRadius: CGFloat = 2
        let shadowLength: CGFloat = 1
        let shadowColor: UIColor = UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1)
        let headerColor: UIColor = UIColor.darkGrayColor()
        let headerFontSize: CGFloat = 14
        let baseColor: UIColor = UIColor.whiteColor()
        let margin: CGFloat = 8
        
        // This draws the shadow.
        let shadowPath: CGPathRef = CGPathCreateWithRoundedRect(self.bounds, cornerRadius, cornerRadius, nil)
        CGContextSetFillColorWithColor(context, shadowColor.CGColor)
        CGContextAddPath(context, shadowPath)
        CGContextFillPath(context)
        
        // This draws the white base.
        let basePathRect: CGRect = CGRect(
            x: self.bounds.minX,
            y: self.bounds.minY,
            width: self.bounds.width,
            height: self.bounds.height - shadowLength
        )
        let basePath: CGPathRef = CGPathCreateWithRoundedRect(basePathRect, cornerRadius, cornerRadius, nil)
        CGContextSetFillColorWithColor(context, baseColor.CGColor)
        CGContextAddPath(context, basePath)
        CGContextFillPath(context)
        
        // This draws the header.
        let headerPath: UIBezierPath = UIBezierPath(roundedRect: CGRect(
            x: self.bounds.minX,
            y: self.bounds.minY,
            width: self.bounds.width,
            height: headerBarSize
            ), byRoundingCorners: UIRectCorner.TopLeft | UIRectCorner.TopRight, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        headerColor.setFill()
        headerPath.fill()
        
        // This draws the header text.
        let headerLabelMargin: CGFloat = (headerBarSize - headerFontSize) * 0.5
        let headerLabel: UILabel = UILabel(frame: CGRect(
            x: headerLabelMargin,
            y: 0,
            width: self.bounds.width - 2 * headerLabelMargin,
            height: headerBarSize
            ))
        headerLabel.text = headerText
        headerLabel.font = UIFont(name: "Helvetica Neue", size: headerFontSize)
        headerLabel.textColor = UIColor.whiteColor()
        self.addSubview(headerLabel)
        
        // This sets the original location, which is needed for the swipe deletion.
        originalLocation = self.center
    }
    
    init(frame: CGRect, headerText: String) {
        super.init(frame: frame)
        self.headerText = headerText
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        // This stuff is executed when the CardView is created form the storyboard.
        super.init(coder: aDecoder)
    }
    
}

