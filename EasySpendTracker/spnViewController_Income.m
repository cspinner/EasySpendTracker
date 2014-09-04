//
//  spnTableViewController_Transaction.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/2/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnViewController_Income.h"
#import "SpnCategory.h"
#import "SpnSubCategory.h"

@interface spnViewController_Income ()

@end

@implementation spnViewController_Income

#define DEFAULT_CATEGORY_TITLE @"Income"
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

// <UITableViewDataSource> methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Category section is not desired for the Income view
    if (section != CATEGORY_SECTION_IDX)
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    else
    {
        return 0;
    }
}

// <UITableViewDelegate> methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Category section is not desired for the Income view
    if (section != CATEGORY_SECTION_IDX)
    {
        return [super tableView:tableView viewForHeaderInSection:section];
    }
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // Category section is not desired for the Income view
    if (section != CATEGORY_SECTION_IDX)
    {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
    else
    {
        return 0.001;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    // Category section is not desired for the Income view
    if (section != CATEGORY_SECTION_IDX)
    {
        return [super tableView:tableView heightForFooterInSection:section];
    }
    else
    {
        return 0.001;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Category section is not desired for the Income view
    if (indexPath.section != CATEGORY_SECTION_IDX)
    {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    else
    {
        return 0.001;
    }
}


@end
