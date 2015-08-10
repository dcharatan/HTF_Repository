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
        case HealthKitAuthorized = "HealthKitAuthorized"
        case AllowWeeklyNotifications = "AllowWeeklyNotifications"
        case AllowDailyNotifications = "AllowDailyNotifications"
        case WeatherStartDate = "WeatherStartDate"
        case WeatherData = "WeatherData"
    }
    
    static func verifySaveFile() {
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