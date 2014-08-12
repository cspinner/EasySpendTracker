//
//  spnSpendTracker.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/27/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnSpendTracker.h"
#import "spnViewController_Home.h"
#import "spnTableViewController_MainCategories.h"
#import "spnTableViewController_Transactions.h"
#import "SpnRecurrence.h"

@interface spnSpendTracker ()

@property UITabBarController* mainTabBarController;
@property spnViewController_Home* homeViewController;
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
    
    self.homeViewController = [[spnViewController_Home alloc] init];
    [self initHomeViewCntrl];
    
    self.categoryTableViewController = [[spnTableViewController_MainCategories alloc] initWithStyle:UITableViewStyleGrouped];
    [self initCategoriesViewCntrl];
    
    self.allTransTableViewController = [[spnTableViewController_Transactions alloc] initWithStyle:UITableViewStyleGrouped];
    [self initTransactionsViewCntrl];
    
    // Navigation Controllers
    UINavigationController* homeNavController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    UINavigationController* categoryTableNavController = [[UINavigationController alloc] initWithRootViewController:self.categoryTableViewController];
    UINavigationController* allTransTableNavController = [[UINavigationController alloc] initWithRootViewController:self.allTransTableViewController];
    NSArray* navControllerArray = [NSArray arrayWithObjects:homeNavController, categoryTableNavController, allTransTableNavController, nil];
    
    // Setup Home Tab
    UITabBarItem* homeTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:0];
    homeNavController.tabBarItem = homeTabBarItem;
    
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

- (void)initHomeViewCntrl
{
    [self.homeViewController setTitle:@"Summary"];
    [self.homeViewController setManagedObjectContext:self.managedObjectContext];
}

- (void)initCategoriesViewCntrl
{
    [self.categoryTableViewController setTitle:@"Categories"];
    [self.categoryTableViewController setManagedObjectContext:self.managedObjectContext];
}

- (void)initTransactionsViewCntrl
{
    [self.allTransTableViewController setTitle:@"All Transactions"];
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
