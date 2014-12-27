//
//  spnLoadPieChartDataOp.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/24/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnPieChartProcessDataOp.h"

@interface spnPieChartProcessDataOp()

@end


@implementation spnPieChartProcessDataOp

- (id)init
{
    self = [super init];
    if (self) {
        // sub class specific init. Note this is invoked from the calling thread
    }
    return self;
}

-(void)sortArraysTogetherBasedOnArray:(NSMutableArray**)numberArray secondArray:(NSMutableArray**)secondArray
{
    // Create permutation array
    NSMutableArray *p = [NSMutableArray arrayWithCapacity:(*numberArray).count];
    
    // Create array of numbers 0 - n
    for (NSUInteger i = 0 ; i < (*numberArray).count; i++)
    {
        [p addObject:[NSNumber numberWithInteger:i]];
    }
    
    // Rearrange the 0 - n array based on the desired order of numberArray
    [p sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
         // Sort routine wants to sort objects in ascending order, so our comparator needs to return the opposite to force it to sort in descending order.
         if (NSOrderedAscending == [[(*numberArray) objectAtIndex:[obj1 integerValue]] compare:[(*numberArray) objectAtIndex:[obj2 integerValue]]])
         {
             return NSOrderedDescending;
         }
         
         if (NSOrderedDescending == [[(*numberArray) objectAtIndex:[obj1 integerValue]] compare:[(*numberArray) objectAtIndex:[obj2 integerValue]]])
         {
             return NSOrderedAscending;
         }
         
         return NSOrderedSame;
     }];
    
    // Create array objects to hold the sorted arrays
    NSMutableArray *sortedFirst = [NSMutableArray arrayWithCapacity:(*numberArray).count];
    NSMutableArray *sortedSecond = [NSMutableArray arrayWithCapacity:(*numberArray).count];
    
    // Enumerate through the rearranged 0 - n array. This is the order that both arrays will need.
    [p enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSUInteger pos = [obj intValue];
         [sortedFirst addObject:[(*numberArray) objectAtIndex:pos]];
         [sortedSecond addObject:[(*secondArray) objectAtIndex:pos]];
     }];
    
    *numberArray = [[NSMutableArray alloc] initWithArray:sortedFirst copyItems:YES];
    *secondArray = [[NSMutableArray alloc] initWithArray:sortedSecond copyItems:YES];
}

// main is invoked by the NSOperationQueue
- (void)main
{
    @autoreleasepool
    {
        // Create a managed object context unique to this operation
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        
        // Retrieve transaction objects from object IDs
        NSMutableArray* transactions = [[NSMutableArray alloc] init];
        for (NSManagedObjectID* transactionID in self.transactionIDs)
        {
            [transactions addObject:[managedObjectContext objectWithID:transactionID]];
        }
        
        // If the optional predicate was defined
        if (self.predicate != nil)
        {
            transactions = [[transactions filteredArrayUsingPredicate:self.predicate] mutableCopy];
        }
        
        NSMutableArray* valuesArray = [[NSMutableArray alloc] init];
        
        // Get array of unique names
        NSMutableArray* namesArray = [transactions valueForKeyPath:[NSString stringWithFormat:@"@distinctUnionOfObjects.%@", self.keyPath]];
        
        for(NSString* name in namesArray)
        {
            // Get array of transactions for each name
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K MATCHES[cd] %@", self.keyPath, name];
            NSArray* filteredTransactions = [transactions filteredArrayUsingPredicate:predicate];
            
            // Store the sum of values of those transactions to the array
            [valuesArray addObject:[filteredTransactions valueForKeyPath:@"@sum.value"]];
        }
        
        [self sortArraysTogetherBasedOnArray:&valuesArray secondArray:&namesArray];

        // Call dataReturnBlock block
        if(self.dataReturnBlock)
        {
            self.dataReturnBlock([[NSMutableArray alloc] initWithArray:valuesArray copyItems:YES], [[NSMutableArray alloc] initWithArray:namesArray copyItems:YES]);
        }
    }
}


@end
