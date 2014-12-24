//
//  SpnBillReminder.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 11/16/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "SpnBillReminderMO.h"

@interface SpnBillReminder : SpnBillReminderMO

typedef enum
{
    PAID_STATUS_NONE,
    PAID_STATUS_PAID,
    PAID_STATUS_UNPAID
} enumBillReminderPaidStatus;

- (enumBillReminderPaidStatus)paidStatus;
- (void)setPaidStatus:(enumBillReminderPaidStatus)paidStatus;

@end
