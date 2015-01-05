//
//  spnAppDelegate.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/21/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnAppDelegate.h"
#import "spnSpendTracker.h"
#import "NSDate+Convenience.h"
#import <UIKit/UIKit.h>

@interface spnAppDelegate ()


@end

@implementation spnAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIScreen *mainScreen = [UIScreen mainScreen];
//    NSLog(@"Screen bounds: %@, Screen resolution: %@, scale: %f, nativeScale: %f", NSStringFromCGRect(mainScreen.bounds), mainScreen.coordinateSpace, mainScreen.scale, mainScreen.nativeScale);
    
    self.window = [[UIWindow alloc] initWithFrame:mainScreen.bounds];
    // Override point for customization after application launch.
    
    NSManagedObjectContext *context = [self managedObjectContext];
    if (!context) {
        // Handle the error.
    }
    
    // main data object (singleton)
    spnSpendTracker* spendTracker = [spnSpendTracker sharedManager];
    spendTracker.managedObjectContext = context;
    [spendTracker initViews];
    [spendTracker initLocalNotifications];
    
    // Notifications -
    // The user taps the default button in the alert or taps (or clicks) the app icon.
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification)
    {
//        application.applicationIconBadgeNumber = notification.applicationIconBadgeNumber-1;
//        NSLog(@"Launch options: %@", notification.alertBody);
        [[spnSpendTracker sharedManager] processLocalNotification:notification withActionIdentifier:nil];
    }
//    [application cancelAllLocalNotifications];
    
    self.window.rootViewController = spendTracker.rootViewController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // Many of the view controllers will display content based on a start and end date that is set when the view controllers are loaded for the first time. If the app has been lingering in background across a day's boundary, the view controllers will need to be reloaded so they can account for the date change.
    if ([spnSpendTracker sharedManager].dateViewCntlLoaded.day != [NSDate date].day)
    {
        [[spnSpendTracker sharedManager] initViews];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // This was added because exceptions were occuring when the app entered background with the "add" view active, which had a pending transaction/reminder object. Invoking either of these when the app re-entered foreground and became active stomped over the active context
    if ([self.managedObjectContext hasChanges] == NO)
    {
        [[spnSpendTracker sharedManager] updateAllRecurrences];
        [[spnSpendTracker sharedManager] updateAllReminders];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
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

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"EasySpendTracker" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"EasySpendTracker.sqlite"];
    
    NSError *error = nil;
    NSDictionary *options =
    [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
        [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
        nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
//    NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject]);
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Notifications
// Notifications -
// Called when the user taps a custom action button in an iOS 8 notification.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
//    NSLog(@"Button pressed - Notification handled: %@ with identifier: %@", notification.alertBody, identifier);
    [[spnSpendTracker sharedManager] processLocalNotification:notification withActionIdentifier:identifier];
    completionHandler();
}

// Called when the notification is delivered when the app is running in the foreground.
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//    NSLog(@"App Running - Notification handled: %@", notification.alertBody);
    [[spnSpendTracker sharedManager] processLocalNotification:notification withActionIdentifier:nil];
}

@end
