//
//  UIViewController+addTransactionHandles.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/26/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (addTransactionHandles) <UIActionSheetDelegate>

@property NSDate* preferredDate;

- (void)spnAddButtonClicked: (id)sender;

@end
