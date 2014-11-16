//
//  spnBarPlotProcessDataOp.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/26/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnBarPlotProcessDataOp.h"
#import "NSDate+Convenience.h"

@interface spnBarPlotProcessDataOp()

@end

@implementation spnBarPlotProcessDataOp

- (id)init
{
    self = [super init];
    if (self) {
        // sub class specific init. Note this is invoked from the calling thread
    }
    return self;
}

// main is invoked by the NSOperationQueue
- (void)main
{
    @autoreleasepool
    {
        NSMutableArray* barPlotValues = [[NSMutableArray alloc] init];
        NSMutableArray* barPlotMonths = [[NSMutableArray alloc] init];
        
        // Create a managed object context unique to this operation
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        
        // Retrieve transaction objects from object IDs
        NSMutableArray* transactions = [[NSMutableArray alloc] init];
        for (NSManagedObjectID* transactionID in self.transactionIDs)
        {
            [transactions addObject:[managedObjectContext objectWithID:transactionID]];
        }
        
        // Sort transactions by date
        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        [transactions sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        if (transactions.count > 0)
        {
            NSInteger i = -1;
            NSDate* date;
            NSDate* prevDate;

            // For each transaction
            for (id transaction in transactions)
            {
                date = [transaction valueForKey:@"date"];
                
                // If the transaction is not in the same month as previous
                if (date.month != prevDate.month)
                {
                    // add plot data item
                    [barPlotValues addObject:[NSDecimalNumber numberWithFloat:0.0]];
                    [barPlotMonths addObject:[NSDate stringFromDate:date format:@"MMMM"]];
                    i++;
                }
                
                NSDecimalNumber* value = [[NSDecimalNumber alloc] initWithDecimal:[[transaction valueForKey:@"value"] decimalValue]];
                
                // Income transactions add to the value, expense transactions subtract
                if ([[transaction valueForKeyPath:@"subCategory.category.title"] isEqualToString:@"Income"])
                {
                    barPlotValues[i] = [barPlotValues[i] decimalNumberByAdding:value];
                }
                else
                {
                    barPlotValues[i] = [barPlotValues[i] decimalNumberBySubtracting:value];
                }
                
                prevDate = [date copy];
            }
        }
        
        // Call dataReturnBlock block
        if(self.dataReturnBlock)
        {
            self.dataReturnBlock([[NSMutableArray alloc] initWithArray:barPlotValues copyItems:YES], [[NSMutableArray alloc] initWithArray:barPlotMonths copyItems:YES]);
        }
    }
}

@end
