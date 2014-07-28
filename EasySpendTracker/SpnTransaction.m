//
//  SpnTransaction.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "SpnTransaction.h"

@implementation SpnTransaction

- (SpnTransaction*)clone
{
    // Create the clone
    SpnTransaction* clonedTransaction = [[SpnTransaction alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnTransactionMO" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];

    // copy attributes to the clone
    [clonedTransaction setDate:self.date];
    [clonedTransaction setMerchant:self.merchant];
    [clonedTransaction setNotes:self.notes];
    [clonedTransaction setType:self.type];
    [clonedTransaction setValue:self.value];
    [clonedTransaction setSubCategory:self.subCategory];
    
    // return the clone
    return clonedTransaction;
}

- (NSString*) sectionName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle: NSDateFormatterMediumStyle];
    
    return [dateFormatter stringFromDate:self.date];
}


@end
