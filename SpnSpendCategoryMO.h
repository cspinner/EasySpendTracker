//
//  SpnSpendCategoryMO.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SpnTransaction;

@interface SpnSpendCategoryMO : NSManagedObject

@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSSet *transactions;
@end

@interface SpnSpendCategoryMO (CoreDataGeneratedAccessors)

- (void)addTransactionsObject:(SpnTransaction *)value;
- (void)removeTransactionsObject:(SpnTransaction *)value;
- (void)addTransactions:(NSSet *)values;
- (void)removeTransactions:(NSSet *)values;

@end
