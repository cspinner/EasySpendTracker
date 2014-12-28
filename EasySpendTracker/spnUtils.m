//
//  spnUtils.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/23/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnUtils.h"

@implementation spnUtils

static NSDateFormatter* sharedDateFormatterMonthDayYear;
static NSDateFormatter* sharedDateFormatterMonthYear;
static NSDateFormatter* sharedDateFormatterMonth;
static spnUtils *sharedUtils = nil;

+ (spnUtils*)sharedUtils
{
    if (sharedUtils == nil) {
        sharedUtils = [[super alloc] init];
    }
    return sharedUtils;
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

- (NSDateFormatter*)dateFormatterMonthYear
{
    if (sharedDateFormatterMonthYear == nil)
    {
        sharedDateFormatterMonthYear = [[NSDateFormatter alloc] init];
        [sharedDateFormatterMonthYear setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"MMMyyyy" options:0 locale:[NSLocale currentLocale]]];
    }
    
    return sharedDateFormatterMonthYear;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
