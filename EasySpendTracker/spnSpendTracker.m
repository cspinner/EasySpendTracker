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
#import "SpnTransaction.h"
#import "SpnSpendCategory.h"

@interface spnSpendTracker ()

@end

@implementation spnSpendTracker

static spnSpendTracker *sharedSpendTracker = nil;
static NSDateFormatter* sharedDateFormatterMonthDayYear;
static NSDateFormatter* sharedDateFormatterMonthYear;
static NSDateFormatter* sharedDateFormatterMonth;

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
    [categoryTableViewController setMonth:[self fetchMonth:[NSDate date]]];
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

- (SpnMonth*)fetchMonth:(NSDate*)date
{
    NSError *error = nil;
    SpnMonth* month = nil;
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SpnMonth"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SpnMonth"inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sectionName == %@", [self.dateFormatterMonthYear stringFromDate:date]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext                                                executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if (mutableFetchResults == nil)
    {
        // Error
    }
    else
    {
        // Target month was found
        if([mutableFetchResults count] != 0)
        {
            // set the return value
            month = [mutableFetchResults objectAtIndex:0];
        }
    }
    
    return month;
}

- (SpnSpendCategory*)fetchCategory:(NSString*)categoryName inMonth:(SpnMonth*)month
{
    NSError *error = nil;
    SpnSpendCategory* category = nil;
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SpnSpendCategory"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SpnSpendCategory"inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title == %@) AND (month == %@)", categoryName, month];
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
            // set the return value
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

- (NSDateFormatter*)dateFormatterMonthDayYear
{
    if (sharedDateFormatterMonthDayYear == nil)
    {
        sharedDateFormatterMonthDayYear = [[NSDateFormatter alloc] init];
        [sharedDateFormatterMonthDayYear setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"yyyyMd" options:0 locale:[NSLocale currentLocale]]];
    }
    
    return sharedDateFormatterMonthDayYear;
}

- (NSDateFormatter*)dateFormatterMonth
{
    if (sharedDateFormatterMonth == nil)
    {
        sharedDateFormatterMonth = [[NSDateFormatter alloc] init];
        [sharedDateFormatterMonth setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"MMMM" options:0 locale:[NSLocale currentLocale]]];
    }
    
    return sharedDateFormatterMonth;
}

- (NSDateFormatter*)dateFormatterMonthYear
{
    if (sharedDateFormatterMonthYear == nil)
    {
        sharedDateFormatterMonthYear = [[NSDateFormatter alloc] init];
        [sharedDateFormatterMonthYear setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"MMMyyyy" options:0 locale:[NSLocale currentLocale]]];
    }
    
    return sharedDateFormatterMonthYear;
}

- (void)addTransaction:(SpnTransaction*)entry forCategory:(NSString*)targetCategory
{
    // If an entry was specified
    if(entry)
    {
        SpnMonth* month = [self fetchMonth:entry.date];
        
        // Month not found - add a new one
        if(!month)
        {
            // Create new month
            month = (SpnMonth*)[NSEntityDescription                                                  insertNewObjectForEntityForName:@"SpnMonth"                                                  inManagedObjectContext:self.managedObjectContext];
            [month setDate:entry.date];
            [month setSectionName:[self.dateFormatterMonthYear stringFromDate:entry.date]];
            [month setTotalExpenses:[NSNumber numberWithFloat:0.00]];
            [month setTotalIncome:[NSNumber numberWithFloat:0.00]];
        }
        
        SpnSpendCategory* category = [self fetchCategory:targetCategory inMonth:month];
        
        // Category not found - add a new one
        if(!category)
        {
            // Create new category then add the entry
            category = (SpnSpendCategory*)[NSEntityDescription                                                  insertNewObjectForEntityForName:@"SpnSpendCategory"                                                  inManagedObjectContext:self.managedObjectContext];
            [category setTitle:targetCategory];
            [category setTotal:entry.value];
            
            // add the new category to the month
            [month addCategoriesObject:category];
        }
        else // Target category was found
        {
            // add the entry value to the total
            [category setTotal:[NSNumber numberWithFloat:(category.total.floatValue + entry.value.floatValue)]];
        }
        
        [month setTotalExpenses:[NSNumber numberWithFloat:(month.totalExpenses.floatValue + entry.value.floatValue)]];
        
        [category addTransactionsObject:entry];
        [category setLastModifiedDate:[NSDate date]];
        
        //NSLog(@"Category count after: %lu", (unsigned long)[mutableFetchResults count]);
        //NSLog(@"Transaction count after: %lu", (unsigned long)category.transactions.count);
        
        [self saveContext];
    }
}

- (void)deleteTransaction:(SpnTransaction*)entry fromCategory:(NSString*)targetCategory
{
    // If an entry was specified
    if(entry)
    {
        // Find target category
        SpnSpendCategory* category = [self fetchCategory:targetCategory inMonth:[self fetchMonth:entry.date]];
        
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
