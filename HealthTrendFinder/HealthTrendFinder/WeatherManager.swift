//
//  WeatherManager.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 8/10/15.
//
//

import UIKit
import Foundation
typealias ServiceResponse = (JSON, NSError?) -> Void

class WeatherManager: NSObject {
    
    var baseURL: String = "No URL"
    var data: String = ""
 
    var dataChanged = ""
    var checkData = ""
    var sum: Int = 0
    var error: Int = 0
    var success: Int = 0
    private static let _sharedInstance = WeatherManager()
    
    private override init() { super.init() }
    
    static func sharedInstance() -> WeatherManager {
        return _sharedInstance
    }
    
    func getRandomUser(onCompletion: (JSON) -> Void) {
        println("Starting getRandomUser")
        let route = self.baseURL
        println(self.baseURL)
        self.makeHTTPGetRequest(route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json:JSON = JSON(data: data)
            onCompletion(json, error)
            /*if error != nil {
                println("Error:\(error)")
            } else {
                println("No Error")
            }*/
        })
        task.resume()
    }
    
    func addData() {
        self.getRandomUser { json in

            var jsonData = json["history"]["dailysummary"][0]["maxtempi"]
            var lowData = json["history"]["dailysummary"][0]["date"]["pretty"]
            self.data = "\(jsonData)"
            self.checkData = "\(lowData)"
            dispatch_async(dispatch_get_main_queue(),{
                if self.data != "null" {
                    self.success++
                } else {
                    self.error++
                    println("Error Reading Data")
                }
            })
        }
    }
    
    func updateWeatherHistory() {
        println(self.baseURL)
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        println("Weather Updating...")
        // This sets the start date to midnight of the current date if no start date has been set.
        if StorageManager.getValue(StorageManager.StorageKeys.WeatherStartDate) == nil {
            let startDate: NSDate = calendar.startOfDayForDate(NSDate())
            StorageManager.setValue(startDate, forKey: StorageManager.StorageKeys.WeatherStartDate)
        }
        
        let fakeStartDate: NSDate = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.dateWithEra(1, year: 2015, month: 8, day: 6, hour: 0, minute: 0, second: 0, nanosecond: 0)!
        StorageManager.setValue(fakeStartDate, forKey: StorageManager.StorageKeys.WeatherStartDate)
        
        // This adds a data array if it hasn't been created yet.
        if StorageManager.getValue(StorageManager.StorageKeys.WeatherData) == nil {
            StorageManager.setValue([:], forKey: StorageManager.StorageKeys.WeatherData)
        }
        
        var weatherData: [NSDate: NSObject] = StorageManager.getValue(StorageManager.StorageKeys.WeatherData)! as! [NSDate : NSObject]
        let startMidnight: NSDate = StorageManager.getValue(StorageManager.StorageKeys.WeatherStartDate) as! NSDate
        let currentMidnight: NSDate = calendar.startOfDayForDate(NSDate())
        var daysFromStartDate: Int = calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: startMidnight, toDate: currentMidnight, options: nil).day
        println("Starting Loop")
        for i: Int in 0..<daysFromStartDate {
            
            let dateToBeExamined: NSDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: i, toDate: startMidnight, options: nil)!
            if weatherData[dateToBeExamined] == nil {
                let calendarUnits: NSCalendarUnit = .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear
                let components = NSCalendar.currentCalendar().components(calendarUnits, fromDate: dateToBeExamined)
                var month: String
                var day: String
                if components.month < 10 {
                    month = "0\(components.month)"
                } else {
                    month = "\(components.month)"
                }
                if components.day < 10 {
                    day = "0\(components.day)"
                } else {
                    day = "\(components.day)"
                }
                var apiDateString = "\(components.year)\(month)\(day)"
                self.baseURL = "http://api.wunderground.com/api/91e65f0fbb35f122/history_\(apiDateString)/q/OR/Portland.json"
                var get: () = self.addData()
                println(get)
                var waiting = true
                while waiting {
                    if checkData != "" && checkData != dataChanged {
                        waiting = false
                        println(dataChanged)
                        dataChanged = checkData
                        println(dataChanged)
                    } else if self.error != 0 {
                        waiting = false
                        daysFromStartDate = i
                    } else {
                        
                    }
                    
                }
                
                weatherData[dateToBeExamined] = self.data
                println(weatherData)
                
                
                
                // There is no data for the NSDate dateForInspection. You need to pull data and add it to the dictionary.
            } else {
                // Data exists for the specified date, so you don't need to do anything.
            }
        }
        println("Loop has finished or been skipped")
 
        
        println("Presenting Alert")
        
        if error != 0 {
            let alert = UIAlertView()
            alert.title = "Weather Data Update"
            alert.message = "HealthTrendFinder encountered an error while updating data."
            alert.addButtonWithTitle("OK")
            alert.addButtonWithTitle("Not OK")
            alert.show()
        } else {
            
        }
        
    }
    
}
