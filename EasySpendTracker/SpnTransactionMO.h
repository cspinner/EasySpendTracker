//
//  SpnTransactionMO.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/26/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SpnRecurrence, SpnSubCategoryMO;

@interface SpnTransactionMO : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * merchant;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) SpnSubCategoryMO *subCategory;
@property (nonatomic, retain) SpnRecurrence *recurrence;
@property (nonatomic, retain) SpnRecurrence *recurrenceWhereRoot;

@end
