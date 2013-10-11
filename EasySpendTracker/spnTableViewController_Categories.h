//
//  spnTableViewController_Categories.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/25/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spnAddController.h"

@interface spnTableViewController_Categories : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic) NSManagedObjectContext* managedObjectContext;

@end
