//
//  spnTableViewController_Categories.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/25/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol spnTableViewController_CategoriesDelegate <NSObject>

@required
- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
- (void)selectedRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface spnTableViewController_Categories : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>


@property (nonatomic) NSManagedObjectContext* managedObjectContext;
@property(nonatomic,assign) id<spnTableViewController_CategoriesDelegate> delegate;

// properties used for fetched results controller
@property (nonatomic)  NSFetchedResultsController* fetchedResultsController;
@property NSString* entityName;
@property NSPredicate* predicate;

@end
