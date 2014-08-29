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
#import "SpnRecurrence.h"

@interface spnSpendTracker ()

@property UITabBarController* mainTabBarController;
@property spnTableViewController_Summary* summaryViewController;
@property spnTableViewController_MainCategories* categoryTableViewController;
@property spnTableViewController_Transactions* allTransTableViewController;

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
    
    // Navigation Controllers
    UINavigationController* summaryNavController = [[UINavigationController alloc] initWithRootViewController:self.summaryViewController];
    UINavigationController* categoryTableNavController = [[UINavigationController alloc] initWithRootViewController:self.categoryTableViewController];
    UINavigationController* allTransTableNavController = [[UINavigationController alloc] initWithRootViewController:self.allTransTableViewController];
    NSArray* navControllerArray = [NSArray arrayWithObjects:summaryNavController, categoryTableNavController, allTransTableNavController, nil];
    
    // Setup Summary Tab
    UITabBarItem* summaryTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Summary" image:nil tag:0];
    summaryNavController.tabBarItem = summaryTabBarItem;
    
    // Setup Categories Tab
    UITabBarItem* catTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Categories" image:nil tag:1];
    categoryTableNavController.tabBarItem = catTabBarItem;
    
    // Setup Transactions Tab
    UITabBarItem* trnsTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Transactions" image:nil tag:2];
    allTransTableNavController.tabBarItem = trnsTabBarItem;
    
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
    [self.categoryTableViewController setTitle:@"Categories"];
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

- (void)updateAllRecurrences
{
    NSError* error;
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnRecurrenceMO"];
    
    // Get all recurrences from the managed object context
    NSArray *recurrencesArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Call the extend routine on them all. Transactions will be created through the end of the month, if they don't already exist
    [recurrencesArray makeObjectsPerformSelector:@selector(extendSeriesThroughEndOfMonth)];
}


@end
