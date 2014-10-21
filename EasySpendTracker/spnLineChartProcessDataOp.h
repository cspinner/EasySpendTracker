//
//  spnLineChartProcessDataOp.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/28/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface spnLineChartProcessDataOp : NSOperation

@property NSPersistentStoreCoordinator* persistentStoreCoordinator;

@property NSArray* transactionIDs;
//@property NSString* keyPath;
//@property NSPredicate* predicate; // optional additional filtering of the fetched transactions

@property (copy) void (^dataReturnBlock) (NSMutableArray* linePlotXYValues, NSMutableArray* linePlotXLabels);

@end
