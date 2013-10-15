//
//  spnAddTransactionDelegate.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/3/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpnTransaction.h"

@protocol spnAddTransactionDelegate <NSObject>

@optional
- (SpnTransaction*)transactionForEdit;
- (NSString*)activeCategory;
@end
