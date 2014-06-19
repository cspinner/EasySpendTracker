//
//  SpnRecurrenceMO.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 6/16/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <EventKit/EventKit.h>

@class SpnTransaction;

@interface SpnRecurrenceMO : NSManagedObject

@property (nonatomic, retain) NSNumber* frequency;
@property (nonatomic, retain) NSSet *transaction;
@end

@interface SpnRecurrenceMO (CoreDataGeneratedAccessors)

- (void)addTransactionObject:(SpnTransaction *)value;
- (void)removeTransactionObject:(SpnTransaction *)value;
- (void)addTransaction:(NSSet *)values;
- (void)removeTransaction:(NSSet *)values;

@end
