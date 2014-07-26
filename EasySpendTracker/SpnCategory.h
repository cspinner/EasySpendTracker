//
//  SpnCategory.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "SpnCategoryMO.h"

@interface SpnCategory : SpnCategoryMO

+ (SpnCategory*)fetchCategoryWithName:(NSString*)categoryName inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
