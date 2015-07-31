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
import Darwin

class HKManager {
    // none of these variables should be here
    var weekStepData = [Double]()
    var dayStepData = [Double]()
    var x = 1
    var checker = 0
    var allTimeStepsTotal: Double = 0.0
    var allTimeStepsSum: Double = 0.0
    var allTimeSteps = [Double]()
    var unknown = "Unknown"
    var height:HKQuantitySample?
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    // This is the only data fetching function we need
    func getHKQuantityData(sampleType: HKQuantityType, timeUnit: NSCalendarUnit, dataUnit: HKUnit, startDate: NSDate, endDate: NSDate, completion: ([(NSDate, Double)] -> Void)?) {
        var returnValue: [(NSDate, Double)] = []
        
        let conversionComponents: NSDateComponents = NSCalendar.currentCalendar().components(timeUnit, fromDate: startDate, toDate: endDate, options: nil)
        let elapsedUnitsBetweenDates: Int = conversionComponents.valueForComponent(timeUnit)
        let predicateStartDate: NSDate = NSCalendar.currentCalendar().dateByAddingUnit(timeUnit, value: -elapsedUnitsBetweenDates, toDate: endDate, options: nil)!
        let predicateEndDate: NSDate = endDate
        let predicate: NSPredicate = HKQuery.predicateForSamplesWithStartDate(predicateStartDate, endDate: predicateEndDate, options: HKQueryOptions.None)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors: nil) {query, results, error in
            // This takes all of the results
            var currentSectionTotal: Double = 0
            var currentSectionNumber: Int = 0
            if results?.count > 0 {
                var currentSectionStartDate: NSDate = NSDate()
                var currentSectionEndDate: NSDate = NSDate()
                
                for result: HKQuantitySample in results as! [HKQuantitySample] {
                    currentSectionEndDate = NSCalendar.currentCalendar().dateByAddingUnit(timeUnit, value: -currentSectionNumber, toDate: predicateEndDate, options: nil)!
                    currentSectionStartDate = NSCalendar.currentCalendar().dateByAddingUnit(timeUnit, value: -1, toDate: currentSectionEndDate, options: nil)!
                    
                    while currentSectionStartDate.timeIntervalSinceDate(result.endDate) > 0 {
                        returnValue += [(currentSectionStartDate, currentSectionTotal)]
                        currentSectionNumber += 1
                        currentSectionTotal = 0
                        currentSectionEndDate = NSCalendar.currentCalendar().dateByAddingUnit(timeUnit, value: -currentSectionNumber, toDate: predicateEndDate, options: nil)!
                        currentSectionStartDate = NSCalendar.currentCalendar().dateByAddingUnit(timeUnit, value: -1, toDate: currentSectionEndDate, options: nil)!
                    }
                    
                    currentSectionTotal += result.quantity.doubleValueForUnit(dataUnit)
                }
                
                while currentSectionNumber < elapsedUnitsBetweenDates {
                    returnValue += [(currentSectionStartDate, currentSectionTotal)]
                    currentSectionNumber += 1
                    currentSectionTotal = 0
                    currentSectionEndDate = NSCalendar.currentCalendar().dateByAddingUnit(timeUnit, value: -currentSectionNumber, toDate: predicateEndDate, options: nil)!
                    currentSectionStartDate = NSCalendar.currentCalendar().dateByAddingUnit(timeUnit, value: -1, toDate: currentSectionEndDate, options: nil)!
                }
                
                if let completionFunction = completion {
                    completionFunction(returnValue)
                }
                
                println("HKManager.getHKQuantityData:")
                println("returnValue.count: \(returnValue.count), elapsedUnitsBetweenDates: \(elapsedUnitsBetweenDates)")
                println("returnValue: \(returnValue)")
            }
        }
        self.healthKitStore.executeQuery(query)
    }
    
    func authorizeHealthKit(completion: ((success: Bool, error: NSError?) -> Void)!) {
        let healthKitTypesToRead: Set = [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)
        ]
        
        if !HKHealthStore.isHealthDataAvailable() {
            if completion != nil {
                completion(success: false, error: nil)
            }
            return
        }
        
        healthKitStore.requestAuthorizationToShareTypes(Set(), readTypes: healthKitTypesToRead) { (success, error) -> Void in
            if completion != nil {
                completion(success: success, error: error)
            }
        }
    }
}
