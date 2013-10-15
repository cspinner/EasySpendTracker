//
//  spnViewController_Months.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/11/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpnMonth.h"

@interface spnViewController_Months : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, weak) id delegate;

@end
