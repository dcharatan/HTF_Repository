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
    
    static func spearmanRho(data: [CGPoint]) -> CGFloat {
        // This extracts and sorts x/y values.
        var xSortedValues: [CGFloat] = []
        var ySortedValues: [CGFloat] = []
        
        for point: CGPoint in data {
            xSortedValues += [point.x]
            ySortedValues += [point.y]
        }
        
        xSortedValues.sort({$1 < $0})
        ySortedValues.sort({$1 < $0})
        
        // This determines the values of d^2 and adds them to dSum
        var dSum: CGFloat = 0
        
        for i: Int in 0..<data.count {
            let xValue: CGFloat = data[i].x
            let yValue: CGFloat = data[i].y
            var xRank: Int = 0
            var yRank: Int = 0
            
            for i_x: Int in 0..<xSortedValues.count {
                if xValue == xSortedValues[i_x] {
                    xRank = i_x + 1
                    break
                }
            }
            
            for i_y: Int in 0..<ySortedValues.count {
                if yValue == ySortedValues[i_y] {
                    yRank = i_y + 1
                    break
                }
            }
            
            let d: Int = xRank - yRank
            let dSquared: CGFloat = CGFloat(d) * CGFloat(d)
            
            dSum += dSquared
        }
        
        // This calculates the rest.
        return 1 - (6 * dSum) / CGFloat(data.count * (data.count * data.count - 1))
    }
    
    static func kendallTau(data: [CGPoint]) -> CGFloat {
        return 0
    }
}
