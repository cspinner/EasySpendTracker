//
//  spnTableViewController_Transaction.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/2/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Income.h"
#import "SpnCategory.h"

@interface spnTableViewController_Income ()

@end

@implementation spnTableViewController_Income

#define DEFAULT_CATEGORY_TITLE @"Income"

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize category title based on category
    if (self.transaction.category)
    {
        [self setCategory_string:self.transaction.category.title];
    }
    else
    {
        // Category is hardcoded to the default for this view controller
        [self setCategory_string:DEFAULT_CATEGORY_TITLE];
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
