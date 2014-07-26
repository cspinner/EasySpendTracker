//
//  spnTableViewController_Transaction.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/2/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Expense.h"
#import "SpnCategory.h"

@interface spnTableViewController_Expense ()

@end

@implementation spnTableViewController_Expense

#define DEFAULT_CATEGORY_TITLE @"Uncategorized"

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

@end
