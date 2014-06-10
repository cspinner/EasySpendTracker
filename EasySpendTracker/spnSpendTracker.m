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
#import "SpnSpendCategory.h"
//#import "SpnMonth.h"
#import "spnUtils.h"
//#import "spnViewController_Months.h"

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
//    SpnMonth* month = [SpnMonth fetchMonthWithDate:[NSDate date] inManagedObjectContext:self.managedObjectContext];
    NSError *error;
    
    [self.categoryTableViewController setManagedObjectContext:self.managedObjectContext];
    [self.categoryTableViewController setDelegate:self];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnSpendCategoryMO"];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"lastModifiedDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    
    [NSFetchedResultsController deleteCacheWithName:@"CacheCategories"];
    [self.categoryTableViewController setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.categoryTableViewController.managedObjectContext sectionNameKeyPath:nil cacheName:@"CacheCategories"]];
    
    [self.categoryTableViewController.fetchedResultsController setDelegate:self.categoryTableViewController];
//    [self monthChange:month];
    

    if (![self.categoryTableViewController.fetchedResultsController performFetch:&error])
    {
        // Update to handle the error appropriately.
        NSLog(@"Category Fetch Error: %@, %@", error, [error userInfo]);
        exit(-1);
    }
    
    [self.categoryTableViewController setTitle:@"Categories"];
}
//
//- (void)monthSelect
//{
//    // Create and Push month selector view controller
//    spnViewController_Months* monthsTableViewController = [[spnViewController_Months alloc] initWithStyle:UITableViewStyleGrouped];
//    [monthsTableViewController setTitle:@"Select Month"];
//    [monthsTableViewController setManagedObjectContext:self.managedObjectContext];
//    [monthsTableViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
//    
//    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:monthsTableViewController];
//    
//    monthsTableViewController.delegate = self;
//    
//    [self.categoryTableViewController presentViewController:navController animated:YES completion:nil];
//}
//
//- (void)closeMonthViewCntrl
//{
//    [[self.categoryTableViewController navigationController] dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)monthChange:(SpnMonth*)newMonth
//{
//    if(newMonth)
//    {
//        // Delete results controller cache file before modifying the predicate
//        [NSFetchedResultsController deleteCacheWithName:@"CacheCategories"];
//        
//        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"month == %@", newMonth];
//        [[self.categoryTableViewController.fetchedResultsController fetchRequest] setPredicate:predicate];
//        
//        NSError *error;
//        if (![self.categoryTableViewController.fetchedResultsController performFetch:&error])
//        {
//            // Update to handle the error appropriately.
//            NSLog(@"Category Fetch Error: %@, %@", error, [error userInfo]);
//            exit(-1);
//        }
//        
//        [self.categoryTableViewController setTitle:[[[spnUtils sharedUtils] dateFormatterMonthYear] stringFromDate:newMonth.date]];
//    }
//}


@end
