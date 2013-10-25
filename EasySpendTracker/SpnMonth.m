//
//  SpnMonth.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "SpnMonth.h"
#import "SpnSpendCategory.h"
#import "spnUtils.h"

@implementation SpnMonth

+ (SpnMonth*)fetchMonthWithDate:(NSDate*)date inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    NSError *error = nil;
    SpnMonth* month = nil;
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SpnMonthMO"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sectionName == %@", [[[spnUtils sharedUtils] dateFormatterMonthYear] stringFromDate:date]];
    [fetchRequest setPredicate:predicate];
    
    NSMutableArray *mutableFetchResults = [[managedObjectContext                                                executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if (mutableFetchResults == nil)
    {
        // Error
    }
    else
    {
        // Target month was found
        if([mutableFetchResults count] != 0)
        {
            // set the return value
            month = [mutableFetchResults objectAtIndex:0];
        }
        else
        {
            // Month not found - add a new one
            month = [[SpnMonth alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnMonthMO" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
            
            //month = (SpnMonth*)[NSEntityDescription                                                  insertNewObjectForEntityForName:@"SpnMonthMO"                                                  inManagedObjectContext:managedObjectContext];
            [month setDate:date];
            [month setSectionName:[[[spnUtils sharedUtils] dateFormatterMonthYear] stringFromDate:date]];
        }
    }
    
    return month;
}

- (id)initWithEntity:(NSEntityDescription*)entity insertIntoManagedObjectContext:(NSManagedObjectContext*)context
{
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self != nil) {
        // Perform additional initialization.
        [self setTotalExpenses:[NSNumber numberWithFloat:0.00]];
        [self setTotalIncome:[NSNumber numberWithFloat:0.00]];
    }
    return self;
}

- (SpnSpendCategory*)fetchCategoryWithName:(NSString*)categoryName
{
    NSError *error = nil;
    SpnSpendCategory* category = nil;
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SpnSpendCategoryMO"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title MATCHES[cd] %@) AND (month == %@)", categoryName, self];
    [fetchRequest setPredicate:predicate];
    
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext                                                executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if (mutableFetchResults == nil)
    {
        // Error
    }
    else
    {
        // Target category was found
        if([mutableFetchResults count] != 0)
        {
            // set the return value
            category = [mutableFetchResults objectAtIndex:0];
        }
        else
        {
            // Category not found - add a new one
            category = [[SpnSpendCategory alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnSpendCategoryMO" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];

            [category setTitle:categoryName];        
            [category setMonth:self];
        }
    }
    
    return category;
}

@end
