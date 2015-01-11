//
//  spnSpendTracker.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/27/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnSpendTracker.h"
#import "spnTableViewController_Summary.h"
#import "spnTableViewController_MainCategories.h"
#import "spnTableViewController_Transactions.h"
#import "spnTableViewController_BillReminders.h"
#import "spnViewController_Calendar.h"
#import "SpnRecurrence.h"
#import "SpnTransaction.h"
#import "SpnBillReminder.h"
#import "NSDate+Convenience.h"
#import "UIViewController+addTransactionHandles.h"

@interface spnSpendTracker ()

@property UITabBarController* mainTabBarController;
@property spnTableViewController_Summary* summaryViewController;
@property spnTableViewController_MainCategories* categoryTableViewController;
@property spnTableViewController_Transactions* allTransTableViewController;
@property spnViewController_Calendar* calendarViewController;
@property spnTableViewController_BillReminders* remindersTableViewController;

//@property (strong, nonatomic) UIAlertView *notificationAlert;

@end

enum
{
    TAB_BAR_SUMMARY_INEDX,
    TAB_BAR_CATEGORIES_INDEX,
    TAB_BAR_TRANSACTIONS_INDEX,
    TAB_BAR_CALENDAR_INDEX,
    TAB_BAR_REMINDERS_INDEX
};

@implementation spnSpendTracker

static spnSpendTracker *sharedSpendTracker = nil;

#pragma mark - Factory Methods

+ (spnSpendTracker*)sharedManager
{
    if (sharedSpendTracker == nil) {
        sharedSpendTracker = [[super alloc] init];
    }
    return sharedSpendTracker;
}

#pragma mark - View Controllers

- (void)deallocViews
{
    self.allTransTableViewController = nil;
    self.mainTabBarController = nil;
    self.rootViewController = nil;
}

- (void)initViews
{
    // View Controllers
    self.mainTabBarController = [[UITabBarController alloc] init];
    
    self.summaryViewController = [[spnTableViewController_Summary alloc] init];
    [self initSummaryViewCntrl];
    
    self.categoryTableViewController = [[spnTableViewController_MainCategories alloc] initWithStyle:UITableViewStyleGrouped];
    [self initCategoriesViewCntrl];
    
    self.allTransTableViewController = [[spnTableViewController_Transactions alloc] initWithStyle:UITableViewStyleGrouped];
    [self initTransactionsViewCntrl];
    
    self.calendarViewController = [[spnViewController_Calendar alloc] initWithSelectionMode:KalSelectionModeSingle];
    [self initCalendarViewCntrl];
    
    self.remindersTableViewController = [[spnTableViewController_BillReminders alloc] initWithStyle:UITableViewStyleGrouped];
    [self initRemindersViewCntrl];
    
    // Navigation Controllers
    UINavigationController* summaryNavController = [[UINavigationController alloc] initWithRootViewController:self.summaryViewController];
    UINavigationController* categoryTableNavController = [[UINavigationController alloc] initWithRootViewController:self.categoryTableViewController];
    UINavigationController* allTransTableNavController = [[UINavigationController alloc] initWithRootViewController:self.allTransTableViewController];
    UINavigationController* calendarNavController = [[UINavigationController alloc] initWithRootViewController:self.calendarViewController];
    UINavigationController* remindersNavController = [[UINavigationController alloc] initWithRootViewController:self.remindersTableViewController];
    NSArray* navControllerArray = [NSArray arrayWithObjects:summaryNavController, categoryTableNavController, allTransTableNavController, calendarNavController, remindersNavController, nil];
    
    // Setup Summary Tab
    UITabBarItem* summaryTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Summary" image:[UIImage imageNamed:@"pie-chart-7.png"] tag:TAB_BAR_SUMMARY_INEDX+1];
    summaryNavController.tabBarItem = summaryTabBarItem;
    
    // Setup Categories Tab
    UITabBarItem* catTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Categories" image:[UIImage imageNamed:@"folder-7.png"] tag:TAB_BAR_CATEGORIES_INDEX+1];
    categoryTableNavController.tabBarItem = catTabBarItem;
    
    // Setup Transactions Tab
    UITabBarItem* trnsTabBarItem = [[UITabBarItem alloc] initWithTitle:@"List" image:[UIImage imageNamed:@"list-fat-7.png"] tag:TAB_BAR_TRANSACTIONS_INDEX+1];
    allTransTableNavController.tabBarItem = trnsTabBarItem;
    
    // Setup Calendar Tab
    UITabBarItem* calTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Calendar" image:[UIImage imageNamed:@"calendar-7.png"] tag:TAB_BAR_CALENDAR_INDEX+1];
    calendarNavController.tabBarItem = calTabBarItem;
    
    // Setup Reminders Tab
    UITabBarItem* reminderTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Bills" image:[UIImage imageNamed:@"paper-piece-tick-7.png"] tag:TAB_BAR_REMINDERS_INDEX+1];
    remindersNavController.tabBarItem = reminderTabBarItem;
    
    // Setup Tab Bar Control - set as root view controller
    self.mainTabBarController.viewControllers = navControllerArray;
    self.rootViewController = self.mainTabBarController;
    
    // Record the datestamp on which the view controllers were initialized
    self.dateViewCntlLoaded = [NSDate date];
}

- (void)initSummaryViewCntrl
{
    [self.summaryViewController setTitle:@"Summary"];
    [self.summaryViewController setManagedObjectContext:self.managedObjectContext];
}

- (void)initCategoriesViewCntrl
{
    [self.categoryTableViewController setTitle:@"One Month's Categories"];
    [self.categoryTableViewController setStartDate:[[NSDate date] offsetDay:-30]];
    [self.categoryTableViewController setEndDate:[NSDate dateStartOfDay:[[NSDate date] offsetDay:1]]];
    [self.categoryTableViewController setManagedObjectContext:self.managedObjectContext];}

- (void)initTransactionsViewCntrl
{
    [self.allTransTableViewController setTitle:@"All Transactions"];
    [self.allTransTableViewController setCategoryTitles:nil];
    [self.allTransTableViewController setSubCategoryTitles:nil];
    [self.allTransTableViewController setMerchantTitles:nil];
    [self.allTransTableViewController setStartDate:nil];
    [self.allTransTableViewController setEndDate:[NSDate dateStartOfDay:[[NSDate date] offsetDay:1]]];
    [self.allTransTableViewController setManagedObjectContext:self.managedObjectContext];
}

- (void)initCalendarViewCntrl
{
    [self.calendarViewController setTitle:@"Calendar"];
    [self.calendarViewController setManagedObjectContext:self.managedObjectContext];
    [self.calendarViewController setTableViewDelegate:self.calendarViewController];
    [self.calendarViewController setCalendarDataSource:self.calendarViewController];
    [self.calendarViewController setMinAvailableDate:[NSDate dateStartOfDay:[[NSDate date] offsetYear:-3]]];
    [self.calendarViewController setMaxAvailableDate:[NSDate dateStartOfDay:[[NSDate date] offsetYear:3]]];
    [self.calendarViewController setBeginDate:[NSDate dateStartOfDay:[NSDate date]]];
    [self.calendarViewController setEndDate:[NSDate dateStartOfDay:[[NSDate date] offsetDay:1]]];
    [self.calendarViewController setPreferredDate:self.calendarViewController.beginDate];
}

- (void)initRemindersViewCntrl
{
    [self.remindersTableViewController setTitle:@"Bill Reminders"];
    [self.remindersTableViewController setManagedObjectContext:self.managedObjectContext];
}

#pragma mark - Context

- (void)saveContext:(NSManagedObjectContext*)managedObjectContext
{
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Local Notifications

- (void)initLocalNotifications
{
//    
//    // Define action for "Mark Paid"
//    UIMutableUserNotificationAction *paidAction = [[UIMutableUserNotificationAction alloc] init];
//    paidAction.identifier = @"PAID_IDENTIFIER";
//    paidAction.title = @"Mark Paid";
//    paidAction.activationMode = UIUserNotificationActivationModeBackground;
//    paidAction.destructive = NO;
//    paidAction.authenticationRequired = NO;
//    
//    // Define reminder category
//    UIMutableUserNotificationCategory *reminderCategory = [[UIMutableUserNotificationCategory alloc] init];
//    reminderCategory.identifier = @"REMINDER_CATEGORY";
//    
//    // Add the actions to the category and set the action context (modal)
//    [reminderCategory setActions:@[paidAction] forContext:UIUserNotificationActionContextDefault];
//    
//    // Set the actions to present in a minimal context (lock screen)
//    [reminderCategory setActions:@[paidAction] forContext:UIUserNotificationActionContextMinimal];
//    
//    // Add the categories to the notification settings
//    NSSet *categories = [NSSet setWithObject:reminderCategory];
//    
    // Register for notifications
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
//    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    // Register the settings with the app
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
}

- (void)addLocalNotificationWithID:(NSNumber*)uniqueID alertBody:(NSString*)alertBody fireDate:(NSDate*)fireDate
{
    UILocalNotification* notification = [[UILocalNotification alloc] init];
    notification.fireDate = fireDate;
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.alertBody = alertBody;
    notification.alertAction = nil;
    notification.applicationIconBadgeNumber = 0; // this will be computed in renumberBadgesOfPendingNotifications
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = [[NSDictionary alloc] initWithObjects:@[[uniqueID copy]] forKeys:@[@"uniqueID"]];
    notification.repeatCalendar = [NSCalendar currentCalendar];
    notification.repeatInterval = 0; // Don't repeat
    notification.category = @"REMINDER_CATEGORY";
    
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    // Recompute badge numbers - the delay accounts for the fact that scheduleLocalNotification isn't atomic and probably happens at the end of the current run loop
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.100 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self renumberBadgesOfPendingNotifications];
    });
}

- (void)processLocalNotification:(UILocalNotification*)notification withActionIdentifier:(NSString*)identifier
{
    // Get the unique identifer associated with the notification
    NSNumber* uniqueID = [notification.userInfo valueForKey:@"uniqueID"];

    // Fetch all bill pay reminders
    NSError* error;
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnBillReminderMO"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uniqueID.integerValue == %lu", uniqueID.integerValue];
    
    // Should be at most 1
    NSArray* fetchedReminders = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedReminders.count)
    {
//        for (SpnBillReminder* remind in fetchedReminders)
//        {
//            NSLog(@"hit - %@: %lu", remind.merchant, remind.uniqueID.integerValue);
//        }
        
        [self.mainTabBarController setSelectedIndex:TAB_BAR_REMINDERS_INDEX];
    }
}

- (void)deleteLocalNotificationWithUniqueID:(NSNumber*)uniqueID
{
    // List all notifications
    NSArray* notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    // Get the ID of the notification to delete
    NSNumber* thisUniqueID = uniqueID;
    
    // Search for this notification in the list of all notifications
    UILocalNotification* thisNotification = nil;
    for(UILocalNotification* notification in notifications)
    {
        NSNumber* notificationID = [notification.userInfo objectForKey:@"uniqueID"];
        if(notificationID.integerValue == thisUniqueID.integerValue)
        {
            thisNotification = notification;
            break;
        }
    }
    
    // if one was found, it's still in its unfired state
    if (thisNotification)
    {
        [[UIApplication sharedApplication] cancelLocalNotification:thisNotification];
//        NSLog(@"notification canceled: %@", thisNotification.fireDate);
        
        // Recompute badge numbers
        [[spnSpendTracker sharedManager] renumberBadgesOfPendingNotifications];
    }
}

- (void)renumberBadgesOfPendingNotifications
{
    // clear the badge on the icon
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // first get a copy of all pending notifications (unfortunately you cannot 'modify' a pending notification)
    // Sort the pending notifications first by their fireDate
    NSArray *pendingNotifications = [[[UIApplication sharedApplication] scheduledLocalNotifications] sortedArrayUsingComparator:^(id obj1, id obj2) {
        if ([obj1 isKindOfClass:[UILocalNotification class]] && [obj2 isKindOfClass:[UILocalNotification class]])
        {
            UILocalNotification *notif1 = (UILocalNotification *)obj1;
            UILocalNotification *notif2 = (UILocalNotification *)obj2;
            return [notif1.fireDate compare:notif2.fireDate];
        }
        
        return NSOrderedSame;
    }];
    
    // if there are any pending notifications -> adjust their badge number
    if (pendingNotifications.count != 0)
    {
        // clear all pending notifications
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        // the for loop will 'restore' the pending notifications, but with corrected badge numbers accounting for the present badge number
        NSUInteger badgeNbr = 1 + [[UIApplication sharedApplication] applicationIconBadgeNumber];
        
        for (UILocalNotification *notification in pendingNotifications)
        {
            // modify the badgeNumber
            notification.applicationIconBadgeNumber = badgeNbr;
            badgeNbr++;
            
            // schedule 'again'
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//            NSLog(@"notification scheduled: %@, Badge: %lu", notification.fireDate, notification.applicationIconBadgeNumber);
        }
    }
}

#pragma mark - Recurrences

- (void)updateAllRecurrences
{
    NSError* error;
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnRecurrenceMO"];
    
    // Get all recurrences from the managed object context
    NSArray *recurrencesArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Call the extend routine on them all. Transactions will be created if they don't already exist
    [recurrencesArray makeObjectsPerformSelector:@selector(extendSeries)];
    
    // Save changes
    [self saveContext:self.managedObjectContext];
}

#pragma mark - Transactions

- (SpnTransaction*)createTransactionWithType:(enumSpnTransactionType)transactionType
{
    SpnTransaction* newTransaction = [[SpnTransaction alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnTransactionMO" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    
    // Perform additional initialization.
    [newTransaction setMerchant:@""];
    [newTransaction setNotes:@""];
    [newTransaction setValue:@(0.00)];
    [newTransaction setType:@(transactionType)];
    
    return newTransaction;
}

- (void)deleteTransaction:(SpnTransaction*)transaction
{
    // Remove the reminder object
    [self.managedObjectContext deleteObject:transaction];
    
    // Save context
    [self saveContext:self.managedObjectContext];
}

#pragma mark - Bill Reminders

- (void)updateAllReminders
{
    NSError* error;
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnBillReminderMO"];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"dateDue <= %@", [NSDate date]];
    [fetchRequest setPredicate:predicate];
    
    // Get all reminders that are past due from the managed object context
    NSArray *remindersArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Set them to unpaid if they are recurring. Set them to unpaid if they are one-off reminders AND they are not marked paid.
    for (SpnBillReminder* reminder in remindersArray)
    {
        if (reminder.frequency != nil)
        {
            [reminder setPaidStatusRaw:@(PAID_STATUS_UNPAID)];
//            NSLog(@"updateAllReminders - marked %@ Unpaid", reminder.merchant);
        }
        else
        {
            if (reminder.paidStatus != PAID_STATUS_PAID)
            {
                [reminder setPaidStatusRaw:@(PAID_STATUS_UNPAID)];
//                NSLog(@"updateAllReminders - marked %@ Unpaid", reminder.merchant);
            }
        }
    }
    
    // Look for the notification associated with each respective past due reminder and fire it immediately
    NSArray *pendingNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification* notification in pendingNotifications)
    {
        for (SpnBillReminder* reminder in remindersArray)
        {
            NSNumber* notificationID = [notification.userInfo valueForKey:@"uniqueID"];
            if (notificationID.integerValue == reminder.uniqueID.integerValue)
            {
                // This dispatch delay accounts for a race condition - special case where the notification is scheduled, it is already due, and the reminder list is refreshed immediately. The system doesn't schedule notifications atomically so the delay is necessary.
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.100 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    NSLog(@"Present it now!");
                    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                    [[UIApplication sharedApplication] cancelLocalNotification:notification];
                });
            }
        }
    }
    
    // Take care of badges - this is to address any bugs in which a badge icon is set with no unpaid bill
    predicate = [NSPredicate predicateWithFormat:@"paidStatusRaw == %@", @(PAID_STATUS_UNPAID)];
    [fetchRequest setPredicate:predicate];
    remindersArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (remindersArray.count == 0)
    {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
    // Manage badge of tab bar icon
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] != 0)
    {
        // Set badge count in tab bar item
        ((UINavigationController*)self.mainTabBarController.viewControllers[4]).tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu", (long)[[UIApplication sharedApplication] applicationIconBadgeNumber]];
    }
    else
    {
        // Clear the badge count in tab bar item
        ((UINavigationController*)self.mainTabBarController.viewControllers[4]).tabBarItem.badgeValue = nil;
    }
    
    
    // Save changes
    [self saveContext:self.managedObjectContext];
}

- (void)billReminder:(SpnBillReminder*)reminder setPaidStatus:(enumBillReminderPaidStatus)paidStatus
{
    switch (paidStatus)
    {
        case PAID_STATUS_UNPAID:
        {
            if (reminder.paidStatus != PAID_STATUS_UNPAID)
            {
                // badge increments for every time a bill transitions to unpaid from paid/none
                NSInteger currentBadgeNum = [[UIApplication sharedApplication] applicationIconBadgeNumber];
                NSInteger newBadgeNum = currentBadgeNum+1;
                
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:newBadgeNum];
                
                // We should readjust pending notification badges settings after manually changing the badge count
                [self renumberBadgesOfPendingNotifications];
            }
        }
            break;
            
        case PAID_STATUS_NONE:
        case PAID_STATUS_PAID:
        {
            if (reminder.paidStatus == PAID_STATUS_UNPAID)
            {
                // bill is unpaid so we need to decrement the badge number first. Assumes that a badge increments for every time a bill transitions to unpaid
                NSInteger currentBadgeNum = [[UIApplication sharedApplication] applicationIconBadgeNumber];
                NSInteger newBadgeNum = MAX(0, currentBadgeNum-1); // protect against negative
                
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:newBadgeNum];
                
                // We should readjust pending notification badges settings after manually changing the badge count
                [self renumberBadgesOfPendingNotifications];
            }
        }
            break;
            
        default:
            break;
    }
    
    // Finally, set the status
    reminder.paidStatus = paidStatus;
}

- (SpnBillReminder*)createBillReminder
{
    SpnBillReminder* newReminder = [[SpnBillReminder alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnBillReminderMO" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    
    // Perform additional initialization.
    [newReminder setMerchant:@""];
    [newReminder setNotes:@""];
    [newReminder setValue:[NSNumber numberWithFloat:0.00]];
    [newReminder setPaidStatus:PAID_STATUS_NONE];
    
    return newReminder;
}

- (void)deleteBillReminder:(SpnBillReminder*)reminder
{
    // First mark bill as paid
    [self billReminder:reminder setPaidStatus:PAID_STATUS_PAID];
    
    // Delete the notification in case it still is pending
    [self deleteLocalNotificationWithUniqueID:reminder.uniqueID];
    
    // Remove the reminder object
    [self.managedObjectContext deleteObject:reminder];
    
    // Save context
    [self saveContext:self.managedObjectContext];
}

- (void)markBillReminderAsPending:(SpnBillReminder*)reminder
{
    // First mark bill as pending
    [self billReminder:reminder setPaidStatus:PAID_STATUS_NONE];
    
    // Save context
    [self saveContext:self.managedObjectContext];
}

- (void)markBillReminderAsUnpaid:(SpnBillReminder*)reminder
{
    // First mark bill as unpaid
    [self billReminder:reminder setPaidStatus:PAID_STATUS_UNPAID];
    
    // Save context
    [self saveContext:self.managedObjectContext];
}

- (void)markBillReminderAsPaid:(SpnBillReminder*)reminder
{
    // First mark bill as paid
    [self billReminder:reminder setPaidStatus:PAID_STATUS_PAID];
    
    // Delete pending notification by ID, in case it still exists
    [self deleteLocalNotificationWithUniqueID:reminder.uniqueID];
    
    // Save context
    [self saveContext:self.managedObjectContext];
}

@end
