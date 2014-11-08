//
//  spnBarPlotProcessDataOp.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/26/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnBarPlotProcessDataOp.h"

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
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDate* date = [transactions[0] valueForKey:@"date"];
            NSDateComponents* dateComponents = [calendar components:NSCalendarUnitMonth fromDate:date];
            NSDateComponents* prevDateComponents = [[NSDateComponents alloc] init];
            
            // Create the date formatter to extract the month
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"MMMM" options:0 locale:[NSLocale currentLocale]]];
            
            // For each transaction
            for (id transaction in transactions)
            {
                date = [transaction valueForKey:@"date"];
                dateComponents = [calendar components:NSCalendarUnitMonth fromDate:date];
                
                // If the transaction is not in the same month as previous
                if (dateComponents.month != prevDateComponents.month)
                {
                    NSDate* monthDate = [calendar dateFromComponents:dateComponents];
                    
                    // add plot data item
                    [barPlotValues addObject:[NSDecimalNumber numberWithFloat:0.0]];
                    [barPlotMonths addObject:[dateFormatter stringFromDate:monthDate]];
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
                
                prevDateComponents = [dateComponents copy];
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
