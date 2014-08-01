//
//  spnTableViewController_Transactions.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/29/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spnTableViewController_Transactions : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property NSString* categoryTitle;
@property (nonatomic) NSManagedObjectContext* managedObjectContext;

@end
