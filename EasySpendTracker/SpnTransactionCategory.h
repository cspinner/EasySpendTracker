//
//  SpnTransactionCategory.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "SpnTransactionCategoryMO.h"

@interface SpnTransactionCategory : SpnTransactionCategoryMO

+ (SpnTransactionCategory*)fetchCategoryWithName:(NSString*)categoryName inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
