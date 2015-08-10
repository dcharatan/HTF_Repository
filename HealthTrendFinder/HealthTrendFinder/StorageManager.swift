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
        case healthKitAuthorized = "healthKitAuthorized"
        case allowWeeklyNotifications = "allowWeeklyNotifications"
        case allowDailyNotifications = "allowDailyNotifications"
    }
    
    static func verifySaveFile() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if defaults.valueForKey(StorageKeys.healthKitAuthorized.rawValue) == nil {
            defaults.setValue(false, forKey: StorageKeys.healthKitAuthorized.rawValue)
        }
        
        if defaults.valueForKey(StorageKeys.allowWeeklyNotifications.rawValue) == nil {
            defaults.setValue(true, forKey: StorageKeys.allowDailyNotifications.rawValue)
        }
        
        if defaults.valueForKey(StorageKeys.allowWeeklyNotifications.rawValue) == nil {
            defaults.setValue(true, forKey: StorageKeys.allowWeeklyNotifications.rawValue)
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