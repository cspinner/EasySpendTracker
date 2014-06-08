//
//  SpnSpendCategory.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "SpnSpendCategory.h"
#import "SpnTransaction.h"

@implementation SpnSpendCategory

- (id)initWithEntity:(NSEntityDescription*)entity insertIntoManagedObjectContext:(NSManagedObjectContext*)context
{
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self != nil) {
        [self addObserver:self forKeyPath:@"transactions" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"value"])
    {
//        NSString *const NSKeyValueChangeKindKey;
//        NSString *const NSKeyValueChangeNewKey;
//        NSString *const NSKeyValueChangeOldKey;
//        NSString *const NSKeyValueChangeIndexesKey;
//        NSString *const NSKeyValueChangeNotificationIsPriorKey;
        
        switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
        {
            case NSKeyValueChangeSetting:
            {
                NSNumber* oldNumber = [change objectForKey:NSKeyValueChangeOldKey];
                NSNumber* newNumber = [change objectForKey:NSKeyValueChangeNewKey];
                [self setTotal:[NSNumber numberWithFloat:[self.total floatValue] - [oldNumber floatValue]]];
                [self setTotal:[NSNumber numberWithFloat:[self.total floatValue] + [newNumber floatValue]]];
            }
                break;
                
            case NSKeyValueChangeInsertion:
            case NSKeyValueChangeRemoval:
            case NSKeyValueChangeReplacement:
            default:
                break;
        }
    }
    else if ([keyPath isEqual:@"transactions"])
    {
        switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
        {
            case NSKeyValueChangeInsertion:
            {
                NSSet* transactions = [change objectForKey:NSKeyValueChangeNewKey];
                
                for(SpnTransaction* transaction in transactions)
                {
                    [self setTotal:[NSNumber numberWithFloat:[self.total floatValue] + [transaction.value floatValue]]];
                }
            }
                break;
                
            case NSKeyValueChangeRemoval:
            {
                NSSet* transactions = [change objectForKey:NSKeyValueChangeOldKey];
                
                for(SpnTransaction* transaction in transactions)
                {
                    [self setTotal:[NSNumber numberWithFloat:[self.total floatValue] - [transaction.value floatValue]]];
                    
                    // stop observing properties of this object since it's being deleted. Otherwise we will get back to back notifications.
                    [transaction removeObserver:self forKeyPath:@"value"];
                }
            }
                break;
                
            case NSKeyValueChangeSetting:
            case NSKeyValueChangeReplacement:
            default:
                break;
        }
    }
    
}


@end
