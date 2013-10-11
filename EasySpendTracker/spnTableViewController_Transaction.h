//
//  spnTableViewController_Transaction.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/2/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transaction.h"
#import "spnAddTransactionDelegate.h"

@interface spnTableViewController_Transaction : UITableViewController <UITableViewDelegate, UITableViewDataSource, spnAddTransactionDelegate>

@property Transaction* transaction;

@end
