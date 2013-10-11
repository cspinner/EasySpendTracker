//
//  UIView+spnViewCategory.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/28/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "UIView+spnViewCategory.h"

@implementation UIView (spnViewCategory)

static NSDateFormatter* sharedDateFormatterMonthDayYear;
static NSDateFormatter* sharedDateFormatterMonth;

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

- (NSDateFormatter*)dateFormatterMonthDayYear
{
    if (sharedDateFormatterMonthDayYear == nil)
    {
        sharedDateFormatterMonthDayYear = [[NSDateFormatter alloc] init];
        [sharedDateFormatterMonthDayYear setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"yyyyMd" options:0 locale:[NSLocale currentLocale]]];
    }
    
    return sharedDateFormatterMonthDayYear;
}

- (NSDateFormatter*)dateFormatterMonth
{
    if (sharedDateFormatterMonth == nil)
    {
        sharedDateFormatterMonth = [[NSDateFormatter alloc] init];
        [sharedDateFormatterMonth setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"MMMM" options:0 locale:[NSLocale currentLocale]]];
    }
    
    return sharedDateFormatterMonth;
}

@end
