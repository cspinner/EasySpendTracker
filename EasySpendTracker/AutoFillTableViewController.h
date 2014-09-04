//
//  AutoFillTableViewController.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/3/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AutoFillTableViewController;

@protocol AutoFillDelegate <NSObject>

@required
- (void)autoFillTable:(AutoFillTableViewController*)autoFillTable selectedEntry:(NSString*)entry;

@end

@interface AutoFillTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>


@property UITextField *textField;
@property NSMutableArray* sourceData;
@property NSMutableArray * searchResults;
@property id<AutoFillDelegate> delegate;


@property NSNumber* yPosition;

- (void)createTableViewWithYPosition:(NSNumber *)yPosition;
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring;

@end

