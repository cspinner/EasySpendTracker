//
//  UIView+spnViewCtgy.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/28/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (spnViewCtgy)

@property UIDatePicker* datePicker;

- (UIView*)spnFirstResponder;
- (UIView*)datePickerView;
- (void)dismissKeyboard;

@end
