//
//  UIViewController+addTransactionHandles.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/26/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "UIViewController+addTransactionHandles.h"
#import "spnSpendTracker.h"
#import "spnViewController_Expense.h"
#import "spnViewController_Income.h"
#import "SpnTransaction.h"

@implementation UIViewController (addTransactionHandles)

#define ACTION_SHEET_BUTTON_IDX_EXPENSE 0
#define ACTION_SHEET_BUTTON_IDX_INCOME 1

- (void)spnAddButtonClicked: (id)sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
        @"Expense",
        @"Income",
        nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    SEL cancelButtonSelector = sel_registerName("cancelButtonClicked:");
    SEL doneButtonSelector = sel_registerName("doneButtonClicked:");
    
    switch (buttonIndex)
    {
        case ACTION_SHEET_BUTTON_IDX_EXPENSE:
        {
            SpnTransaction* newTransaction = [[SpnTransaction alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnTransactionMO" inManagedObjectContext:[[spnSpendTracker sharedManager] managedObjectContext]] insertIntoManagedObjectContext:[[spnSpendTracker sharedManager] managedObjectContext]];
            
            // Perform additional initialization.
            [newTransaction setMerchant:@""];
            [newTransaction setNotes:@""];
            [newTransaction setValue:[NSNumber numberWithFloat:0.00]];
            [newTransaction setType:[NSNumber numberWithInt:EXPENSE_TRANSACTION_TYPE]];
            
            spnViewController_Expense* addViewController = [[spnViewController_Expense alloc] init];
            [addViewController setTitle:@"Add Expense"];
            [addViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [addViewController setManagedObjectContext:[[spnSpendTracker sharedManager] managedObjectContext]];
            [addViewController setTransaction:newTransaction];
            [addViewController setIsNew:YES];
            
            // Add done and cancel buttons
            addViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:addViewController action:doneButtonSelector];
            addViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:addViewController action:cancelButtonSelector];
            
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:addViewController];
            
            [self presentViewController:navController animated:YES completion:nil];
        }
            break;
            
        case ACTION_SHEET_BUTTON_IDX_INCOME:
        {
            SpnTransaction* newTransaction = [[SpnTransaction alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnTransactionMO" inManagedObjectContext:[[spnSpendTracker sharedManager] managedObjectContext]] insertIntoManagedObjectContext:[[spnSpendTracker sharedManager] managedObjectContext]];
            
            // Perform additional initialization.
            [newTransaction setMerchant:@""];
            [newTransaction setNotes:@""];
            [newTransaction setValue:[NSNumber numberWithFloat:0.00]];
            [newTransaction setType:[NSNumber numberWithInt:INCOME_TRANSACTION_TYPE]];
            
            spnViewController_Income* addViewController = [[spnViewController_Income alloc] init];
            [addViewController setTitle:@"Add Income"];
            [addViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [addViewController setManagedObjectContext:[[spnSpendTracker sharedManager] managedObjectContext]];
            [addViewController setTransaction:newTransaction];
            [addViewController setIsNew:YES];
            
            // Add done and cancel buttons
            addViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:addViewController action:doneButtonSelector];
            addViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:addViewController action:cancelButtonSelector];
            
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:addViewController];
            
            [self presentViewController:navController animated:YES completion:nil];
        }
            break;
            
        default:
            break;
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
