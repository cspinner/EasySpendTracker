//
//  spnTableViewController_Transaction.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/2/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpnTransaction.h"
#import "spnViewController_Recur.h"

@interface spnTableViewController_Expense : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, spnViewController_RecurDelegate>

@property SpnTransaction* transaction;
@property (nonatomic) NSManagedObjectContext* managedObjectContext;

@end
