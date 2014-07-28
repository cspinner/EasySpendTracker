//
//  SpnSubCategory.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/26/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "SpnSubCategory.h"

@implementation SpnSubCategory

static int transactionsObservanceContext;

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
                    NSLog(@"Removing empty sub-category");
                }
            }
                break;
                
            case NSKeyValueChangeReplacement:
            case NSKeyValueChangeSetting:
            case NSKeyValueChangeInsertion:
            default:
                break;
        }
        
        // Update last modified date for the sub-category and main category
        self.lastModifiedDate = [NSDate date];
        id category = self.category;
        
        if ([category respondsToSelector:@selector(setLastModifiedDate:)])
        {
            [category setLastModifiedDate:[NSDate date]];
        }
    }
    
}

@end
