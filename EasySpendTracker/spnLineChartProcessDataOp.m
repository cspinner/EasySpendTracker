//
//  spnLineChartProcessDataOp.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/28/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnLineChartProcessDataOp.h"
#import "NSDate+Convenience.h"

@interface spnLineChartProcessDataOp()

@end

@implementation spnLineChartProcessDataOp

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
        NSArray* linePlotXYValues;
        NSArray* linePlotXLabels;
        
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
        
        // retrieve list of values as the data source:
        NSMutableArray* XYValues = [[NSMutableArray alloc] init];
        NSMutableArray* XLabels = [[NSMutableArray alloc] init];
        
        NSDate* dateForCompare1 = [NSDate date:[NSDate date] withComponents:(NSYearCalendarUnit|NSMonthCalendarUnit)]; // Creates year/month only date
        dateForCompare1 = [dateForCompare1 offsetYear:-1]; // 1 year ago

        NSDate* dateForCompare2 = [dateForCompare1 offsetMonth:1]; // 11 months ago
        
        // Get 12 month's worth of totals
        for (NSInteger monthOffset = 0; monthOffset <= 12; monthOffset++)
        {
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date < %@)", dateForCompare1, dateForCompare2];
            NSArray* aMonthsTransactions = [transactions filteredArrayUsingPredicate:predicate];
            
            // If there were any transactions for the month
            NSNumber* valueOfMonth;
            if (aMonthsTransactions.count > 0)
            {
                // Sum the value of them
                valueOfMonth = [aMonthsTransactions valueForKeyPath:@"@sum.value"];
            }
            else
            {
                // assign a value of 0
                valueOfMonth = [NSNumber numberWithFloat:0.0];
            }
            
            // Add the sum and the month offset to the XY data
            [XYValues addObject:@[ @(monthOffset), valueOfMonth] ];
            
            // Add the label for the X axis
            [XLabels addObject:[NSDate stringFromDate:dateForCompare1 format:@"MMMMM"]];
            
            // Increment date pointers by one month
            dateForCompare1 = [dateForCompare1 offsetMonth:1];
            dateForCompare2 = [dateForCompare2 offsetMonth:1];
        }
        
        linePlotXYValues = [NSArray arrayWithArray:XYValues];
        linePlotXLabels = [NSArray arrayWithArray:XLabels];

        // Call dataReturnBlock block
        if(self.dataReturnBlock)
        {
            self.dataReturnBlock([[NSMutableArray alloc] initWithArray:linePlotXYValues copyItems:YES], [[NSMutableArray alloc] initWithArray:linePlotXLabels copyItems:YES]);
        }
    }
}

@end
