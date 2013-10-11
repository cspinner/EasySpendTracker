//
//  UIViewController+addTransactionHandles.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/26/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (addTransactionHandles)

- (void)spnAddButtonClicked: (id)sender;
- (void)spnEditButtonClicked: (id)sender;
- (void)spnAddViewControllerDidFinish:(id)sender withNewEntry:(id)newEntry fromOldEntry:(id)oldEntry withCategory:(NSString*)category fromOldCategory:(NSString*)oldCategory;

@end
