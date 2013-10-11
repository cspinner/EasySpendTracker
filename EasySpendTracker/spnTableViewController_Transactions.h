//
//  spnTableViewController_Transactions.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/29/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpendCategory.h"

@interface spnTableViewController_Transactions : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic) SpendCategory* category;
@property (nonatomic) NSManagedObjectContext* managedObjectContext;

@end
