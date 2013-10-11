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
#import "spnAddController.h"
#import "Transaction.h"
#import "SpendCategory.h"

@interface spnSpendTracker ()

@end

@implementation spnSpendTracker

static spnSpendTracker *sharedSpendTracker = nil;

+ (spnSpendTracker*)sharedManager
{
    if (sharedSpendTracker == nil) {
        sharedSpendTracker = [[super alloc] init];
        
        sharedSpendTracker.categories = [[NSMutableDictionary alloc] init];
    }
    return sharedSpendTracker;
}

- (void)initViews
{
    // View Controllers
    UITabBarController* mainTabBarController = [[UITabBarController alloc] init];
    spnViewController_Home* homeViewController = [[spnViewController_Home alloc] init];
    [homeViewController setTitle:@"Summary"];
    spnTableViewController_Categories* categoryTableViewController = [[spnTableViewController_Categories alloc] initWithStyle:UITableViewStyleGrouped];
    [categoryTableViewController setTitle:@"Categories"];
    [categoryTableViewController setManagedObjectContext:self.managedObjectContext];
    
    // Navigation Controllers
    UINavigationController* homeNavController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    UINavigationController* tableNavController = [[UINavigationController alloc] initWithRootViewController:categoryTableViewController];
    NSArray* navControllerArray = [NSArray arrayWithObjects:homeNavController, tableNavController, nil];
    
    // Setup Home Tab
    UITabBarItem* homeTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:0];
    homeNavController.tabBarItem = homeTabBarItem;
    
    // Setup Category Tab
    UITabBarItem* catTabBarItem = [[UITabBarItem alloc] initWithTitle:@"$" image:nil tag:1];
    tableNavController.tabBarItem = catTabBarItem;
    
    // Setup Tab Bar Control - set as root view controller
    mainTabBarController.viewControllers = navControllerArray;
    self.rootViewController = mainTabBarController;
    
    // Setup Data
    self.categories = [[NSMutableDictionary alloc] init];
}


- (SpendCategory*)fetchCategory:(NSString*)categoryName
{
    NSError *error = nil;
    SpendCategory* category = nil;
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SpendCategory"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SpendCategory"inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", categoryName];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext                                                executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if (mutableFetchResults == nil)
    {
        // Error
    }
    else
    {
        // Target category was found
        if([mutableFetchResults count] != 0)
        {
            // add the entry
            category = [mutableFetchResults objectAtIndex:0];
        }
    }
    
    return category;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)addTransaction:(Transaction*)entry forCategory:(NSString*)targetCategory
{
    // If an entry was specified
    if(entry)
    {
        SpendCategory* category = [self fetchCategory:targetCategory];
        
        // Category not found - add a new one
        if(!category)
        {
            // Create new category then add the entry
            category = (SpendCategory*)[NSEntityDescription                                                  insertNewObjectForEntityForName:@"SpendCategory"                                                  inManagedObjectContext:self.managedObjectContext];
            [category setTitle:targetCategory];
            [category setTotal:entry.value];
        }
        else // Target category was found
        {
            // add the entry value to the total
            [category setTotal:[NSNumber numberWithFloat:(category.total.floatValue + entry.value.floatValue)]];
        }
        
        [category addTransactionsObject:entry];
        [category setLastModifiedDate:[NSDate date]];
        
        //NSLog(@"Category count after: %lu", (unsigned long)[mutableFetchResults count]);
        //NSLog(@"Transaction count after: %lu", (unsigned long)category.transactions.count);
        
        [self saveContext];
    }
}

- (void)deleteTransaction:(Transaction*)entry fromCategory:(NSString*)targetCategory
{
    // If an entry was specified
    if(entry)
    {
        // Find target category
        SpendCategory* category = [self fetchCategory:targetCategory];
        
        // If a category was found
        if(category)
        {
            [category setTotal:[NSNumber numberWithFloat:(category.total.floatValue - entry.value.floatValue)]];
            [category removeTransactionsObject:entry];
            [category setLastModifiedDate:[NSDate date]];
        }
        
        [self saveContext];
    }
}


@end
