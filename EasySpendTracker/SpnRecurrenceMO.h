//
//  SpnRecurrenceMO.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/9/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SpnTransaction;

@interface SpnRecurrenceMO : NSManagedObject

@property (nonatomic, retain) id frequency;
@property (nonatomic, retain) SpnTransaction *rootTransaction;
@property (nonatomic, retain) NSSet *transactions;
@end

@interface SpnRecurrenceMO (CoreDataGeneratedAccessors)

- (void)addTransactionsObject:(SpnTransaction *)value;
- (void)removeTransactionsObject:(SpnTransaction *)value;
- (void)addTransactions:(NSSet *)values;
- (void)removeTransactions:(NSSet *)values;

@end
