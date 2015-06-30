//
//  CardView.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 6/29/15.
//
//

import UIKit

class CardView: UIView {
    
    let gradients: [(CGColor, CGColor)] = [(UIColor(red: 26 / 255, green: 214 / 255, blue: 253 / 255, alpha: 1.0).CGColor, UIColor(red: 29 / 255, green: 98 / 255, blue: 240 / 255, alpha: 1.0).CGColor),
    (UIColor(red: 255 / 255, green: 94 / 255, blue: 58 / 255, alpha: 1.0).CGColor, UIColor(red: 255 / 255, green: 42 / 255, blue: 104 / 255, alpha: 1.0).CGColor),
    (UIColor(red: 255 / 255, green: 149 / 255, blue: 0 / 255, alpha: 1.0).CGColor, UIColor(red: 255 / 255, green: 94 / 255, blue: 58 / 255, alpha: 1.0).CGColor),
    (UIColor(red: 74 / 255, green: 74 / 255, blue: 74 / 255, alpha: 1.0).CGColor, UIColor(red: 43 / 255, green: 43 / 255, blue: 43 / 255, alpha: 1.0).CGColor),
    (UIColor(red: 239 / 255, green: 77 / 255, blue: 182 / 255, alpha: 1.0).CGColor, UIColor(red: 198 / 255, green: 67 / 255, blue: 252 / 255, alpha: 1.0).CGColor),
    (UIColor(red: 255 / 255, green: 219 / 255, blue: 76 / 255, alpha: 1.0).CGColor, UIColor(red: 255 / 255, green: 205 / 255, blue: 2 / 255, alpha: 1.0).CGColor),
    (UIColor(red: 135 / 255, green: 252 / 255, blue: 112 / 255, alpha: 1.0).CGColor, UIColor(red: 11 / 255, green: 211 / 255, blue: 24 / 255, alpha: 1.0).CGColor)]
    
    // Variables used to aid in dragging CardView
    internal var lastLocation: CGPoint = CGPointMake(0.0, 0.0)
    internal var originalLocation: CGPoint = CGPointMake(0.0, 0.0)
    internal var panGestureRecognizerReference: UIPanGestureRecognizer? = nil
    
    let fullyRandomColors = false
    
    override func drawRect(rect: CGRect) {
        // This clips the (future) background gradient so that the view has rounded corners.
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: 8.0, height: 8.0))
        path.addClip()
        
        // This defines and creates the background gradient.
        let context = UIGraphicsGetCurrentContext()
        let colorChoice = Int(arc4random_uniform(UInt32(gradients.count)))
        var colors = [gradients[colorChoice].0, gradients[colorChoice].1]
        if(fullyRandomColors == true) {
            let color1 = UIColor(red: CGFloat(arc4random_uniform(256)) / 255, green: CGFloat(arc4random_uniform(256)) / 255, blue: CGFloat(arc4random_uniform(256)) / 255, alpha: 1.0).CGColor
            let color2 = UIColor(red: CGFloat(arc4random_uniform(256)) / 255, green: CGFloat(arc4random_uniform(256)) / 255, blue: CGFloat(arc4random_uniform(256)) / 255, alpha: 1.0).CGColor
            colors = [color1, color2]
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        let backgroundGradient = CGGradientCreateWithColors(colorSpace, colors, colorLocations)
        let startPoint = CGPoint(x: self.bounds.width * 0.5, y: 0)
        let endPoint = CGPoint(x: self.bounds.width * 0.5, y: self.bounds.height)
        CGContextDrawLinearGradient(context, backgroundGradient, startPoint, endPoint, 0)
        
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

