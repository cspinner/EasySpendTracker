//
//  spnTableViewController_Transaction.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/15/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpnTransaction.h"
#import "spnTableViewController_RecurSelect.h"
#import "spnTableViewController_MainCategorySelect.h"
#import "spnTableViewController_SubCategorySelect.h"
#import "AutoFillTableViewController.h"

@interface spnViewController_Transaction : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, spnViewController_RecurSelectDelegate, spnViewController_CategorySelectDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, AutoFillDelegate>

// Table section indexes
typedef NS_ENUM(NSInteger, SpnTransactionViewCntlSectionIndexType)
{
    AMOUNT_SECTION_IDX,
    MERCHANT_SECTION_IDX,
    CATEGORY_SECTION_IDX,
    SUB_CATEGORY_SECTION_IDX,
    DATE_SECTION_IDX,
    DESCRIPTION_SECTION_IDX,
    RECURRENCE_SECTION_IDX,
    DELETE_SECTION_IDX,
    NUM_SECTIONS
};

// Texfield/view tags
enum
{
    AMOUNT_VIEW_TAG = 1,
    MERCHANT_VIEW_TAG,
    CATEGORY_VIEW_TAG,
    SUB_CATEGORY_VIEW_TAG,
    DATE_VIEW_TAG,
    DESCRIPTION_VIEW_TAG,
    RECURRENCE_VIEW_TAG
};

// "Update" action sheet option indexes
enum
{
    UPDATE_ALL_AS_INDEX,
    UPDATE_FUTURE_AS_INDEX,
    UPDATE_ONE_AS_INDEX
};

// "Delete" action sheet option indexes
enum
{
    DELETE_ALL_AS_INDEX,
    DELETE_FUTURE_AS_INDEX,
    DELETE_ONE_AS_INDEX
};

// Action sheet tags
enum
{
    UPDATE_RECUR_AS_TAG,
    UPDATE_RECUR_INTERVAL_AS_TAG,
    DELETE_ONE_AS_TAG,
    DELETE_RECUR_AS_TAG
};

@property SpnTransaction* transaction;
@property (nonatomic) NSManagedObjectContext* managedObjectContext;
@property BOOL isNew;
@property BOOL frequencyWasUpdated;

@property NSNumber* value;
@property NSString* merchant;
@property NSString* category_string;
@property NSString* subCategory_string;
@property NSDate* date;
@property NSString* notes;
@property NSDateComponents* frequency;


@end
