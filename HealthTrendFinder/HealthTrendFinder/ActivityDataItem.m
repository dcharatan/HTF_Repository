//
//  ActivityDataItem.m
//  HealthTrendFinder
//
//  Created by Cameron on 5/17/15.
//  Copyright (c) 2015 Cameron. All rights reserved.
//

#import "ActivityDataItem.h"

@implementation ActivityDataItem

// TODO: move to common code location
- (NSDateFormatter *) getDateFormatterYearFirst {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    return dateFormatter;
}

- (NSDateFormatter *) getDateFormatterYearLast {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    return dateFormatter;
}

- (id)initWithType:(NSString*)type startDate:(NSDate*)start endDate:(NSDate*)end amount:(NSNumber*)amount {
    if (self = [super init]) {
        self.type = type;
        self.dateStart = start;
        self.dateEnd = end;
        self.amount = amount;
        return self;
    } else {
        return nil;
    }
}

- (id)initWithType:(NSString *)type startDateString:(NSString *)start endDateString:(NSString *)end amount:(float)amount {
    if (self = [super init]) {
        NSDateFormatter *dateFormatter = [self getDateFormatterYearFirst];
        if ([dateFormatter dateFromString:start] == nil) {
            dateFormatter = [self getDateFormatterYearLast];
        }
        self.type = type;
        self.dateStart = [dateFormatter dateFromString:start];
        self.dateEnd = [dateFormatter dateFromString:end];
        self.amount = [[NSNumber alloc] initWithFloat:amount];
        return self;
    } else {
        return nil;
    }
}

- (BOOL) endsOnOrAfterDate:(NSDate*)date {
    NSComparisonResult result = [self.dateEnd compare:date];
    if ((result == NSOrderedSame) || (result == NSOrderedDescending)) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) endsOnOrBeforeDate:(NSDate*)date {
    NSComparisonResult result = [self.dateEnd compare:date];
    if ((result == NSOrderedSame) || (result == NSOrderedAscending)) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) endsOnSameDayAs:(NSDate*)date {
    NSDateFormatter *dateFormatter = [self getDateFormatterYearFirst];
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSString *startDateString = [dateFormatter stringFromDate:self.dateEnd];
    NSComparisonResult result = [dateString compare:startDateString];
    if (result == NSOrderedSame) {
        return YES;
    } else {
        return NO;
    }
}

- (id) copyWithZone:(NSZone *)zone {
    ActivityDataItem *another = [[ActivityDataItem alloc] init];
    another.type = [[NSString alloc] initWithString:self.type];
    another.dateStart = [self.dateStart copy];
    another.dateEnd = [self.dateEnd copy];
    another.amount = [self.amount copy];
    return another;
}

@end
