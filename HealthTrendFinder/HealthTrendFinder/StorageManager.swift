//
//  StorageManager.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 7/29/15.
//
//

import UIKit

class StorageManager {
    enum StorageKeys: String {
        // HealthKit Authorization
        case HealthKitAuthorized = "HealthKitAuthorized"
        
        // Notifications
        case AllowWeeklyNotifications = "AllowWeeklyNotifications"
        case AllowDailyNotifications = "AllowDailyNotifications"
        
        // Weather
        case WeatherStartDate = "WeatherStartDate"
        case WeatherData = "WeatherData"
    }
    
    static func verifySaveFile() {
        // These values are part of the settings, so standard values must be set.
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if defaults.valueForKey(StorageKeys.HealthKitAuthorized.rawValue) == nil {
            defaults.setValue(false, forKey: StorageKeys.HealthKitAuthorized.rawValue)
        }
        
        if defaults.valueForKey(StorageKeys.AllowWeeklyNotifications.rawValue) == nil {
            defaults.setValue(true, forKey: StorageKeys.AllowDailyNotifications.rawValue)
        }
        
        if defaults.valueForKey(StorageKeys.AllowWeeklyNotifications.rawValue) == nil {
            defaults.setValue(true, forKey: StorageKeys.AllowWeeklyNotifications.rawValue)
        }
    }
    
    static func getValue(key: StorageKeys) -> AnyObject? {
        var defaults = NSUserDefaults.standardUserDefaults()
        return defaults.valueForKey(key.rawValue)
    }
    
    static func setValue(value: AnyObject, forKey: StorageKeys) {
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(value, forKey: forKey.rawValue)
        defaults.synchronize()
    }
}