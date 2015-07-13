//
//  ActivityDataSet.m
//  HealthTrendFinder
//
//  Created by Cameron on 5/17/15.
//  Copyright (c) 2015 Cameron. All rights reserved.
//

#import "ActivityDataSet.h"
#import "ActivityDataItem.h"

@interface ActivityDataSet () {
    NSMutableArray *activityItems;
}

@end

@implementation ActivityDataSet

- (id)init {
    if (self = [super init]) {
        activityItems = [NSMutableArray array];
        return self;
    } else {
        return nil;
    }
}

-(id)copyWithZone:(NSZone *)zone
{
    @synchronized(self) {
        ActivityDataSet *another = [[ActivityDataSet alloc] init];
        another->activityItems = [NSMutableArray array];
        for (ActivityDataItem *item in [self getActivityItems]) {
            [another->activityItems addObject:[item copy]];
        }
        return another;
    }
}

- (void)insertItem:(ActivityDataItem*)item {
    @synchronized(self) {
        [activityItems addObject:item];
    }
}

- (void) appendSet:(ActivityDataSet *)set {
    @synchronized(self) {
        [activityItems addObjectsFromArray: [set getActivityItems]];
    }
}

- (void) coalesce {
    @synchronized(self) {
        NSDateFormatter *dateFormatter = [self getDateFormatter];
        NSMutableSet *excludeList = [NSMutableSet set];
        for (NSUInteger currIndex = 0; currIndex < [self count]; currIndex++) {
            if (![excludeList containsObject:[NSNumber numberWithUnsignedInteger:currIndex]]) { // check this
                ActivityDataItem *currItem = [self getItemAtIndex:currIndex];
                NSString *currDateString = [dateFormatter stringFromDate:currItem.dateEnd];
                for (NSUInteger index = 0; index < [self count]; index++) {
                    if (index != currIndex) {
                        ActivityDataItem *item = [self getItemAtIndex:index];
                        NSString *dateString = [dateFormatter stringFromDate:item.dateEnd];
                        if ([currDateString isEqualToString:dateString] &&
                            [currItem.type isEqualToString:item.type]) {
                            double newValue = [currItem.amount doubleValue] + [item.amount doubleValue];
                            currItem.amount = [NSNumber numberWithDouble:newValue];
                            [excludeList addObject:[NSNumber numberWithUnsignedInteger:index]];
                        }
                    }
                }
            }
        }

        ActivityDataSet *set = [[ActivityDataSet alloc] init];
        if ([self count] > 0) {
            for (NSUInteger currIndex = 0; currIndex < [self count]; currIndex++) {
                if (![excludeList containsObject:[NSNumber numberWithUnsignedInteger:currIndex]]) {
                    [set insertItem:[self getItemAtIndex:currIndex]];
                }
            }
        }
        self->activityItems = set->activityItems;
    }
}

- (NSMutableArray *) getActivityItems {
    @synchronized(self) {
        return self->activityItems;
    }
}

- (ActivityDataItem*) getItemAtIndex:(NSUInteger)index {
    @synchronized(self) {
        return [activityItems objectAtIndex:index];
    }
}

- (NSUInteger)count {
    @synchronized(self) {
        return [activityItems count];
    }
}

- (void) clear {
    @synchronized(self) {
        [activityItems removeAllObjects];
    }
}

- (NSNumber *) sumAmountsForActivity:(NSString *)activity {
    @synchronized(self) {
        double sum = 0.0;
        for (ActivityDataItem* item in [self getActivityItems]) {
            if ([item.type isEqualToString:activity]) {
                sum += [item.amount doubleValue];
            }
        }
        return [NSNumber numberWithDouble:sum];
    }
}

- (NSNumber *) sumAmountsForActivity:(NSString *)activity duringWeekNumber:(NSUInteger)week {
    @synchronized(self) {
        double sum = 0.0;
        for (ActivityDataItem* item in [self getActivityItems]) {
            NSUInteger itemWeek = [self calculateWeekOfYearFromDate:item.dateEnd];
            if (([item.type isEqualToString:activity]) && (itemWeek == week)) {
                sum += [item.amount doubleValue];
            }
        }
        return [NSNumber numberWithDouble:sum];
    }
}

- (NSNumber *) averageForActivity:(NSString *)activity {
    @synchronized(self) {
        double sum = 0.0;
        double count = 0.0;
        for (ActivityDataItem* item in [self getActivityItems]) {
            if ([item.type isEqualToString:activity]) {
                sum += [item.amount doubleValue];
                count += 1;
            }
        }
        return [NSNumber numberWithDouble:(sum / count)];
    }
}

- (NSNumber *) minimumForActivity:(NSString *)activity {
    @synchronized(self) {
        double min = 0.0;
        bool minValid = false;
        for (ActivityDataItem* item in [self getActivityItems]) {
            if ([item.type isEqualToString:activity]) {
                if (minValid == false) {
                    min = [item.amount doubleValue];
                    minValid = true;
                } else {
                    if ([item.amount doubleValue] < min) {
                        min = [item.amount doubleValue];
                    }
                }
            }
        }
        return [NSNumber numberWithDouble:min];
    }
}

- (NSNumber *) maximumForActivity:(NSString *)activity {
    @synchronized(self) {
        double max = 0.0;
        bool maxValid = false;
        for (ActivityDataItem* item in [self getActivityItems]) {
            if ([item.type isEqualToString:activity]) {
                if (maxValid == false) {
                    max = [item.amount doubleValue];
                    maxValid = true;
                } else {
                    if ([item.amount doubleValue] > max) {
                        max = [item.amount doubleValue];
                    }
                }
            }
        }
        return [NSNumber numberWithDouble:max];
    }
}

- (void)removeItemsBeforeDate:(NSDate *)date {
    @synchronized(self) {
        // TODO: look at filteredArrayUsingPredicate:<#(NSPredicate *)#>
        NSMutableArray *itemsToKeep = [NSMutableArray array];
        for (ActivityDataItem* item in [self getActivityItems]) {
            if ([item endsOnOrAfterDate:date] == YES) {
                [itemsToKeep addObject:item];
            }
        }
        activityItems = itemsToKeep;
    }
}

- (void)removeItemsBeforeDateString:(NSString *)dateString {
    @synchronized(self) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        NSDate *date = [dateFormatter dateFromString:dateString];
        return [self removeItemsBeforeDate:date];
    }
}

- (void) removeItemsAfterDate:(NSDate *)date {
    @synchronized(self) {
        // TODO: look at filteredArrayUsingPredicate:<#(NSPredicate *)#>
        NSMutableArray *itemsToKeep = [NSMutableArray array];
        for (ActivityDataItem* item in [self getActivityItems]) {
            if ([item endsOnOrBeforeDate:date] == YES) {
                [itemsToKeep addObject:item];
            }
        }
        activityItems = itemsToKeep;
    }
}

- (void) removeItemsAfterDateString:(NSString *)dateString {
    @synchronized(self) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        NSDate *date = [dateFormatter dateFromString:dateString];
        return [self removeItemsAfterDate:date];
    }
}

- (NSSet *) uniqueDatesForActivity:(NSString *)activity withThreshold:(NSNumber *)threshold {
    @synchronized(self) {
        NSMutableSet * set = [NSMutableSet set];
        NSDateFormatter *dateFormatter = [self getDateFormatter];
        for (NSUInteger index = 0; index < [self count]; index++) {
            ActivityDataItem* item = [self getItemAtIndex:index];
            if ([item.type isEqualToString:activity] &&
                ([item.amount doubleValue] >= [threshold doubleValue])) {
                NSString *dateString = [dateFormatter stringFromDate:item.dateEnd];
                [set addObject:dateString];
            }
        }
        return set;
    }
}

// TODO: move to common code location
- (NSDateComponents *) dayAfter {
    NSDateComponents *oneDay = [[NSDateComponents alloc] init];
    oneDay.day = 1;
    return oneDay;
}

// TODO: move to common code location
- (NSDateComponents *) dayBefore {
    NSDateComponents *oneDay = [[NSDateComponents alloc] init];
    oneDay.day = -1;
    return oneDay;
}

// TODO: move to common code location
- (NSUInteger) calculateWeekOfYearFromDate:(NSDate*)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.firstWeekday = 1; // Sunday = 1, Monday = 2, ..., Saturday = 7
    calendar.timeZone = [NSTimeZone localTimeZone];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekOfYear fromDate:date];
    return [components weekOfYear];
}

- (NSArray *) asArray {
    @synchronized(self) {
        return self->activityItems;
    }
}

- (ActivityDataSet *) filterItems:(ActivityDataSet *)items onDate:(NSDate *)date {
    @synchronized(self) {
        ActivityDataSet *filteredItems = [[ActivityDataSet alloc] init];
        for (ActivityDataItem* item in [items asArray]) {
            if ([item endsOnSameDayAs:date]) {
                [filteredItems insertItem:item];
            }
        }
        return filteredItems;
    }
}

- (ActivityDataSet *) getItemsForActivity:(NSString *)activity {
    @synchronized(self) {
        ActivityDataSet *set = [[ActivityDataSet alloc] init];
        for (NSUInteger index = 0; index < [self count]; index++) {
            ActivityDataItem* item = [self getItemAtIndex:index];
            if ([item.type isEqualToString:activity]) {
                [set insertItem:item];
            }
        }
        return set;
    }
}

- (ActivityDataSet *) getItemsForActivity:(NSString *)activity onDayBefore:(NSString *)dateString {
    @synchronized(self) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        calendar.firstWeekday = 1; // Sunday = 1, Monday = 2, ..., Saturday = 7
        calendar.timeZone = [NSTimeZone localTimeZone];
        NSDate *dateBefore = [[self getDateFormatter] dateFromString:dateString];
        dateBefore = [calendar dateByAddingComponents:[self dayBefore] toDate:dateBefore options:0];
        
        ActivityDataSet *items = [self getItemsForActivity:activity];
        ActivityDataSet *filteredItems = [self filterItems:items onDate:dateBefore];
        return filteredItems;
    }
}

- (ActivityDataSet *) getItemsForActivity:(NSString *)activity onDayOf:(NSString *)dateString {
    @synchronized(self) {
        NSDate *dateOf = [[self getDateFormatter] dateFromString:dateString];
        
        ActivityDataSet *items = [self getItemsForActivity:activity];
        ActivityDataSet *filteredItems = [self filterItems:items onDate:dateOf];
        return filteredItems;
    }
}

- (ActivityDataSet *) getItemsForActivity:(NSString *)activity onDayAfter:(NSString *)dateString {
    @synchronized(self) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        calendar.firstWeekday = 1; // Sunday = 1, Monday = 2, ..., Saturday = 7
        calendar.timeZone = [NSTimeZone localTimeZone];
        NSDate *dateAfter = [[self getDateFormatter] dateFromString:dateString];
        dateAfter = [calendar dateByAddingComponents:[self dayAfter] toDate:dateAfter options:0];
        
        ActivityDataSet *items = [self getItemsForActivity:activity];
        ActivityDataSet *filteredItems = [self filterItems:items onDate:dateAfter];
        return filteredItems;
    }
}

- (NSDateFormatter *) getDateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    return dateFormatter;
}

@end
