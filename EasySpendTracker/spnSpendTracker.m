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
#import "spnViewController_Calendar.h"
#import "SpnRecurrence.h"

@interface spnSpendTracker ()

@property UITabBarController* mainTabBarController;
@property spnTableViewController_Summary* summaryViewController;
@property spnTableViewController_MainCategories* categoryTableViewController;
@property spnTableViewController_Transactions* allTransTableViewController;
@property spnViewController_Calendar* calendarViewController;

@end

@implementation spnSpendTracker

static spnSpendTracker *sharedSpendTracker = nil;

+ (spnSpendTracker*)sharedManager
{
    if (sharedSpendTracker == nil) {
        sharedSpendTracker = [[super alloc] init];
    }
    return sharedSpendTracker;
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
    
    // Navigation Controllers
    UINavigationController* summaryNavController = [[UINavigationController alloc] initWithRootViewController:self.summaryViewController];
    UINavigationController* categoryTableNavController = [[UINavigationController alloc] initWithRootViewController:self.categoryTableViewController];
    UINavigationController* allTransTableNavController = [[UINavigationController alloc] initWithRootViewController:self.allTransTableViewController];
    UINavigationController* calendarNavController = [[UINavigationController alloc] initWithRootViewController:self.calendarViewController];
    NSArray* navControllerArray = [NSArray arrayWithObjects:summaryNavController, categoryTableNavController, allTransTableNavController, calendarNavController, nil];
    
    // Setup Summary Tab
    UITabBarItem* summaryTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Summary" image:nil tag:0];
    summaryNavController.tabBarItem = summaryTabBarItem;
    
    // Setup Categories Tab
    UITabBarItem* catTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Categories" image:nil tag:1];
    categoryTableNavController.tabBarItem = catTabBarItem;
    
    // Setup Transactions Tab
    UITabBarItem* trnsTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Transactions" image:nil tag:2];
    allTransTableNavController.tabBarItem = trnsTabBarItem;
    
    // Setup Calendar Tab
    UITabBarItem* calTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Calendar" image:nil tag:3];
    calendarNavController.tabBarItem = calTabBarItem;
    
    // Setup Tab Bar Control - set as root view controller
    self.mainTabBarController.viewControllers = navControllerArray;
    self.rootViewController = self.mainTabBarController;
}

- (void)initSummaryViewCntrl
{
    [self.summaryViewController setTitle:@"Summary"];
    [self.summaryViewController setManagedObjectContext:self.managedObjectContext];
}

- (void)initCategoriesViewCntrl
{
    [self.categoryTableViewController setTitle:@"Categories This Month"];
    [self.categoryTableViewController setStartDate:nil];
    [self.categoryTableViewController setEndDate:nil];
    [self.categoryTableViewController setManagedObjectContext:self.managedObjectContext];
}

- (void)initTransactionsViewCntrl
{
    [self.allTransTableViewController setTitle:@"All Transactions"];
    [self.allTransTableViewController setCategoryTitle:nil];
    [self.allTransTableViewController setSubCategoryTitle:nil];
    [self.allTransTableViewController setStartDate:nil];
    [self.allTransTableViewController setEndDate:nil];
    [self.allTransTableViewController setManagedObjectContext:self.managedObjectContext];
    [self.allTransTableViewController setCategoryTitle:@"*"];
}

- (void)initCalendarViewCntrl
{
    [self.calendarViewController setTitle:@"Calendar View"];
    [self.calendarViewController setManagedObjectContext:self.managedObjectContext];
}

- (void)updateAllRecurrences
{
    NSError* error;
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnRecurrenceMO"];
    
    // Get all recurrences from the managed object context
    NSArray *recurrencesArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Call the extend routine on them all. Transactions will be created through the end of the month, if they don't already exist
    [recurrencesArray makeObjectsPerformSelector:@selector(extendSeriesThroughToday)];
    
    // Save changes
    [self saveContext:self.managedObjectContext];
}

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


@end
