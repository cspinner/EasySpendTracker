//
//  spnInAppPurchaseManager.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 1/14/15.
//  Copyright (c) 2015 Christopher Spinner. All rights reserved.
//

#import "spnInAppPurchase.h"

UIKIT_EXTERN NSString *const spnInAppProduct_AdFreeUpgrade;

@interface spnInAppPurchaseManager : spnInAppPurchase

+ (spnInAppPurchaseManager*)sharedManager;

@end
