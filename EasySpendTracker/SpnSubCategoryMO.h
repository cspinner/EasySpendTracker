//
//  SpnSubCategoryMO.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/26/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SpnCategoryMO, SpnTransactionMO;

@interface SpnSubCategoryMO : NSManagedObject

@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *transactions;
@property (nonatomic, retain) SpnCategoryMO *category;
@end

@interface SpnSubCategoryMO (CoreDataGeneratedAccessors)

- (void)addTransactionsObject:(SpnTransactionMO *)value;
- (void)removeTransactionsObject:(SpnTransactionMO *)value;
- (void)addTransactions:(NSSet *)values;
- (void)removeTransactions:(NSSet *)values;

@end
