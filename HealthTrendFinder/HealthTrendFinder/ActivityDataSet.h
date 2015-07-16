//
//  ActivityDataSet.h
//  HealthTrendFinder
//
//  Created by Cameron on 5/17/15.
//  Copyright (c) 2015 Cameron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivityDataItem.h"

@interface ActivityDataSet : NSObject <NSCopying>
- (void) insertItem:(ActivityDataItem*)item;
- (void) appendSet:(ActivityDataSet *)set;
- (void) coalesce;
- (void) clear;
- (ActivityDataItem*) getItemAtIndex:(NSUInteger)index;
- (NSUInteger) count;
- (NSNumber *) sumAmountsForActivity:(NSString *)activity;
- (NSNumber *) sumAmountsForActivity:(NSString *)activity duringWeekNumber:(NSUInteger)week;
- (NSNumber *) averageForActivity:(NSString *)activity;
- (NSNumber *) minimumForActivity:(NSString *)activity;
- (NSNumber *) maximumForActivity:(NSString *)activity;
- (void) removeItemsBeforeDate:(NSDate *)date;
- (void) removeItemsBeforeDateString:(NSString *)dateString;
- (void) removeItemsAfterDate:(NSDate *)date;
- (void) removeItemsAfterDateString:(NSString *)dateString;
- (id) copyWithZone:(NSZone *)zone;
- (NSSet *) uniqueDatesForActivity:(NSString *)activity withThreshold:(NSNumber *)threshold;
- (ActivityDataSet *) getItemsForActivity:(NSString *)activity;
- (ActivityDataSet *) getItemsForActivity:(NSString *)activity onDayBefore:(NSString *)dateString;
- (ActivityDataSet *) getItemsForActivity:(NSString *)activity onDayOf:(NSString *)dateString;
- (ActivityDataSet *) getItemsForActivity:(NSString *)activity onDayAfter:(NSString *)dateString;
@end
