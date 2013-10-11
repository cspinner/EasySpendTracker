//
//  UIView+spnViewCategory.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/28/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (spnViewCategory)

- (UIView*)spnFirstResponder;
- (NSDateFormatter*)dateFormatterMonthDayYear; // i.e. in US locale "4/12/84" (april 12, 1984)
- (NSDateFormatter*)dateFormatterMonth; // i.e. "September"

@end
