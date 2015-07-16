//
//  ActivityDataCollectorProtocol.h
//  HealthTrendFinder
//
//  Created by Cameron on 5/17/15.
//  Copyright (c) 2015 Cameron. All rights reserved.
//

#import "ActivityDataSet.h"

@interface ActivityDataCollector : NSObject
- (void) aquireStartingFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (void) aquireStartingFromDateString:(NSString *)fromDate toDateString:(NSString *)toDate;
- (ActivityDataSet *) getActivitySet;
@end