//
//  spnTableViewController_Summary.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 8/22/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spnTableViewController_Summary : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property NSManagedObjectContext* managedObjectContext;

@end
