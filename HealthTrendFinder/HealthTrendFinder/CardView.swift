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
    
    let fullyRandomColors = false
    
    override func drawRect(rect: CGRect) {
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        let cornerRadius: CGFloat = 1 * UIScreen.mainScreen().scale
        let shadowLength: CGFloat = 0.5 * UIScreen.mainScreen().scale
        let shadowColor: UIColor = UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1)
        let baseColor: UIColor = UIColor.whiteColor()
        
        let shadowPath: CGPathRef = CGPathCreateWithRoundedRect(self.bounds, cornerRadius, cornerRadius, nil)
        CGContextSetFillColorWithColor(context, shadowColor.CGColor)
        CGContextAddPath(context, shadowPath)
        CGContextFillPath(context)
        
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
        
        // This sets the original location, which is needed for the swipe deletion.
        originalLocation = self.center
    }
    
    override init(frame: CGRect) {
        // This stuff is executed when the CardView is created from code.
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        // This stuff is executed when the CardView is created form the storyboard.
        super.init(coder: aDecoder)
    }
    
}

