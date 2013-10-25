//
//  SpnMonth.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "SpnMonthMO.h"

@class SpnSpendCategory;

@interface SpnMonth : SpnMonthMO

+ (SpnMonth*)fetchMonthWithDate:(NSDate*)date inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
- (SpnSpendCategory*)fetchCategoryWithName:(NSString*)categoryName;

@end
