//
//  UIViewController+addTransactionHandles.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/26/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "UIViewController+addTransactionHandles.h"
#import "spnViewController_Add.h"
#import "spnSpendTracker.h"

@implementation UIViewController (addTransactionHandles)

typedef enum
{
    ADDING_MODE,
    EDITING_MODE
} addTransaction_mode_t;

addTransaction_mode_t mode;

- (void)spnAddButtonClicked: (id)sender
{
    mode = ADDING_MODE;
    
    spnViewController_Add* addViewController = [[spnViewController_Add alloc] init];
    [addViewController setTitle:@"Add Transaction"];
    
    addViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:addViewController];
    
    addViewController.delegate = self;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)spnEditButtonClicked: (id)sender
{
    mode = EDITING_MODE;
    
    spnViewController_Add* addViewController = [[spnViewController_Add alloc] init];
    [addViewController setTitle:@"Edit Transaction"];
    
    addViewController.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:addViewController];
    
    addViewController.delegate = self;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)spnAddViewControllerDidFinish:(id)sender withNewEntry:(id)newEntry fromOldEntry:(id)oldEntry withCategory:(NSString*)category fromOldCategory:(NSString*)oldCategory
{
    if(newEntry)
    {
        if(mode == ADDING_MODE)
        {
            [[spnSpendTracker sharedManager] addTransaction:newEntry forCategory:category];
        }
        else // mode == EDITING_MODE
        {
            [[spnSpendTracker sharedManager] deleteTransaction:oldEntry fromCategory:oldCategory];
            [[spnSpendTracker sharedManager] addTransaction:newEntry forCategory:category];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
