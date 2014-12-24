//
//  SpnBillReminderMO.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 11/16/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SpnBillReminderMO : NSManagedObject

@property (nonatomic, retain) NSNumber * uniqueID;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * paidStatusRaw;
@property (nonatomic, retain) NSDate * dateDue;
@property (nonatomic, retain) id frequency;
@property (nonatomic, retain) NSString * merchant;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * sectionName;

@end
