//
//  AnalysisTools.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 6/30/15.
//
//

import UIKit

class AnalysisTools: NSObject {
    static func pearsonR(data: [CGPoint]) -> CGFloat {
        // This function determines Pearson's correlation coefficient for a given data set.
        
        // This determines the average data values for x and y.
        var totalX: CGFloat = 0.0
        var totalY: CGFloat = 0.0
        for i in 0..<data.count {
            totalX += data[i].x
            totalY += data[i].y
        }
        let averageX: CGFloat = totalX / CGFloat(data.count)
        let averageY: CGFloat = totalY / CGFloat(data.count)
        
        // This determines the numerator's value and the denominator's components' values.
        var numerator: CGFloat = 0.0
        var denominatorComponentX: CGFloat = 0.0
        var denominatorComponentY: CGFloat = 0.0
        for i in 0..<data.count {
            numerator += (data[i].x - averageX) * (data[i].y - averageY)
            denominatorComponentX += (data[i].x - averageX) * (data[i].x - averageX)
            denominatorComponentY += (data[i].y - averageY) * (data[i].y - averageY)
        }
        
        // This pieces together the numerator and the denominator's components to determine r.
        let r: CGFloat = numerator / (sqrt(denominatorComponentX) * sqrt(denominatorComponentY))
        return r
    }
}
