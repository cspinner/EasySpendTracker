//
//  spnTableViewController_MainCategories.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/27/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_MainCategories.h"
#import "spnTableViewController_SubCategories.h"
#import "SpnCategory.h"
#import "spnUtils.h"

@interface spnTableViewController_MainCategories ()

@end

@implementation spnTableViewController_MainCategories

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Choose the category entity, delegate, and predicate
    self.entityName = @"SpnCategoryMO";
    self.delegate = self;
    self.predicate = [NSPredicate predicateWithFormat:@"title LIKE %@", @"*"];
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error])
    {
        // Update to handle the error appropriately.
        NSLog(@"Category Fetch Error: %@, %@", error, [error userInfo]);
        exit(-1);
    }
}

//<spnTableViewController_CategoriesDelegate> methods
- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    SpnCategory* category = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Determine category total for this month
    // Get the start and end date for predicate to use
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* tempComponents = [[NSDateComponents alloc] init];
    [tempComponents setMonth:1];
    
    NSDate* thisDayNextMonth = [calendar dateByAddingComponents:tempComponents toDate:[NSDate date] options:0];
    
    tempComponents = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:thisDayNextMonth];
    [tempComponents setDay:1];
    
    // First day of the next month - this will be the end date (exclusive)
    NSDate* firstDayOfNextMonth = [calendar dateFromComponents:tempComponents];
    
    tempComponents = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    [tempComponents setDay:1];
    
    // First day of this month - this will be the start date (inclusive)
    NSDate* firstDayOfThisMonth = [calendar dateFromComponents:tempComponents];
    
    // Create predicate to filter transactions by date
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date < %@)", firstDayOfThisMonth, firstDayOfNextMonth];
    
    NSSet* mergedTransactionsSets = [category.subCategories valueForKeyPath:@"@distinctUnionOfSets.transactions"];
    NSSet* thisMonthTransactions = [mergedTransactionsSets filteredSetUsingPredicate:predicate];
    
    // Write cell contents
    NSNumber* thisMonthTotal = [thisMonthTransactions valueForKeyPath:@"@sum.value"];
    [cell.textLabel setText:category.title];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@: $%.2f", [[[spnUtils sharedUtils] dateFormatterMonth] stringFromDate:[NSDate date]], thisMonthTotal.floatValue]];
}

- (void)selectedRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get reference to selected item from the fetch controller
    SpnCategory* category = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Create and Push transaction detail view controller
    spnTableViewController_SubCategories* subCategoryTableViewController = [[spnTableViewController_SubCategories alloc] initWithStyle:UITableViewStyleGrouped];
    [subCategoryTableViewController setTitle:[category title]];
    [subCategoryTableViewController setCategoryTitle:[category title]];
    [subCategoryTableViewController setManagedObjectContext:self.managedObjectContext];
    
    [[self navigationController] pushViewController:subCategoryTableViewController animated:YES];
}

@end
