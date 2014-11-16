//
//  SpnRecurrence.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 6/16/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "SpnRecurrence.h"
#import "SpnTransaction.h"
#import "NSDate+Convenience.h"

@implementation SpnRecurrence

static int rootTransactionObservanceContext;

- (void) awakeFromInsert
{
    // Called when this object is inserted into the managed object context.
    
    [super awakeFromInsert];
    
    // Monitor changes to the root transaction
    [self addObserver:self forKeyPath:@"rootTransaction" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&rootTransactionObservanceContext];
}

- (void) awakeFromFetch
{
    // Called when this category is fetched from the memory store.
    
    [super awakeFromFetch];
    
    // Monitor changes to the root transaction
    [self addObserver:self forKeyPath:@"rootTransaction" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&rootTransactionObservanceContext];
}

- (void) willTurnIntoFault
{
    // Called when this category is being sent to the store
    [super willTurnIntoFault];
    
    // Remove all observances this instance has
    [self removeObserver:self forKeyPath:@"rootTransaction" context:&rootTransactionObservanceContext];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((context == &rootTransactionObservanceContext) && (self.isDeleted == false))
    {
        //        NSString *const NSKeyValueChangeKindKey;
        //        NSString *const NSKeyValueChangeNewKey;
        //        NSString *const NSKeyValueChangeOldKey;
        //        NSString *const NSKeyValueChangeIndexesKey;
        //        NSString *const NSKeyValueChangeNotificationIsPriorKey;
        
        switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
        {
                //            case NSKeyValueChangeSetting:
                //            {
                //                NSNumber* oldNumber = [change objectForKey:NSKeyValueChangeOldKey];
                //                NSNumber* newNumber = [change objectForKey:NSKeyValueChangeNewKey];
                //                [self setTotal:[NSNumber numberWithFloat:[self.total floatValue] - [oldNumber floatValue]]];
                //                [self setTotal:[NSNumber numberWithFloat:[self.total floatValue] + [newNumber floatValue]]];
                //            }
                //                break;
            case NSKeyValueChangeSetting:
            {
                // rootTransaction was set to nil (it was probably deleted)
                if ([change objectForKey:NSKeyValueChangeNewKey] == nil ||
                    [change objectForKey:NSKeyValueChangeNewKey] == (id)[NSNull null])
                {
                    // Remove this object if there are no other transactions associated with it
                    if (self.transactions.count == 0)
                    {
                        [self.managedObjectContext deleteObject:self];
//                        NSLog(@"Deleting recurrence");
                    }
                    else
                    {
                        // Need new root transaction. Just find the latest one in the set
                        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
                        
                        // Sorted by date
                        NSArray* sortedTransactions = [self.transactions sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
                        
                        // Pick the first one (most recent date)
                        self.rootTransaction = sortedTransactions[0];
//                        NSLog(@"Root transaction: %@", self.rootTransaction.sectionName);
                    }
                }
                
            }
                break;
                
            case NSKeyValueChangeRemoval:
            case NSKeyValueChangeInsertion:
            case NSKeyValueChangeReplacement:
            default:
                break;
        }
    }
}

- (void) setRecurrenceForTransaction:(SpnTransaction*)transaction withFrequency:(NSDateComponents*)frequency withAction:(SpnRecurrenceActionType)action
{
    // Call subroutine depending on the action
    switch (action)
    {
        case RECUR_ACTION_CREATE:
            [self createSeriesWithTransaction:transaction withFrequency:frequency];
            break;
            
        case RECUR_ACTION_UPDATE_ALL:
            [self updateAllTransactionsInSeriesWith:transaction];
            break;
            
        case RECUR_ACTION_UPDATE_FUTURE:
            [self updateFutureTransactionsInSeriesWith:transaction];
            break;
            
        case RECUR_ACTION_UPDATE_ONE:
            [self updateOneTransactionInSeries:transaction];
            break;
            
        case RECUR_ACTION_DELETE_ALL:
            [self deleteAllTransactionsInSeries];
            break;
            
        case RECUR_ACTION_DELETE_FUTURE:
            [self deleteFutureTransactionsInSeriesStartingWith:transaction];
            break;
            
        case RECUR_ACTION_DELETE_ONE:
            [self deleteOneTransactionInSeries:transaction];
            break;
            
        case RECUR_ACTION_NONE:         // No action
        default:
            break;
    }
}

- (void) createSeriesWithTransaction:(SpnTransaction*)transaction withFrequency:(NSDateComponents*)frequency
{
    self.frequency = frequency;
    
    // Update the root transaction
    self.rootTransaction = transaction;
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    // Create first interval date:
    // add this transaction to the set of transactions for this recurrence
    [self addTransactionsObject:transaction];
    
    self.nextDate = [calendar dateByAddingComponents:self.frequency toDate:transaction.date options:0];
    
    // Copy the transaction through the next year
    [self extendSeries];
}

- (void) updateAllTransactionsInSeriesWith:(SpnTransaction*)transaction
{
    // Update all transactions related to this recurrence
    for (SpnTransaction* seriesTransaction in self.transactions)
    {
        [seriesTransaction setMerchant:transaction.merchant];
        [seriesTransaction setNotes:transaction.notes];
        [seriesTransaction setValue:transaction.value];
        [seriesTransaction setSubCategory:transaction.subCategory];
    }
    
    // Update the root transaction
    self.rootTransaction = transaction;
}

- (void) updateFutureTransactionsInSeriesWith:(SpnTransaction*)transaction
{
    // Look for transactions at the same date to or later than this one
    NSPredicate* datePredicate = [NSPredicate predicateWithFormat:@"date >= %@", transaction.date];
    NSSet* filteredTransactions = [self.transactions filteredSetUsingPredicate:datePredicate];
    
    // Update the filtered transactions
    for (SpnTransaction* seriesTransaction in filteredTransactions)
    {
        [seriesTransaction setMerchant:transaction.merchant];
        [seriesTransaction setNotes:transaction.notes];
        [seriesTransaction setValue:transaction.value];
        [seriesTransaction setSubCategory:transaction.subCategory];
    }
    
    // Update the root transaction
    self.rootTransaction = transaction;
}

- (void) updateOneTransactionInSeries:(SpnTransaction*)transaction
{
}

- (void) deleteAllTransactionsInSeries
{
    // delete the recurrence itself
    [self.managedObjectContext deleteObject:self];
    
    // delete all transactions associated with the recurrence.
    for (SpnTransaction* transaction in self.transactions)
    {
        [self.managedObjectContext deleteObject:transaction];
    }
}

- (void) deleteFutureTransactionsInSeriesStartingWith:(SpnTransaction*)transaction
{
    // Look for transactions at the same date to or later than this one
    NSPredicate* datePredicate = [NSPredicate predicateWithFormat:@"date >= %@", transaction.date];
    NSSet* filteredTransactions = [self.transactions filteredSetUsingPredicate:datePredicate];

    // delete the recurrence. Note the previous transactions will remain
    [self.managedObjectContext deleteObject:self];
//    NSLog(@"Deleting recurrence");
    
    // delete future transactions (including the one specified) associated with the recurrence.
    for (SpnTransaction* transaction in filteredTransactions)
    {
        [self.managedObjectContext deleteObject:transaction];
    }
}

- (void) deleteOneTransactionInSeries:(SpnTransaction*)transaction
{
    // just delete the transaction
    [self.managedObjectContext deleteObject:transaction];
}

- (void) extendSeries
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    // Continue to create recurring transactions based on the root transaction for the next year - TBD this comparison is subsecond granularity, check manual for options
    while([[[NSDate date] offsetYear:1] compare:self.nextDate] == NSOrderedDescending)
    {
        // copy the root transaction
        SpnTransaction* copiedTransaction = [self.rootTransaction clone];
        [copiedTransaction setDate:self.nextDate];
        
        // finally, add it to the set of transactions for this recurrence
        [self addTransactionsObject:copiedTransaction];
        
        // Create next interval date
        self.nextDate = [calendar dateByAddingComponents:self.frequency toDate:copiedTransaction.date options:0];
    }
}

@end
