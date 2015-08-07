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
        
        // BELOW HERE, THIS IS TESTING STUFF -- DO NOT DELETE
        var hk = HKManager()
        hk.getHKQuantityData(HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount), timeUnit: NSCalendarUnit.CalendarUnitDay, dataUnit: HKUnit.countUnit(), startDate: NSDate(timeIntervalSinceNow: -(7 * 24 * 60 * 60)), endDate: NSDate(), completion: {data in
            // THIS IS WHERE YOU DO THE NEXT THING!
            // DATA IS ACCESSED WITH data
            // data is [(NSDate, Double)]
        })
        
        //var notification: UILocalNotification = UILocalNotification()
        //notification.alertAction = "view cards"
        //notification.alertBody = "This is an entirely fake notification, but it shows that notifications work."
        //notification.fireDate = NSDate(timeIntervalSinceNow: 15)
        //UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
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

