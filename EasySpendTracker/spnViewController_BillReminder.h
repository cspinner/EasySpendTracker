//
//  spnTableViewController_BillReminder.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 11/16/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpnBillReminder.h"
#import "spnTableViewController_RecurSelect.h"

@interface spnViewController_BillReminder : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, spnViewController_RecurSelectDelegate, UIGestureRecognizerDelegate>

// Table section indexes
typedef NS_ENUM(NSInteger, SpnReminderViewCntlSectionIndexType)
{
    REM_MARK_PAID_SECTION_INDEX,
    REM_AMOUNT_SECTION_IDX,
    REM_MERCHANT_SECTION_IDX,
    REM_DATE_SECTION_IDX,
    REM_DESCRIPTION_SECTION_IDX,
    REM_RECURRENCE_SECTION_IDX,
    REM_DELETE_SECTION_IDX,
    REM_NUM_SECTIONS
};

// Texfield/view tags
enum
{
    REM_AMOUNT_VIEW_TAG = 1,
    REM_MERCHANT_VIEW_TAG,
    REM_DATE_VIEW_TAG,
    REM_DESCRIPTION_VIEW_TAG,
    REM_RECURRENCE_VIEW_TAG
};

@property SpnBillReminder* billReminder;
@property (nonatomic) NSManagedObjectContext* managedObjectContext;
@property BOOL isNew;
@property BOOL dueDateWasUpdated;

@property NSNumber* value;
@property enumBillReminderPaidStatus paidStatus;
@property NSString* merchant;
@property NSDate* date;
@property NSString* notes;
@property NSDateComponents* frequency;

@end
