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
    func getHKQuantityDataHolden(sampleType: HKQuantityType, timeUnit: NSCalendarUnit, dataUnit: HKUnit, startDate: NSDate, endDate: NSDate, completion: ([(NSDate, Double)] -> Void)?) {
        var returnValue: [(NSDate, Double)] = []
        // Needed Variables
        var objectType = ""

        var startTime = 0
        var endTime = 0
        var repeat: Double
        var queryType: String = ""
        var predicate: NSPredicate!
        let timeInterval = endDate.timeIntervalSinceDate(startDate)
        var loop: Bool = true
        switch sampleType {
        case HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount):
            queryType = "step"
        case HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight):
            queryType = "height"
        case HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass):
            queryType = "weight"
        case HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex):
            queryType = "bmi"
        default:
            println("No recognized type")
        }

        switch timeInterval {
        // 1. Case for seconds
        case 0...59:
            predicate = HKQuery.predicateForSamplesWithStartDate(NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitSecond, value: startTime, toDate: NSDate(), options: nil), endDate: NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitSecond, value: startTime, toDate: NSDate(), options: nil), options: .None)
            repeat = timeInterval
        // 2. Case for minutes
        case 61...3599:
            predicate = HKQuery.predicateForSamplesWithStartDate(NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitMinute, value: startTime, toDate: NSDate(), options: nil), endDate: NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitMinute, value: startTime, toDate: NSDate(), options: nil), options: .None)
            repeat = round(timeInterval / 60)
        // 3. Case for Hours
        case 3600...86399:
            predicate = HKQuery.predicateForSamplesWithStartDate(NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitHour, value: startTime, toDate: NSDate(), options: nil), endDate: NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitHour, value: startTime, toDate: NSDate(), options: nil), options: .None)
            repeat = round(timeInterval / 3600)
        // 4. Default for Days
        default:
            predicate = HKQuery.predicateForSamplesWithStartDate(NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: startTime, toDate: NSDate(), options: nil), endDate: NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: startTime, toDate: NSDate(), options: nil), options: .None)
            repeat = round(timeInterval / 86400)
        }
        
        while loop {
            
        }
    }
        
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
