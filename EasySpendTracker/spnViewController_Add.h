//
//  spnViewController_Add.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/22/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spnAddTransactionDelegate.h"

@interface spnViewController_Add : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIPopoverControllerDelegate, spnAddTransactionDelegate>

@property (nonatomic, weak) id delegate;

@end
