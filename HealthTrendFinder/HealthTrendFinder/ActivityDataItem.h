//
//  ActivityDataItem.h
//  HealthTrendFinder
//
//  Created by Cameron on 5/17/15.
//  Copyright (c) 2015 Cameron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityDataItem : NSObject <NSCopying>
@property NSString *type;
@property NSDate *dateStart;
@property NSDate *dateEnd;
@property NSNumber *amount;
- (id)initWithType:(NSString *)type startDate:(NSDate*)start endDate:(NSDate*)end amount:(NSNumber*)amount;
- (id)initWithType:(NSString *)type startDateString:(NSString *)start endDateString:(NSString *)end amount:(float)amount;
- (BOOL) endsOnOrAfterDate:(NSDate*)date;
- (BOOL) endsOnOrBeforeDate:(NSDate*)date;
- (BOOL) endsOnSameDayAs:(NSDate*)date;
- (id) copyWithZone:(NSZone *)zone;
@end
