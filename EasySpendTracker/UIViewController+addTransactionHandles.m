//
//  UIViewController+addTransactionHandles.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/26/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "UIViewController+addTransactionHandles.h"
#import "spnSpendTracker.h"
#import "spnTableViewController_Transaction.h"
#import "SpnMonth.h"
#import "SpnSpendCategory.h"
#import "SpnTransaction.h"

@implementation UIViewController (addTransactionHandles)

- (void)spnAddButtonClicked: (id)sender
{
    SpnTransaction* newTransaction = (SpnTransaction*)[NSEntityDescription                                                  insertNewObjectForEntityForName:@"SpnTransactionMO"                                                  inManagedObjectContext:[[spnSpendTracker sharedManager] managedObjectContext]];
    [newTransaction setMerchant:@""];
    [newTransaction setNotes:@""];
    [newTransaction setValue:[NSNumber numberWithFloat:0.00]];
    
    spnTableViewController_Transaction* addViewController = [[spnTableViewController_Transaction alloc] initWithStyle:UITableViewStyleGrouped];
    [addViewController setTitle:@"Add Transaction"];
    [addViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [addViewController setManagedObjectContext:[[spnSpendTracker sharedManager] managedObjectContext]];
    [addViewController setTransaction:newTransaction];

    // Add done and cancel buttons
    addViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
    addViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];

    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:addViewController];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)doneButtonClicked: (id)sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)cancelButtonClicked: (id)sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        // Discard the changes
        [[[spnSpendTracker sharedManager] managedObjectContext] rollback];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
