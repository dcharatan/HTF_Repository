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
        println("Weather Updating...")
        // This sets the start date to midnight of the current date if no start date has been set.
        if StorageManager.getValue(StorageManager.StorageKeys.WeatherStartDate) == nil {
            let startDate: NSDate = calendar.startOfDayForDate(NSDate())
            StorageManager.setValue(startDate, forKey: StorageManager.StorageKeys.WeatherStartDate)

        }
        
        // This adds a data array if it hasn't been created yet.
        if StorageManager.getValue(StorageManager.StorageKeys.WeatherData) == nil {
            StorageManager.setValue([:], forKey: StorageManager.StorageKeys.WeatherData)
            
        }
        
        var weatherData: [NSDate: NSObject] = StorageManager.getValue(StorageManager.StorageKeys.WeatherData)! as! [NSDate : NSObject]
        let startMidnight: NSDate = StorageManager.getValue(StorageManager.StorageKeys.WeatherStartDate) as! NSDate
        let currentMidnight: NSDate = calendar.startOfDayForDate(NSDate())
        let daysFromStartDate: Int = calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: startMidnight, toDate: currentMidnight, options: nil).day
        println("Starting Loop")
        for i: Int in 0..<daysFromStartDate {
            
            let dateToBeExamined: NSDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: i, toDate: startMidnight, options: nil)!
            if weatherData[dateToBeExamined] == nil {
                let calendarUnits: NSCalendarUnit = .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear
                let components = NSCalendar.currentCalendar().components(calendarUnits, fromDate: dateToBeExamined)
                var dateString = "\(components.year)\(components.day)\(components.month)"
                var api = "http://api.wunderground.com/api/91e65f0fbb35f122/history_\(dateString)/q/OR/Portland.json"
                var url = NSURL(string: api)
                var session = NSURLSession.sharedSession()
                println("We got this far")
                typealias JSONdic = [String: AnyObject]
                
                let json: NSObject = api
                if let json = json as? JSONdic, history = json["history"] as? JSONdic, temp = history["tempi"] as? Int, hum = history["hum"] as? String, precip = history["precipi"] as? String{
                    println("Temperature:\(temp)")
                    weatherData = [:]
                    weatherData[dateToBeExamined] = temp
                }
                
                // There is no data for the NSDate dateForInspection. You need to pull data and add it to the dictionary.
            } else {
                // Data exists for the specified date, so you don't need to do anything.
            }
        }
        println("Loop has finished or been skipped")
    }
}
