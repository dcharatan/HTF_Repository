//
//  ColorManager.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 8/4/15.
//
//

import UIKit

class ColorManager: NSObject {
    static let colors: [UIColor] = [
        UIColor(red: 247 / 255, green: 47 / 255, blue: 56 / 255, alpha: 1),
        UIColor(red: 248 / 255, green: 149 / 255, blue: 28 / 255, alpha: 1),
        UIColor(red: 250 / 255, green: 206 / 255, blue: 31 / 255, alpha: 1),
        UIColor(red: 89 / 255, green: 221 / 255, blue: 101 / 255, alpha: 1),
        UIColor(red: 75 / 255, green: 169 / 255, blue: 219 / 255, alpha: 1),
        UIColor(red: 95 / 255, green: 75 / 255, blue: 231 / 255, alpha: 1)
    ]
    
    static func colorForRGB(#red: Int, green: Int, blue: Int) -> UIColor {
        return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }
}