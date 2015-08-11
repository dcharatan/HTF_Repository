//
//  WeatherManager.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 8/10/15.
//
//

import UIKit
import Foundation

class WeatherManager: NSObject {
    
    
        
    static func updateWeatherHistory() {
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        var url = ""
        // This sets the start date to midnight of the current date if no start date has been set.
        if StorageManager.getValue(StorageManager.StorageKeys.WeatherStartDate) == nil {
            let startDate: NSDate = calendar.startOfDayForDate(NSDate())
            StorageManager.setValue(startDate, forKey: StorageManager.StorageKeys.WeatherStartDate)

        }
        
        // This adds a data array if it hasn't been created yet.
        if StorageManager.getValue(StorageManager.StorageKeys.WeatherData) == nil {
            StorageManager.setValue([:], forKey: StorageManager.StorageKeys.WeatherData)
        }
        
        var weatherData: AnyObject = StorageManager.getValue(StorageManager.StorageKeys.WeatherData)!
        let startMidnight: NSDate = StorageManager.getValue(StorageManager.StorageKeys.WeatherStartDate) as! NSDate
        let currentMidnight: NSDate = calendar.startOfDayForDate(NSDate())
        let daysFromStartDate: Int = calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: startMidnight, toDate: currentMidnight, options: nil).day
        
        for i: Int in 0..<daysFromStartDate {
            let dateToBeExamined: NSDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: i, toDate: startMidnight, options: nil)!
            if weatherData[dateToBeExamined] == nil {
                let calendarUnits: NSCalendarUnit = .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear
                let components = NSCalendar.currentCalendar().components(calendarUnits, fromDate: dateToBeExamined)
                var dateString = "\(components.year)\(components.day)\(components.month)"
                var api = "http://api.wunderground.com/api/91e65f0fbb35f122/history_\(dateString)/q/OR/Portland.json"
                var url = NSURL(string: api)
                var session = NSURLSession.sharedSession()
                typealias JSONdic = [String: AnyObject]
                
                let json: AnyObject = ["greeting": "Hello"]
                if let json = json as? JSONdic, history = json["history"] as? JSONdic, temp = history["tempi"] as? String, hum = history["hum"] as? String, precip = history["precipi"] as? String{
                    println("Temperature:\(temp) Humidity:\(hum) Precipitation:\(precip)")
                    
                }
                
                // There is no data for the NSDate dateForInspection. You need to pull data and add it to the dictionary.
            } else {
                // Data exists for the specified date, so you don't need to do anything.
            }
        }
    }
}
