//
//  WeatherDataCollector.m
//  HealthTrendFinder
//
//  Created by Cameron on 5/31/15.
//  Copyright (c) 2015 Cameron. All rights reserved.
//

#import "WeatherDataCollector.h"

@interface WeatherDataCollector () {
    ActivityDataSet *activitySet;
}

@end

@implementation WeatherDataCollector

- (void) aquireStartingFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    self->activitySet = [[ActivityDataSet alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        @synchronized(self) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"portland_weather_data.json" ofType:nil];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"JSON data size: %u", (unsigned int)jsonData.count);
            
            for (NSDictionary *item in jsonData) {
                ActivityDataItem *tempLow = [[ActivityDataItem alloc] initWithType:@"temp_low" startDateString:item[@"date"] endDateString:item[@"date"] amount:[item[@"temp_low"] floatValue]];
                [self->activitySet insertItem:tempLow];
                ActivityDataItem *tempHigh = [[ActivityDataItem alloc] initWithType:@"temp_high" startDateString:item[@"date"] endDateString:item[@"date"] amount:[item[@"temp_high"] floatValue]];
                [self->activitySet insertItem:tempHigh];
                ActivityDataItem *precip = [[ActivityDataItem alloc] initWithType:@"precip" startDateString:item[@"date"] endDateString:item[@"date"] amount:[item[@"precip"] floatValue]];
                [self->activitySet insertItem:precip];
            }
            [self->activitySet removeItemsBeforeDate:fromDate];
            [self->activitySet removeItemsAfterDate:toDate];
            [self willChangeValueForKey:@"activitySet"];
            [self didChangeValueForKey:@"activitySet"];
        }
    });
}

- (void) aquireStartingFromDateString:(NSString *)fromDate toDateString:(NSString *)toDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    NSDate *dateFromDate = [dateFormatter dateFromString:fromDate];
    NSDate *dateToDate = [dateFormatter dateFromString:toDate];
    [self aquireStartingFromDate:dateFromDate toDate:dateToDate];
}

- (ActivityDataSet *) getActivitySet {
    return self->activitySet;
}

@end
