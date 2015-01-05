//
//  spnTableViewController_Transaction.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/2/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnViewController_Expense.h"
#import "SpnCategory.h"
#import "SpnSubCategory.h"

@interface spnViewController_Expense ()

@end

@implementation spnViewController_Expense

#define DEFAULT_CATEGORY_TITLE @"Uncategorized"
#define DEFAULT_SUB_CATEGORY_TITLE @"Miscellaneous"

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize category title based on category
    if (self.transaction.subCategory)
    {
        [self setCategory_string:self.transaction.subCategory.category.title];
        [self setSubCategory_string:self.transaction.subCategory.title];
    }
    else
    {
        // Category and SubCategory is hardcoded to the default for this view controller
        [self setCategory_string:DEFAULT_CATEGORY_TITLE];
        [self setSubCategory_string:DEFAULT_SUB_CATEGORY_TITLE]; 
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [super tableView:tableView viewForHeaderInSection:section];
    
    [headerView setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]];
    
    return headerView;
}

@end
