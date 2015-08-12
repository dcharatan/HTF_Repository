//
//  AppDelegate.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 6/29/15.
//
//

import UIKit
import Foundation
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // This verifies that there's a save file every time the app is launched.
        StorageManager.verifySaveFile()
        
        // This asks for permission for notifications.
        //application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
        
        // TESTING STUFF BELOW THIS POINT
        
        let data = [
            CGPointMake(200, 1.8),
            CGPointMake(275, 1.6),
            CGPointMake(300, 2.2),
            CGPointMake(350, 2.1),
            CGPointMake(600, 4.0),
        ]
        
        var a = AnalysisTools.spearmanRho(data)
        println(a)
        
        let updateWeather: () = WeatherManager.updateWeatherHistory()
        println(updateWeather)
        // This part for debugging only
        var weatherData = [NSDate: NSObject]()
        let calendarUnits: NSCalendarUnit = .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear
        let components = NSCalendar.currentCalendar().components(calendarUnits, fromDate: NSDate())
        var dateString = "\(components.year)\(components.day)\(components.month)"
        var api = "http://api.wunderground.com/api/91e65f0fbb35f122/history_\(dateString)/q/OR/Portland.json"
        var url = NSURL(string: api)
        var session = NSURLSession.sharedSession()
        println("We got this far")
        typealias JSONdic = [String: AnyObject]
        
        let json: NSObject = api
        println("Got here too")
        if let json = json as? JSONdic, history = json["history"] as? JSONdic, temp = history["tempi"] as? Int, hum = history["hum"] as? String, precip = history["precipi"] as? String{
            println("Temperature:\(temp)")
            weatherData = [:]
            weatherData[NSDate()] = temp
        }
        println("Done")
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

