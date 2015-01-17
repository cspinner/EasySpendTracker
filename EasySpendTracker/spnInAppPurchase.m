//
//  spnInAppPurchase.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 1/13/15.
//  Copyright (c) 2015 Christopher Spinner. All rights reserved.
//

#import "spnInAppPurchase.h"
#import "StoreKit/StoreKit.h"

@interface spnInAppPurchase () 

@end

NSString *const spnInAppProductPurchasedNotification = @"spnInAppProductPurchasedNotification";

@implementation spnInAppPurchase
{
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if ((self = [super init]))
    {
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers)
        {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            
#ifdef PP_IAP_ALL_PURCHASED
            if (PP_IAP_ALL_PURCHASED)
            {
                // Enabled for debug release only
                [_purchasedProductIdentifiers addObject:productIdentifier];
            }
            else
#endif
                if (productPurchased)
                {
                    [_purchasedProductIdentifiers addObject:productIdentifier];
                    NSLog(@"Previously purchased: %@", productIdentifier);
                }
                else
                {
                    NSLog(@"Not purchased: %@", productIdentifier);
                }
        }
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

- (void)buyProduct:(SKProduct *)product;
{
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (BOOL)productPurchased:(NSString *)productIdentifier
{
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:spnInAppProductPurchasedNotification object:productIdentifier userInfo:nil];
}

#pragma mark - SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts)
    {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

#pragma mark - SKPaymentTransactionObserver methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

@end

