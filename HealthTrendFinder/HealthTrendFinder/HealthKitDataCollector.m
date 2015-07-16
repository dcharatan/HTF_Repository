//
//  HealthKitDataCollector.m
//  HealthTrendFinder
//
//  Created by Cameron on 5/25/15.
//  Copyright (c) 2015 Cameron. All rights reserved.
//

#import "HealthKitDataCollector.h"
@import HealthKit;

// Needed?
@interface HealthKitDataCollector () {
    HKHealthStore *healthStore;
    HKSampleQuery *stepsQuery;
    HKSampleQuery *cyclingQuery;
    HKSampleQuery *sleepQuery;
    HKSampleType *stepsSampleType;
    HKSampleType *cyclingSampleType;
    HKSampleType *sleepSampleType;
    NSSortDescriptor *sortDescriptor;
    ActivityDataSet *activitySet;
}

@end


// Needed
@implementation HealthKitDataCollector


- (id) init {
    if (self = [super init]) {
        stepsQuery = nil;
        cyclingQuery = nil;
        sleepQuery = nil;
        activitySet = [[ActivityDataSet alloc] init];
        healthStore = nil;
        stepsSampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        cyclingSampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
        sleepSampleType = [HKSampleType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:YES];
        if (NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable])
        {
            healthStore = [[HKHealthStore alloc] init];
            NSSet *readObjectTypes  = [NSSet setWithObjects:
                                       [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis],
                                       [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling],
                                       [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                                       nil];
            [healthStore requestAuthorizationToShareTypes:nil
                                                readTypes:readObjectTypes
                                               completion:^(BOOL success, NSError *error) {
                                                   if (success == YES)
                                                   {
                                                       // ...
                                                   } else {
                                                       // Determine if it was an error or if the
                                                       // user just canceled the authorization request
                                                   }
                                               }];
        }
        return self;
    } else {
        return nil;
    }
}


// Needed
- (void) executeStepsQuery:(NSPredicate *)predicate {
    stepsQuery = [[HKSampleQuery alloc] initWithSampleType:stepsSampleType
                                                 predicate:predicate
                                                     limit:HKObjectQueryNoLimit
                                           sortDescriptors:@[sortDescriptor]
                                            resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                @synchronized(self) {
                                                    if (!error && results)
                                                    {
                                                        for (HKQuantitySample *sample in results)
                                                        {
                                                            ActivityDataItem *item = [[ActivityDataItem alloc] init];
                                                            item.dateStart = [sample startDate];
                                                            item.dateEnd = [sample endDate];
                                                            item.type = @"steps";
                                                            item.amount = [NSNumber numberWithDouble:
                                                                           [[sample quantity] doubleValueForUnit:[HKUnit unitFromString:@"count"]]];
                                                            [activitySet insertItem:item];
                                                        }
                                                        [activitySet coalesce];
                                                        [self willChangeValueForKey:@"activitySet"];
                                                        [self didChangeValueForKey:@"activitySet"];
                                                    }
                                                }
                                                
                                            }];
    [healthStore executeQuery:stepsQuery];
    NSLog(@"%@", stepsQuery);
}

- (void) executeCyclingQuery:(NSPredicate *)predicate {
    cyclingQuery = [[HKSampleQuery alloc] initWithSampleType:cyclingSampleType
                                            predicate:predicate
                                                limit:HKObjectQueryNoLimit
                                      sortDescriptors:@[sortDescriptor]
                                       resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                           @synchronized(self) {
                                               if (!error && results)
                                               {
                                                   for (HKQuantitySample *sample in results)
                                                   {
                                                       ActivityDataItem *item = [[ActivityDataItem alloc] init];
                                                       item.dateStart = [sample startDate];
                                                       item.dateEnd = [sample endDate];
                                                       item.type = @"bike";
                                                       item.amount = [NSNumber numberWithDouble:
                                                                      [[sample quantity] doubleValueForUnit:[HKUnit unitFromString:@"mi"]]];
                                                       [activitySet insertItem:item];
                                                   }
                                                   [activitySet coalesce];
                                                   [self willChangeValueForKey:@"activitySet"];
                                                   [self didChangeValueForKey:@"activitySet"];
                                               }
                                           }
                                       }];
    [healthStore executeQuery:cyclingQuery];
    NSLog(@"%@", cyclingQuery);
}

- (void) executeSleepQuery:(NSPredicate *)predicate {
    sleepQuery = [[HKSampleQuery alloc] initWithSampleType:sleepSampleType
                                                 predicate:predicate
                                                     limit:HKObjectQueryNoLimit
                                           sortDescriptors:@[sortDescriptor]
                                            resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                @synchronized(self) {
                                                    if (!error && results)
                                                    {
                                                        for (HKCategorySample *sample in results)
                                                        {
                                                            if (sample.value == HKCategoryValueSleepAnalysisAsleep) {
                                                                ActivityDataItem *item = [[ActivityDataItem alloc] init];
                                                                item.dateStart = [sample startDate];
                                                                item.dateEnd = [sample endDate];
                                                                item.type = @"sleep";
                                                                item.amount = [NSNumber numberWithDouble:
                                                                               [self hoursBetween:item.dateStart and:item.dateEnd]];
                                                                [activitySet insertItem:item];
                                                            }
                                                        }
                                                        [activitySet coalesce];
                                                        [self willChangeValueForKey:@"activitySet"];
                                                        [self didChangeValueForKey:@"activitySet"];
                                                    }
                                                }
                                            }];
    [healthStore executeQuery:sleepQuery];
    NSLog(@"%@", sleepQuery);
}

- (void) aquireStartingFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    @synchronized(self) {
        if (healthStore == nil) {
            [NSException raise:@"HealthStore is invalid." format:@"HealthStore has not been created."];
        }
        
        [healthStore stopQuery:stepsQuery];
        [healthStore stopQuery:cyclingQuery];
        [healthStore stopQuery:sleepQuery];
        [activitySet clear];
        
        NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:fromDate
                                                                   endDate:toDate
                                                                   options:HKQueryOptionStrictStartDate];
        [self executeStepsQuery:predicate];
        [self executeCyclingQuery:predicate];
        [self executeSleepQuery:predicate];
    }
}

// TODO: move to common code location
- (NSDateComponents *) dayAfter {
    NSDateComponents *oneDay = [[NSDateComponents alloc] init];
    oneDay.day = 1;
    return oneDay;
}

- (void) aquireStartingFromDateString:(NSString *)fromDate toDateString:(NSString *)toDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    NSDate *dateFromDate = [dateFormatter dateFromString:fromDate];
    NSDate *dateToDate = [dateFormatter dateFromString:toDate];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.firstWeekday = 1; // Sunday = 1, Monday = 2, ..., Saturday = 7
    calendar.timeZone = [NSTimeZone localTimeZone];
    dateToDate = [calendar dateByAddingComponents:[self dayAfter] toDate:dateToDate options:0];
    
    [self aquireStartingFromDate:dateFromDate toDate:dateToDate];
}

- (double) hoursBetween:(NSDate *)startDate and:(NSDate *)endDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.firstWeekday = 1; // Sunday = 1, Monday = 2, ..., Saturday = 7
    calendar.timeZone = [NSTimeZone localTimeZone];
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute fromDate:startDate toDate:endDate options:0];
    return ((double)components.minute / 60.0);
}

- (ActivityDataSet *) getActivitySet {
    return activitySet;
}

@end
