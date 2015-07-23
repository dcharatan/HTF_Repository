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
    func getHKQuantityData(sampleType: HKSampleType, timeUnit: NSCalendarUnit, startDate: NSDate, endDate: NSDate, completion: (Void -> Void)) -> [(NSDate, Double)] {
        var returnValue: [(NSDate, Double)] = []
        
        // Returns one data point for each timeUnit between startDate and endDate
        // array of tuples - (date, double)
        
        return returnValue
    }
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
        let healthKitTypesToRead = [
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth),
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType),
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount),
            HKObjectType.workoutType()
        ]
        let healthKitTypesToWrite = [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex),
            HKQuantityType.workoutType()
        ]
        
        // 3. If the store is not available, return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable() {
            let error = NSError(domain: "com.Test", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4. Request HealthKit authorization
        healthKitStore.requestAuthorizationToShareTypes(Set(healthKitTypesToWrite), readTypes: Set(healthKitTypesToRead)) { (success, error) -> Void in
            
            if( completion != nil ) {
                completion(success:success,error:error)
            }
        }
    }
    
    func readWeekData(sampleType:HKSampleType , completion: ((HKSample!, NSError!) -> Void)!) {
        for x in 1...7 {
            // Builds the Predicate
            var past = -1 * x
            var now = (-1 * x) + 1
            var mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: past, toDate: NSDate(), options: nil), endDate: NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: now, toDate: NSDate(), options: nil), options: .None)
            
            // Builds the sort descriptor to return the samples in descending order
            let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
            
            // 4. Build samples query
            let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: 0, sortDescriptors: [sortDescriptor])
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
    }
    
    
    func readDayData(sampleType:HKSampleType , completion: ((HKSample!, NSError!) -> Void)!) {
        for x in 1...24 {
            // Builds the Predicate
            var past = -1 * x
            var now = (-1 * x) + 1
            var mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitHour, value: past, toDate: NSDate(), options: nil), endDate: NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitHour, value: now, toDate: NSDate(), options: nil), options: .None)
            
            // Builds the sort descriptor to return the samples in descending order
            let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
            
            // 4. Build samples query
            let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: 0, sortDescriptors: [sortDescriptor])
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
        
    }
    
    func updateHeight() {
        // 1. Construct an HKSampleType for Height
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        // 2. Call the method to read the most recent Height sample
        self.readWeekData(sampleType, completion: { (mostRecentHeight, error) -> Void in
           
            if( error != nil ) {
                println("Error reading height from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            var heightLocalizedString = self.unknown
            self.height = (mostRecentHeight as? HKQuantitySample)!;
            // 3. Format the height to display it on the screen
            if let meters = self.height?.quantity.doubleValueForUnit(HKUnit.meterUnit()) {
                let heightFormatter = NSLengthFormatter()
                heightFormatter.forPersonHeightUse = true;
                heightLocalizedString = heightFormatter.stringFromMeters(meters);
            }
            
            // 4. Update UI. HealthKit uses an internal queue. We make sure that we interact with the UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                println(heightLocalizedString)
            });
        });
    }
    
    func stepsInPastWeek(completion: (Double, NSError?) -> () ) {
        for x in 1...7 {
            // The type of data we are requesting
            let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
            var dayBeginning = -1 * x
            var dayEnd = (-1 * x) + 1
            // Our search predicate which will fetch data from now until a day ago
            let predicate = HKQuery.predicateForSamplesWithStartDate(NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: dayBeginning, toDate: NSDate(), options: nil), endDate: NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: dayEnd, toDate: NSDate(), options: nil), options: .None)
            
            // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
                var steps: Double = 0
                
                
                if results?.count > 0 {
                    for result in results as! [HKQuantitySample] {
                        steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
                    }
                }
                
                completion(steps, error)
                
                self.weekStepData.append(steps)
                if self.weekStepData.count > 6 {
                    println(self.weekStepData)
                }
            }
            
            self.healthKitStore.executeQuery(query)
            
        }
    }
    func stepsInPastDay(completion: (Double, NSError?) -> () ) {
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
                
                self.dayStepData.append(steps)
                if self.dayStepData.count > 23 {
                    println(self.dayStepData)
                }
            }
            
            self.healthKitStore.executeQuery(query)
        }
    }
    
    func stepsAllTimeTotal(completion: (Double, NSError?) -> () ) {
        println("Running")
        var keepRunning: Bool = true
        var getData: Bool = true
            // The type of data we are requesting
            let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)

            // Our search predicate which will fetch data from now until a day ago
            let predicate = HKQuery.predicateForSamplesWithStartDate(NSDate.distantPast() as! NSDate, endDate: NSDate(), options: .None)
            
            // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
                var steps: Double = 0
                
                
                if results?.count > 0 {
                    for result in results as! [HKQuantitySample] {
                        steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
                    }
                }
                
                completion(steps, error)
                self.allTimeStepsTotal += steps
 

            }
            
            self.healthKitStore.executeQuery(query)


        while keepRunning {
            // if the total number of recorded steps is not zero:
            if allTimeStepsTotal != 0.0 {
                // if the "getData" boolean is true:
                if getData {
                    // print the total number of recorded steps and the current sum of recorded steps to the console
                    println(allTimeStepsTotal)
                    println(allTimeStepsSum)
                    // execute the function to save a day's step data to the allTimeSteps array
                    self.stepsAllTime({Double, NSError in})
                    // Set getData to false so that the loop does not auto-execute the function
                    getData = false
                } else {
                    if allTimeStepsTotal > allTimeStepsSum {
                        if checker == allTimeSteps.count {
                            getData = false
                        } else if checker < allTimeSteps.count {
 
                            getData = true
                        }
                    } else {
                        println(allTimeSteps)
                        keepRunning = false
                    }
                }
            }
        }

    }
    
    func stepsAllTime(completion: (Double, NSError?) -> Void) {
        var stopStart = true
        x += -1
        // The type of data we are requesting
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        var dayBeginning = x
        var dayEnd = x + 1
        var daysSinceToday = -1 * dayBeginning
        for item in self.allTimeSteps {
            self.checker += 1
        }
        // Our search predicate which will fetch data from now until a day ago
        let samplePredicate = HKQuery.predicateForSamplesWithStartDate(NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: dayBeginning, toDate: NSDate(), options: nil), endDate: NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: dayEnd, toDate: NSDate(), options: nil), options: .None)
        
        // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
        let stepQuery = HKSampleQuery(sampleType: sampleType, predicate: samplePredicate, limit: 0, sortDescriptors: nil) { query, results, error in
            var steps: Double = 0
            self.checker = 0
            
            if results?.count > 0 {
                for result in results as! [HKQuantitySample] {
                    steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
                }
            }
            
            completion(steps, error)
            self.allTimeStepsSum += steps
            self.allTimeSteps.append(steps)
            for item in self.allTimeSteps {
                self.checker += 1
            }
            /*
            println("New Sum:")
            println(self.allTimeStepsSum)
            println("Days Since Today:")
            println(daysSinceToday)
            println("Steps taken today:")
            println(steps)
            */
            
        }
        if !(self.allTimeStepsTotal > self.allTimeStepsSum) {
            stopStart = false
        }
        
        self.healthKitStore.executeQuery(stepQuery)
    }
}
