//
//  spnTableViewController_Transaction.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/2/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Expense.h"
#import "SpnCategory.h"
#import "SpnSubCategory.h"

@interface spnTableViewController_Expense ()

@end

@implementation spnTableViewController_Expense

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

@end
