//
//  SpnCategory.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "SpnCategory.h"
#import "SpnTransaction.h"

@implementation SpnCategory

static int transactionsObservanceContext;

+ (SpnCategory*)fetchCategoryWithName:(NSString*)categoryName inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    NSError *error = nil;
    SpnCategory* category = nil;
    
    // Find categories (but should only be one) matching the specified name
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SpnCategoryMO"];
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
            category = [[SpnCategory alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnCategoryMO" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
            
            // Perform additional initialization.
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

- (void)willTurnIntoFault
{
    // Called when this category is being sent to the store
    [super willTurnIntoFault];
    
    // Remove all observances this instance has
    [self removeObserver:self forKeyPath:@"transactions" context:&transactionsObservanceContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &transactionsObservanceContext)
    {
        switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
        {
            case NSKeyValueChangeRemoval:
            {
                // Is there a better way?
                if (self.transactions.count == nil ||
                    self.transactions.count == 0)
                {
                    [self.managedObjectContext deleteObject:self];
                    NSLog(@"Removing empty category");
                }
            }
                break;
                
            case NSKeyValueChangeReplacement:
            case NSKeyValueChangeSetting:
            case NSKeyValueChangeInsertion:
            default:
                break;
        }
    }
    
}




@end
