//
//  WeatherManager.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 8/10/15.
//
//

import UIKit

class WeatherManager {
    // Note: All dates linked to weather information should be at midnight (i.e. the start of the day).
    // Note: The format of the data should be [(date: NSDate):(location: NotSureWhatFormatThisWillUse, tempHigh: Double, tempLow: Double, someOtherInformation0: SomeObject ... someOtherInformationN: SomeObject)]
    // Note: In other words, you use the date as the key. Multiple locations won't be needed for the same date, since you're usually only in one region each day.
    
    static func updateWeatherHistory(completion: (success: Bool, error: NSError) -> Void) {
        // This calendar is needed in several places, so it is created here.
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        // This sets the start date to midnight of the current date if no start date has been set.
        if StorageManager.getValue(StorageManager.StorageKeys.WeatherStartDate) == nil {
            let startDate: NSDate = calendar.startOfDayForDate(NSDate())
            StorageManager.setValue(startDate, forKey: StorageManager.StorageKeys.WeatherStartDate)
        }
        
        // This adds a data array if it hasn't been created yet.
        if StorageManager.getValue(StorageManager.StorageKeys.WeatherData) == nil {
            StorageManager.setValue([:], forKey: StorageManager.StorageKeys.WeatherData)
        }
        
        // This determines which dates need filling in.
        var weatherData: AnyObject! = StorageManager.getValue(StorageManager.StorageKeys.WeatherData)
        let startMidnight: NSDate = StorageManager.getValue(StorageManager.StorageKeys.WeatherStartDate) as! NSDate
        let currentMidnight: NSDate = calendar.startOfDayForDate(NSDate())
        let daysFromStartDate: Int = calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: startMidnight, toDate: currentMidnight, options: nil).day
        
        for i: Int in 0..<daysFromStartDate {
            let dateToBeExamined: NSDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: i, toDate: startMidnight, options: nil)!
            if weatherData[dateToBeExamined] == nil {
                // There is no data for the NSDate dateForInspection. You need to pull data and add it to the dictionary.
            } else {
                // Data exists for the specified date, so you don't need to do anything.
            }
        }
    }
}