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
        ColorManager.colorForRGB(red: 0xFF, green: 0x3B, blue: 0x30),
        ColorManager.colorForRGB(red: 0xFF, green: 0x95, blue: 0x00),
        ColorManager.colorForRGB(red: 0xFF, green: 0xCC, blue: 0x00),
        ColorManager.colorForRGB(red: 0x4C, green: 0xD9, blue: 0x64),
        ColorManager.colorForRGB(red: 0x34, green: 0xAA, blue: 0xDC)
    ]
    
    static func colorForRGB(#red: Int, green: Int, blue: Int) -> UIColor {
        return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }
}