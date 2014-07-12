//
//  spnViewController_Recur.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/2/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol spnViewController_RecurDelegate <NSObject>

@required

- (NSDateComponents*)recurGetFrequency;
- (void)recurSetFrequency:(NSDateComponents*)frequency;

@end


@interface spnViewController_Recur : UITableViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate>

@property(nonatomic,assign) id<spnViewController_RecurDelegate> delegate;

@end
