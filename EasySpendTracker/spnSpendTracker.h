//
//  spnSpendTracker.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/27/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpnTransaction.h"
#import "SpnBillReminder.h"

@interface spnSpendTracker : NSObject 

@property (nonatomic) UIViewController* rootViewController;
@property (nonatomic) NSManagedObjectContext* managedObjectContext;
@property NSDate* dateViewCntlLoaded;

+ (spnSpendTracker*)sharedManager;
- (void)initViews;
- (void)saveContext:(NSManagedObjectContext*)managedObjectContext;

- (void)initLocalNotifications;
- (void)addLocalNotificationWithID:(NSNumber*)uniqueID alertBody:(NSString*)alertBody fireDate:(NSDate*)fireDate;
- (void)processLocalNotification:(UILocalNotification*)notification withActionIdentifier:(NSString*)identifier;
- (void)deleteLocalNotificationWithUniqueID:(NSNumber*)uniqueID;
- (void)renumberBadgesOfPendingNotifications;

- (void)updateAllRecurrences;

- (SpnTransaction*)createTransactionWithType:(enumSpnTransactionType)transactionType;
- (void)deleteTransaction:(SpnTransaction*)transaction;

- (void)updateAllReminders;
- (SpnBillReminder*)createBillReminder;
- (void)deleteBillReminder:(SpnBillReminder*)reminder;
- (void)markBillReminderAsPending:(SpnBillReminder*)reminder;
- (void)markBillReminderAsUnpaid:(SpnBillReminder*)reminder;
- (void)markBillReminderAsPaid:(SpnBillReminder*)reminder doRescheduleIfRecurring:(BOOL)doReschedule;
- (void)scheduleNotificationForReminder:(SpnBillReminder*)reminder;
- (SpnBillReminder*)reminderWithUniqueID:(NSNumber*)uniqueID;

@end
