//
//  HKManager.swift
//  HealthTrendFinder
//
//  Created by Holden Lee on 7/6/15.
//
//

import HealthKit
import Foundation
import UIKit

class HKManager {
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!) {
        // This keeps track of the types that will be read.
        let healthKitTypesToRead = [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)
        ]
        
        // This throws an error if HealthKit isn't available.
        if !HKHealthStore.isHealthDataAvailable() {
            let error = NSError(domain: "com.Test", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this device"])
            if completion != nil {
                completion(success:false, error:error)
            }
            return
        }
        
        // This requests HealthKit authorization.
        healthKitStore.requestAuthorizationToShareTypes(Set(), readTypes: Set(arrayLiteral: healthKitTypesToRead)) {(success, error) -> Void in
            if completion != nil {
                completion(success: success, error: error)
            }
        }
    }
    
    func readMostRecentSample(sampleType:HKSampleType , completion: ((HKSample!, NSError!) -> Void)!) {
        
        // 1. Build the Predicate
        let past = NSDate.distantPast() as! NSDate
        let now = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate:now, options: .None)
        
        // 2. Build the sort descriptor to return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        
        // 3. Limit the number of samples returned by the query to just 1 (most recent)
        let limit = 1
        
        // 4. Build samples query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
            {(sampleQuery, results, error) -> Void in
                
                if let queryError = error {
                    completion(nil, error)
                    return
                }
                
                // Get First Sample
                let mostRecentSample = results.first as? HKQuantitySample
                
                // Execute the completion closure
                if completion != nil {
                    completion(mostRecentSample,nil)
                }
        }
        
        // 5. Execute the Query
        self.healthKitStore.executeQuery(sampleQuery)
    }
    
    func stepsInPastWeek(completion: (Double, NSError?) -> () ) {
        var weekStepData = [Double]()
        for x in 1...7 {
            // The type of data we are requesting
            let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
            var daysAgo = -1 * x
            var daysSince = (-1 * x) + 1
            // Our search predicate which will fetch data from now until a day ago
            let predicate = HKQuery.predicateForSamplesWithStartDate(NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: daysAgo, toDate: NSDate(), options: nil), endDate: NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: daysSince, toDate: NSDate(), options: nil), options: .None)
            
            // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
                var steps: Double = 0
                
                
                if results?.count > 0 {
                    for result in results as! [HKQuantitySample] {
                        steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
                    }
                }
                
                completion(steps, error)
                
                weekStepData.append(steps)
                if weekStepData.count > 6 {
                    for item in weekStepData {
                        println(item)
                    }
                }
            }
            
            self.healthKitStore.executeQuery(query)
            
        }
    }
    func stepsInPastDay(completion: (Double, NSError?) -> () ) {
        var dayStepData = [Double]()
        for x in 1...24 {
            // The type of data we are requesting
            let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
            var hoursAgo = -1 * x
            var hoursSince = (-1 * x) + 1
            // Our search predicate which will fetch data from now until a day ago
            let predicate = HKQuery.predicateForSamplesWithStartDate(NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitHour, value: hoursAgo, toDate: NSDate(), options: nil), endDate: NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitHour, value: hoursSince, toDate: NSDate(), options: nil), options: .None)
            
            // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
                var steps: Double = 0
                
                
                if results?.count > 0 {
                    for result in results as! [HKQuantitySample] {
                        steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
                    }
                }
                
                completion(steps, error)
                
                dayStepData.append(steps)
                if dayStepData.count > 23 {
                    for item in dayStepData {
                        println(item)
                    }
                }
            }
            
            self.healthKitStore.executeQuery(query)
            println(dayStepData.count)
        }
        println(dayStepData.count)
    }
    
    func stepsAllTime(completion: (Double, NSError?) -> () ) {
        var allTimeStepData = [Double]()
        var y: Int = 0
        var x = 0

        while y < 3 {
            // The type of data we are requesting
            let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
            x += -1
            var daysAgo = x
            var daysSince = x + 1
            // Our search predicate which will fetch data from now until a day ago
            let predicate = HKQuery.predicateForSamplesWithStartDate(NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: daysAgo, toDate: NSDate(), options: nil), endDate: NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: daysSince, toDate: NSDate(), options: nil), options: .None)
            
            // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
                var steps: Double = 0
                
                
                if results?.count > 0 {
                    for result in results as! [HKQuantitySample] {
                        steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
                    }
                }
                
                completion(steps, error)
                allTimeStepData.append(steps)
                
                if steps == 0.0 && y == 2 {
                    y += 1
                } else if steps == 0.0 && y == 1 {
                    y += 1
                } else if steps == 0.0 {
                    y += 1
                } else {
                   y = 0
                }
                println(y)
            }
            
            self.healthKitStore.executeQuery(query)
            println(allTimeStepData.count)
            for item in allTimeStepData {
                println(item)
            }
        }
    }
}