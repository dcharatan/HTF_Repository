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
    
    override init(frame: CGRect) {
        // This stuff is executed when the CardView is created from code.
        super.init(frame: frame)
        originalLocation = self.center
        self.backgroundColor = UIColor(red: 246 / 255, green: 246 / 255, blue: 246 / 255, alpha: 1)
        self.layer.borderWidth = 1 / UIScreen.mainScreen().scale
        self.layer.borderColor = UIColor(red: 193 / 255, green: 193 / 255, blue: 193 / 255, alpha: 1).CGColor
    }
    
    required init(coder aDecoder: NSCoder) {
        // This stuff is executed when the CardView is created form the storyboard.
        super.init(coder: aDecoder)
    }
    
}

