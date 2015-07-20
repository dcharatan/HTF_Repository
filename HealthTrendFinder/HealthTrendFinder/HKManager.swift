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
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount),
            HKQuantityType.workoutType()
        ]
        
        // 3. If the store is not available, return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.Test", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4. Request HealthKit authorization
        healthKitStore.requestAuthorizationToShareTypes(Set(healthKitTypesToWrite), readTypes: Set(healthKitTypesToRead)) { (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }
    
    func readProfile() -> ( age:Int?, biologicalsex:HKBiologicalSexObject?, bloodtype:HKBloodTypeObject?)
    {
        var error:NSError?
        var age:Int?
        
        // 1. Request birthday and calculate age
        if let birthDay = healthKitStore.dateOfBirthWithError(&error)
        {
            let today = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let differenceComponents = NSCalendar.currentCalendar().components(.CalendarUnitYear, fromDate: birthDay, toDate: today, options: NSCalendarOptions(0) )
            age = differenceComponents.year
        }
        if error != nil {
            println("Error reading Biological Sex: \(error)")
        }
        // 2. Read biological sex
        var biologicalSex:HKBiologicalSexObject? = healthKitStore.biologicalSexWithError(&error);
        if error != nil {
            println("Error reading Biological Sex: \(error)")
        }
        // 3. Read Blood Type
        var bloodType:HKBloodTypeObject? = healthKitStore.bloodTypeWithError(&error);
        if error != nil {
            println("Error reading Blood type: \(error)")
        }
        enum HKBloodType : Int {
            case NotSet
            case APositive
            case ANegative
            case BPositive
            case BNegative
            case ABPositive
            case ABNegative
            case OPositive
            case ONegative
            
            var description : String {
                switch self {
                    // Use Internationalization, as appropriate.
                case .APositive: return "APositive";
                case .ANegative: return "ANegative";
                case .BPositive: return "BPositive";
                case .BNegative: return "BNegative";
                case .ABPositive: return "ABPositive";
                case .ABNegative: return "ABNegative";
                case .OPositive: return "OPositive";
                case .ONegative: return "ONegative";
                default: return "";
                }
            }
        }
        // 4. Return the information read in a tuple
        return(age, biologicalSex, bloodType)
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
            { (sampleQuery, results, error) -> Void in
                
                if let queryError = error {
                    completion(nil,error)
                    return;
                }
                
                // Get First Sample
                let mostRecentSample = results.first as? HKQuantitySample
                
                //Execute the completion closure
                if completion != nil {
                    completion(mostRecentSample,nil)
                }
        }
        
        // 5. Execute the Query
        self.healthKitStore.executeQuery(sampleQuery)
    }
    
    func stepsInPastWeek(completion: (Double, NSError?) -> () )
    {
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
                
                
                if results?.count > 0
                {
                    for result in results as! [HKQuantitySample]
                    {
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
    func stepsInPastDay(completion: (Double, NSError?) -> () )
    {
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
                
                
                if results?.count > 0
                {
                    for result in results as! [HKQuantitySample]
                    {
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
    
    func stepsAllTime(completion: (Double, NSError?) -> () )
    {
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
                
                
                if results?.count > 0
                {
                    for result in results as! [HKQuantitySample]
                    {
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
    
    func saveBMISample(bmi:Double, date:NSDate ) {
        // 1. Create a BMI Sample
        let bmiType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)
        let bmiQuantity = HKQuantity(unit: HKUnit.countUnit(), doubleValue: bmi)
        let bmiSample = HKQuantitySample(type: bmiType, quantity: bmiQuantity, startDate: date, endDate: date)
        
        // 2. Save the sample in the store
        healthKitStore.saveObject(bmiSample, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                println("Error saving BMI sample: \(error.localizedDescription)")
            } else {
                println("BMI sample saved successfully!")
            }
        })
    }

}