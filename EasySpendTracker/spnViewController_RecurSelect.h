//
//  spnViewController_Recur.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/2/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol spnViewController_RecurSelectDelegate <NSObject>

@required

- (NSDateComponents*)recurGetFrequency;
- (void)recurSetFrequency:(NSDateComponents*)frequency;

@end


@interface spnViewController_RecurSelect : UITableViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate>

@property(nonatomic,assign) id<spnViewController_RecurSelectDelegate> delegate;

@end
