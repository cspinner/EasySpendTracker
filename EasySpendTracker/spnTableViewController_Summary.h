//
//  spnTableViewController_Summary.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 8/22/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spnCollectionContainerView.h"

@interface spnTableViewController_Summary : UITableViewController <UITableViewDelegate, UITableViewDataSource, spnCollectionContainerDelegate, UIAlertViewDelegate>

@property NSManagedObjectContext* managedObjectContext;

@end
