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
#import "NSDate+Convenience.h"

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
- (void)configureCell:(UITableViewCell*)cell withObject:(id)object
{
    SpnCategory* category = (SpnCategory*)object;

    // Create predicate to filter transactions by date
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date < %@)", self.startDate, self.endDate];
    
    NSSet* mergedTransactionsSets = [category.subCategories valueForKeyPath:@"@distinctUnionOfSets.transactions"];
    NSSet* thisMonthTransactions = [mergedTransactionsSets filteredSetUsingPredicate:predicate];
    
    // Write cell contents
    NSNumber* thisMonthTotal = [thisMonthTransactions valueForKeyPath:@"@sum.value"];
    [cell.textLabel setText:category.title];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"$%.2f", thisMonthTotal.floatValue]];
}

- (void)selectedObjectIndexPath:(id)object;
{
    // Get reference to selected item from the fetch controller
    SpnCategory* category = (SpnCategory*)object;
    
    // Create and Push transaction detail view controller
    spnTableViewController_SubCategories* subCategoryTableViewController = [[spnTableViewController_SubCategories alloc] initWithStyle:UITableViewStyleGrouped];
    [subCategoryTableViewController setTitle:self.title];
    [subCategoryTableViewController setCategoryTitle:[category title]];
    [subCategoryTableViewController setStartDate:self.startDate];
    [subCategoryTableViewController setEndDate:self.endDate];
    [subCategoryTableViewController setManagedObjectContext:self.managedObjectContext];
    
    [[self navigationController] pushViewController:subCategoryTableViewController animated:YES];
}

@end
