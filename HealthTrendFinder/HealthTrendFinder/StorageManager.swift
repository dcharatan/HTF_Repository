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
        case allowContextBasedNotifications = "allowContextBasedNotifications"
    }
}