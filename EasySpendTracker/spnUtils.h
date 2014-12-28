//
//  spnUtils.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/23/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface spnUtils : NSObject

+ (spnUtils*)sharedUtils;

- (NSDateFormatter*)dateFormatterMonthDayYear; // i.e. in US locale "4/12/84" (april 12, 1984)
- (NSDateFormatter*)dateFormatterMonthYear; // i.e. "Sept 2013"
- (NSDateFormatter*)dateFormatterMonth; // i.e. "September"
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
