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
#import "spnViewController_BillReminder.h"
#import <objc/runtime.h>

static char const * const PreferredDateKey = "PreferredDate";

@implementation UIViewController (addTransactionHandles)

@dynamic preferredDate;

#define ACTION_SHEET_BUTTON_IDX_EXPENSE 0
#define ACTION_SHEET_BUTTON_IDX_INCOME 1
#define ACTION_SHEET_BUTTON_IDX_REMINDER 2

- (NSDate*)preferredDate
{
    return objc_getAssociatedObject(self, PreferredDateKey);
}

- (void)setPreferredDate:(NSDate *)preferredDate
{
    objc_setAssociatedObject(self, PreferredDateKey, preferredDate,  OBJC_ASSOCIATION_RETAIN);
}

- (void)spnAddButtonClicked: (id)sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
        @"Expense",
        @"Income",
        @"Reminder",
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
            spnViewController_Expense* addViewController = [[spnViewController_Expense alloc] init];
            [addViewController setTitle:@"Add Expense"];
            [addViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [addViewController setManagedObjectContext:[[spnSpendTracker sharedManager] managedObjectContext]];
            [addViewController setTransaction:[[spnSpendTracker sharedManager] createTransactionWithType:EXPENSE_TRANSACTION_TYPE]];
            [addViewController setIsNew:YES];
            [addViewController setDate:self.preferredDate];
            
            // Add done and cancel buttons
            addViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:addViewController action:doneButtonSelector];
            addViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:addViewController action:cancelButtonSelector];
            
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:addViewController];
            
            [self presentViewController:navController animated:YES completion:nil];
        }
            break;
            
        case ACTION_SHEET_BUTTON_IDX_INCOME:
        {
            spnViewController_Income* addViewController = [[spnViewController_Income alloc] init];
            [addViewController setTitle:@"Add Income"];
            [addViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [addViewController setManagedObjectContext:[[spnSpendTracker sharedManager] managedObjectContext]];
            [addViewController setTransaction:[[spnSpendTracker sharedManager] createTransactionWithType:INCOME_TRANSACTION_TYPE]];
            [addViewController setIsNew:YES];
            [addViewController setDate:self.preferredDate];
            
            // Add done and cancel buttons
            addViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:addViewController action:doneButtonSelector];
            addViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:addViewController action:cancelButtonSelector];
            
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:addViewController];
            
            [self presentViewController:navController animated:YES completion:nil];
        }
            break;
            
        case ACTION_SHEET_BUTTON_IDX_REMINDER:
        {
            spnViewController_BillReminder* addViewController = [[spnViewController_BillReminder alloc] init];
            [addViewController setTitle:@"Add Reminder"];
            [addViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [addViewController setManagedObjectContext:[[spnSpendTracker sharedManager] managedObjectContext]];
            [addViewController setBillReminder:[[spnSpendTracker sharedManager] createBillReminder]];
            [addViewController setIsNew:YES];
            [addViewController setDate:self.preferredDate];
            
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




@end
