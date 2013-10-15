//
//  SpnSpendCategory.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/10/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SpnMonth, SpnTransaction;

@interface SpnSpendCategory : NSManagedObject

@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSSet *transactions;
@property (nonatomic, retain) SpnMonth *month;
@end

@interface SpnSpendCategory (CoreDataGeneratedAccessors)

- (void)addTransactionsObject:(SpnTransaction *)value;
- (void)removeTransactionsObject:(SpnTransaction *)value;
- (void)addTransactions:(NSSet *)values;
- (void)removeTransactions:(NSSet *)values;

@end
