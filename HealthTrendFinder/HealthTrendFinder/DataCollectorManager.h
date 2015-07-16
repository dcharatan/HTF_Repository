//
//  DataCollectorManager.h
//  HealthTrendFinder
//
//  Created by Cameron on 6/1/15.
//  Copyright (c) 2015 Cameron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivityDataSet.h"

@interface DataCollectorManager : NSObject

+ (id) instance;
- (void) registerForNotifications:(id)object;
- (void) unregisterForNotifications:(id)object;
- (ActivityDataSet*) getActivityData;
@end
