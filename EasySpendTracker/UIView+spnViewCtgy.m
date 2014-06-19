//
//  UIView+spnViewCategory.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/28/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "UIView+spnViewCtgy.h"
#import "spnUtils.h"
#import <objc/runtime.h>

static char const * const DatePickerKey = "DatePicker";

@implementation UIView (spnViewCtgy)

@dynamic datePicker;

- (UIDatePicker*)datePicker
{
    return objc_getAssociatedObject(self, DatePickerKey);
}

- (void)setDatePicker:(UIDatePicker*)newDatePicker
{
    objc_setAssociatedObject(self, DatePickerKey, newDatePicker,  OBJC_ASSOCIATION_RETAIN);
}

// Returns the first responder subview of the view
- (UIView*)spnFirstResponder
{
    if (self.isFirstResponder)
    {
        return self;
    }
    
    for (UIView *subView in self.subviews)
    {
        UIView *firstResponder = [subView spnFirstResponder];
        
        if (firstResponder != nil)
        {
            return firstResponder;
        }
    }
    
    return nil;
}

- (UIView*)datePickerView
{
    UIView* datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 288, 320, 260)];
    UIToolbar *datePickerViewToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem* dateToolbarCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dateButtonClicked:)];
    [dateToolbarCancelButton setTag:0];
    UIBarButtonItem* dateToolbarSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* dateToolbarDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dateButtonClicked:)];
    [dateToolbarDoneButton setTag:1];
    [datePickerViewToolbar setItems:[NSArray arrayWithObjects:dateToolbarCancelButton, dateToolbarSpacer, dateToolbarDoneButton, nil]];
    
    [self setDatePicker:[[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 320, 216)]];
	[self.datePicker setDatePickerMode:UIDatePickerModeDate];
	[self.datePicker setDate:[NSDate date]];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    [datePickerView addSubview:datePickerViewToolbar];
    [datePickerView addSubview:self.datePicker];
    
    return datePickerView;
}

- (void)dateButtonClicked:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]])
    {
        UIView* firstResponder = [self spnFirstResponder];
        
        if([firstResponder isKindOfClass:[UITextField class]])
        {
            UITextField* textField = (UITextField*)firstResponder;
            
            if([(UIBarButtonItem*)sender tag] == 1)
            {
                [textField setText:[[[spnUtils sharedUtils] dateFormatterMonthDayYear] stringFromDate:[self.datePicker date]]];
            }
            
            [textField resignFirstResponder];
        }
    }
}

- (void)dismissKeyboard
{
    UIView* firstResponder = [self spnFirstResponder];
    
    if(([firstResponder isKindOfClass:[UITextField class]]) ||
       ([firstResponder isKindOfClass:[UITextView class]]))
    {
        [firstResponder resignFirstResponder];
    }
}

@end
