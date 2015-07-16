//
//  DataCollectorManager.m
//  HealthTrendFinder
//
//  Created by Cameron on 6/1/15.
//  Copyright (c) 2015 Cameron. All rights reserved.
//

#import "DataCollectorManager.h"
#import "HealthKitDataCollector.h"
#import "WeatherDataCollector.h"

@interface DataCollectorManager () {
    HealthKitDataCollector *healthKit;
    WeatherDataCollector *weather;
}
@end

NSString *startDate = @"2015/04/19";
NSString *endDate = @"2015/05/23";

@implementation DataCollectorManager


+ (id) instance {
    static DataCollectorManager *instance = nil;
    @synchronized(self) {
        if (instance == nil)
            instance = [[self alloc] init];
    }
    return instance;
}

- (id) init {
    if (self = [super init]) {
        healthKit = [[HealthKitDataCollector alloc] init];
        [healthKit aquireStartingFromDateString:startDate toDateString:endDate];
        weather = [[WeatherDataCollector alloc] init];
        [weather aquireStartingFromDateString:startDate toDateString:endDate];
    }
    return self;
}

- (void) registerForNotifications:(id)object {
    @synchronized(self) {
        [healthKit addObserver:object
                    forKeyPath:@"activitySet"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
        [weather addObserver:object
                  forKeyPath:@"activitySet"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    }
}

- (void) unregisterForNotifications:(id)object {
    @synchronized(self) {
        @try {
            [healthKit removeObserver:object forKeyPath:@"activitySet"];
        }
        @catch (NSException *e) {
            // eat the error, don't care
        }
        
        @try {
            [weather removeObserver:object forKeyPath:@"activitySet"];
        }
        @catch (NSException *e) {
            // eat the error, don't care
        }
    }
}

- (ActivityDataSet*) getActivityData {
    @synchronized(self) {
        ActivityDataSet *data = [[healthKit getActivitySet] copy];
        [data appendSet:[weather getActivitySet]];
        return [data copy];
    }
}

@end
