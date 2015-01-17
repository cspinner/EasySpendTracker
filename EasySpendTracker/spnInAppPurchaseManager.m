//
//  spnInAppPurchaseManager.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 1/14/15.
//  Copyright (c) 2015 Christopher Spinner. All rights reserved.
//

#import "spnInAppPurchaseManager.h"

NSString *const spnInAppProduct_AdFreeUpgrade = @"spinner.EasySpendTracker.AdFreeUpgrade";

@implementation spnInAppPurchaseManager

+ (spnInAppPurchaseManager *)sharedManager
{
    static dispatch_once_t once;
    static spnInAppPurchaseManager * sharedInstance;
    
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      spnInAppProduct_AdFreeUpgrade,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });

    return sharedInstance;
}

@end
