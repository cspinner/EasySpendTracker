//
//  spnLoadPieChartDataOp.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/24/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface spnPieChartProcessDataOp : NSOperation

@property NSPersistentStoreCoordinator* persistentStoreCoordinator;

@property NSArray* transactionIDs;
@property NSString* keyPath;
@property NSPredicate* predicate; // optional additional filtering of the fetched transactions

@property (copy) void (^dataReturnBlock) (NSMutableArray* pieChartValues, NSMutableArray* pieChartNames);

@end
