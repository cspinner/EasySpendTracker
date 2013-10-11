//
//  Transaction.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/10/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SpendCategory;

@interface Transaction : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * merchant;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * uniqueId;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) SpendCategory *category;

@end
