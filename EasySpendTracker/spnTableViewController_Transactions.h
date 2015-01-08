//
//  spnTableViewController_Transactions.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/29/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spnTableViewController_Transactions : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic) NSArray* categoryTitles;
@property (nonatomic) NSArray* subCategoryTitles;
@property (nonatomic) NSArray* merchantTitles;
@property (nonatomic) NSDate* startDate;
@property (nonatomic) NSDate* endDate;
@property (nonatomic) NSManagedObjectContext* managedObjectContext;

@end
