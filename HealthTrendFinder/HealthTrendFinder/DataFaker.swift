//
//  DataFaker.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 7/28/15.
//
//

import UIKit

class DataFaker: NSObject {
    static func linearFakeQuantitativeData(days: Int = 7, name: String) -> QuantitativeDataSet {
        var returnValue: QuantitativeDataSet = QuantitativeDataSet(data: [])
        returnValue.name = name
        
        let deltaY: Int = Int(arc4random_uniform(200)) - 100
        let slope: Double = Double(deltaY) // deltaX is one, so no division is necessary
        let yIntercept: Double = 1000 + Double(arc4random_uniform(1000))
        let scatter: Double = Double(arc4random_uniform(100)) / 200
        
        for i in 0..<days {
            let currentDate: NSDate = generateDate(2015, month: 6, day: 30 - i)
            let currentValue: Double = yIntercept + slope * Double(i) * scatter * Double(Int(arc4random_uniform(200)) - 100) / 100
            returnValue.data.insert((date: currentDate, value: currentValue), atIndex: 0)
        }
        
        println("DataFaker.linearFakeQuantitativeData(days: \(days), name: \(name)) -> QuantitativeDataSet")
        println("slope: \(slope)")
        
        return returnValue
    }
    
    static func generateDate(year: Int, month: Int, day: Int) -> NSDate {
        var components: NSDateComponents = NSDateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        let gregorianCalendar: NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        return gregorianCalendar.dateFromComponents(components)!
    }
}
