//
//  HKManager.swift
//  HealthTrendFinder
//
//  Created by Holden Lee on 7/6/15.
//
//

import HealthKit
import Foundation

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

        // 4. Return the information read in a tuple
        return(age, biologicalSex, bloodType)
    }
}
