//
//  SpnTransaction.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "SpnTransactionMO.h"

@interface SpnTransaction : SpnTransactionMO

- (SpnTransaction*)clone;

@end
