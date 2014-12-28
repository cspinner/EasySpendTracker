//
//  SpnTransaction.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "SpnTransactionMO.h"

@interface SpnTransaction : SpnTransactionMO

typedef enum
{
    EXPENSE_TRANSACTION_TYPE = 0u,
    INCOME_TRANSACTION_TYPE,
    NUM_TRANSACTION_TYPES
} enumSpnTransactionType;

- (SpnTransaction*)clone;

@end
