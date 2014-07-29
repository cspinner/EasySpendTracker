//
//  spnTableViewController_SubCategories.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/27/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Categories.h"

@interface spnTableViewController_SubCategories : spnTableViewController_Categories <spnTableViewController_CategoriesDelegate>

@property NSString* categoryTitle;

@end
