//
//  spnSpendTracker.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/27/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpnBillReminder.h"

@interface spnSpendTracker : NSObject 

@property (nonatomic) UIViewController* rootViewController;
@property (nonatomic) NSManagedObjectContext* managedObjectContext;
@property NSDate* dateViewCntlLoaded;

+ (spnSpendTracker*)sharedManager;
- (void)initViews;
- (void)saveContext:(NSManagedObjectContext*)managedObjectContext;
- (void)initLocalNotifications;
- (void)addLocalNotification:(UILocalNotification*)notification;
- (void)processLocalNotification:(UILocalNotification*)notification withActionIdentifier:(NSString*)identifier;
- (void)deleteLocalNotificationWithUniqueID:(NSNumber*)uniqueID;
- (void)renumberBadgesOfPendingNotifications;
- (void)updateAllRecurrences;
- (void)updateAllReminders;
- (void)billReminder:(SpnBillReminder*)reminder setPaidStatus:(enumBillReminderPaidStatus)paidStatus shouldAdjustBadge:(BOOL)shouldAdjustBadge;

@end
