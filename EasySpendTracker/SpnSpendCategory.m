//
//  SpnSpendCategory.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "SpnSpendCategory.h"
#import "SpnTransaction.h"

@implementation SpnSpendCategory

static int transactionsObservanceContext;
static int transactionValueObservanceContext;

+ (SpnSpendCategory*)fetchCategoryWithName:(NSString*)categoryName inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    NSError *error = nil;
    SpnSpendCategory* category = nil;
    
    // Find categories (but should only be one) matching the specified name
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SpnSpendCategoryMO"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title MATCHES[cd] %@)", categoryName];
    [fetchRequest setPredicate:predicate];
    
    NSMutableArray *mutableFetchResults = [[managedObjectContext                                                executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if (mutableFetchResults == nil)
    {
        // Error
    }
    else
    {
        // Target category was found
        if([mutableFetchResults count] != 0)
        {
            // set the return value - again, assumes only 1 match and so return the first in the array
            category = [mutableFetchResults objectAtIndex:0];
        }
        else
        {
            // Category not found - add a new one
            category = [[SpnSpendCategory alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnSpendCategoryMO" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
            
            // Perform additional initialization.
            [category setTotal:[NSNumber numberWithFloat:0.00]];
            [category setLastModifiedDate:[NSDate date]];
            [category setTitle:categoryName];
        }
    }
    
    return category;
}

- (void)awakeFromInsert
{
    // Called when this category is inserted into the managed object context.
    
    [super awakeFromInsert];
    
    // Monitor changes to the transactions set
    [self addObserver:self forKeyPath:@"transactions" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&transactionsObservanceContext];
}

- (void)awakeFromFetch
{
    // Called when this category is fetched from the memory store.
    
    [super awakeFromFetch];
    
    // Monitor changes to the transactions set
    [self addObserver:self forKeyPath:@"transactions" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&transactionsObservanceContext];
}

- (void)didTurnIntoFault
{
    // Called when this category is being sent to the store
    [super didTurnIntoFault];
    
    // Remove all observances this instance has
    [self removeObserver:self forKeyPath:@"transactions" context:&transactionsObservanceContext];
    
    for(SpnTransaction* transaction in self.transactions)
    {
        [transaction removeObserver:self forKeyPath:@"value" context:&transactionsObservanceContext];
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &transactionValueObservanceContext)
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
            case NSKeyValueChangeInsertion:
            case NSKeyValueChangeRemoval:
            case NSKeyValueChangeReplacement:
            default:
                break;
        }
        
        // Refresh category total
        [self setTotal:[self valueForKeyPath:@"transactions.@sum.value"]];
    }
    else if (context == &transactionsObservanceContext)
    {
        switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
        {
            case NSKeyValueChangeInsertion:
            {
                // Transaction is being inserted into the "transactions" set
                NSSet* transactions = [change objectForKey:NSKeyValueChangeNewKey];
                
                for(SpnTransaction* transaction in transactions)
                {
                    // Update category total
                    //[self setTotal:[NSNumber numberWithFloat:[self.total floatValue] + [transaction.value floatValue]]];
                    
                    // Register for notifications for changes to this transaction's value
                    [transaction addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&transactionValueObservanceContext];
                }
            }
                break;
                
            case NSKeyValueChangeRemoval:
            {
                // Transaction is being removed from the "transactions" set
                NSSet* transactions = [change objectForKey:NSKeyValueChangeOldKey];
                
                for(SpnTransaction* transaction in transactions)
                {
                    //[self setTotal:[NSNumber numberWithFloat:[self.total floatValue] - [transaction.value floatValue]]];
                    
                    // stop observing properties of this object since it's being deleted. Otherwise we will get back to back notifications.
                    @try
                    {
                        // TBD - in a try/catch because we sometimes lose track which category the transaction is attached to. Cannot remove observer from something that isn't being observer. 
                        [transaction removeObserver:self forKeyPath:@"value" context:&transactionValueObservanceContext];
                    }
                    @catch(id anException)
                    {
                        NSLog(@"Exception: %@", anException);
                    }
                    

                }
            }
                break;
                
            case NSKeyValueChangeSetting:
            {
                // "Transactions" set is being set (could be null)
                if(self.transactions != nil)
                {
                    NSSet* transactions = [change objectForKey:NSKeyValueChangeNewKey];
                    
                    // Need to redo observership for each transaction
                    for(SpnTransaction* transaction in transactions)
                    {
                        // Register for notifications for changes to this transaction's value
                        [transaction addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&transactionValueObservanceContext];
                    }
                }
            }
                break;
                
            case NSKeyValueChangeReplacement:
            default:
                break;
        }
        
        // Refresh category total
        [self setTotal:[self valueForKeyPath:@"transactions.@sum.value"]];
    }
    
}




@end
