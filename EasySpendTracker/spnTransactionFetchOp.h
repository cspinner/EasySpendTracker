//
//  spnTransactionFetchOp.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/23/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface spnTransactionFetchOp : NSOperation

@property NSPersistentStoreCoordinator* persistentStoreCoordinator;

@property NSDate* startDate;
@property NSDate* endDate;
@property NSArray* excludeCategories; // exclude transactions from these categories - nil to disable
@property NSArray* includeCategories; // includes transactions from these categories only - nil to disable
@property NSArray* includeSubCategories; // includes transactions from these subcategories only - nil to disable

@property (copy) void (^dataReturnBlock) (NSMutableArray* objectIDs, NSError *error);

@end
