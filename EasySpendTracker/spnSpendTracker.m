//
//  spnSpendTracker.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/27/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnSpendTracker.h"
#import "spnViewController_Home.h"
#import "spnTableViewController_Categories.h"

@interface spnSpendTracker ()

@property UITabBarController* mainTabBarController;
@property spnViewController_Home* homeViewController;
@property spnTableViewController_Categories* categoryTableViewController;

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
    
    self.categoryTableViewController = [[spnTableViewController_Categories alloc] initWithStyle:UITableViewStyleGrouped];
    [self initCategoriesViewCntrl];
    
    // Navigation Controllers
    UINavigationController* homeNavController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    UINavigationController* tableNavController = [[UINavigationController alloc] initWithRootViewController:self.categoryTableViewController];
    NSArray* navControllerArray = [NSArray arrayWithObjects:homeNavController, tableNavController, nil];
    
    // Setup Home Tab
    UITabBarItem* homeTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:0];
    homeNavController.tabBarItem = homeTabBarItem;
    
    // Setup Category Tab
    UITabBarItem* catTabBarItem = [[UITabBarItem alloc] initWithTitle:@"$" image:nil tag:1];
    tableNavController.tabBarItem = catTabBarItem;
    
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


@end
