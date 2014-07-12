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

enum
{
    UPDATE_ALL_AS_INDEX,
    UPDATE_FUTURE_AS_INDEX,
    UPDATE_ONE_AS_INDEX
};

@interface spnTableViewController_Income : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, spnViewController_RecurDelegate, UIActionSheetDelegate>

@property SpnTransaction* transaction;
@property (nonatomic) NSManagedObjectContext* managedObjectContext;

@end
