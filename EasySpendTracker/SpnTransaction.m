//
//  SpnTransaction.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "SpnTransaction.h"

@implementation SpnTransaction

- (NSString*) sectionName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle: NSDateFormatterMediumStyle];
    
    return [dateFormatter stringFromDate:self.date];
}


@end
