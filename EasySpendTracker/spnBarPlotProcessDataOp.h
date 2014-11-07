//
//  spnBarPlotProcessDataOp.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/26/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface spnBarPlotProcessDataOp : NSOperation

@property NSPersistentStoreCoordinator* persistentStoreCoordinator;

@property NSArray* transactionIDs;
//@property NSString* keyPath;
//@property NSPredicate* predicate; // optional additional filtering of the fetched transactions

@property (copy) void (^dataReturnBlock) (NSMutableArray* barPlotValues, NSMutableArray* barPlotMonths);

@end
