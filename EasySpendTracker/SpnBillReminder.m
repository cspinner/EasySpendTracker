//
//  SpnBillReminder.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 11/16/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "SpnBillReminder.h"

@implementation SpnBillReminder

- (NSString*) sectionName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle: NSDateFormatterMediumStyle];
    
    return [dateFormatter stringFromDate:self.dateDue];
}

- (enumBillReminderPaidStatus)paidStatus
{
    return (enumBillReminderPaidStatus)self.paidStatusRaw.integerValue;
}

- (void)setPaidStatus:(enumBillReminderPaidStatus)paidStatus
{
    self.paidStatusRaw = @(paidStatus);
}

+ (NSSet *)keyPathsForValuesAffectingPaidStatus
{
    return [NSSet setWithObject:@"paidStatusRaw"];
}

@end
