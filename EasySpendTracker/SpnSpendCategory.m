//
//  SpnSpendCategory.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "SpnSpendCategory.h"

@implementation SpnSpendCategory

- (id)initWithEntity:(NSEntityDescription*)entity insertIntoManagedObjectContext:(NSManagedObjectContext*)context
{
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self != nil) {
        // Perform additional initialization.
        [self setTotal:[NSNumber numberWithFloat:0.00]];
        [self setLastModifiedDate:[NSDate date]];
    }
    return self;
}

@end
