//
//  AnalysisTools.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 6/30/15.
//
//

import UIKit

class AnalysisTools: NSObject {
    static func pcc(data: [(Double, Double)]) -> Double {
        // This function determines Pearson's correlation coefficient for a given data set.
        
        // This determines the average data values for x and y.
        var totalX: Double = 0.0
        var totalY: Double = 0.0
        for i in 0..<data.count {
            totalX += data[i].0
            totalY += data[i].1
        }
        let averageX: Double = totalX / Double(data.count)
        let averageY: Double = totalY / Double(data.count)
        
        // This determines the numerator's value and the denominator's components' values.
        var numerator: Double = 0.0
        var denominatorComponentX: Double = 0.0
        var denominatorComponentY: Double = 0.0
        for i in 0..<data.count {
            numerator += (data[i].0 - averageX) * (data[i].1 - averageY)
            denominatorComponentX += (data[i].0 - averageX) * (data[i].0 - averageX)
            denominatorComponentY += (data[i].1 - averageY) * (data[i].1 - averageY)
        }
        
        // This pieces together the numerator and the denominator's components to determine r.
        return numerator / (sqrt(denominatorComponentX) * sqrt(denominatorComponentY))
    }
    
    static func pccToString(r: Double) -> String {
        switch r {
        case 0:
            return "Nonexistant"
        case 0..<0.2:
            return "Very Weak"
        case 0.2..<0.4:
            return "Weak"
        case 0.4..<0.6:
            return "Moderate"
        case 0.6..<0.8:
            return "Strong"
        case 0.8..<1:
            return "Very Strong"
        case 1:
            return "Perfect"
        default:
            return "Invalid"
        }
    }
}
