//
//  spnTableViewController_BillReminders.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 11/21/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spnTableViewController_BillReminders : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic) NSManagedObjectContext* managedObjectContext;

@end
