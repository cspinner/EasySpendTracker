//
//  SpnTransactionMO.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 6/16/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SpnRecurrenceMO, SpnTransactionCategory;

@interface SpnTransactionMO : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * merchant;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) SpnTransactionCategory *category;
@property (nonatomic, retain) SpnRecurrenceMO *recurrence;

@end
