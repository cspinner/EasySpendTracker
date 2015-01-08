//
//  spnTableViewController_SubCategories.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/27/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_SubCategories.h"
#import "spnTableViewController_Transactions.h"
#import "SpnSubCategory.h"
#import "spnUtils.h"
#import "NSDate+Convenience.h"

@interface spnTableViewController_SubCategories ()

@end

@implementation spnTableViewController_SubCategories

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Choose the category entity, delegate, and predicate
    self.entityName = @"SpnSubCategoryMO";
    self.delegate = self;
    self.predicate = [NSPredicate predicateWithFormat:@"category.title == %@", self.categoryTitle];
    
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
    SpnSubCategory* subCategory = (SpnSubCategory*)object;
    
    // Create predicate to filter transactions by date
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date < %@)", self.startDate, self.endDate];
    
    NSSet* thisMonthTransactions = [subCategory.transactions filteredSetUsingPredicate:predicate];
    
    // Write cell contents
    NSNumber* thisMonthTotal = [thisMonthTransactions valueForKeyPath:@"@sum.value"];
    [cell.textLabel setText:subCategory.title];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"$%.2f", thisMonthTotal.floatValue]];
}

- (void)selectedObjectIndexPath:(id)object;
{
    // Get reference to selected item from the fetch controller
    SpnSubCategory* subCategory = (SpnSubCategory*)object;
    
    // Create and Push transaction detail view controller
    spnTableViewController_Transactions* transactionsTableViewController = [[spnTableViewController_Transactions alloc] initWithStyle:UITableViewStyleGrouped];
    [transactionsTableViewController setTitle:[subCategory title]];
    [transactionsTableViewController setStartDate:self.startDate];
    [transactionsTableViewController setEndDate:self.endDate];
    [transactionsTableViewController setManagedObjectContext:self.managedObjectContext];
    [transactionsTableViewController setSubCategoryTitles:@[subCategory.title]];
    [transactionsTableViewController setCategoryTitles:@[self.categoryTitle]];
    [transactionsTableViewController setMerchantTitles:nil];
    
    [[self navigationController] pushViewController:transactionsTableViewController animated:YES];
}

@end
