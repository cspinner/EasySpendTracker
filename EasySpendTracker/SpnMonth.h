//
//  SpnMonth.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/10/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SpnSpendCategory;

@interface SpnMonth : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSNumber * totalIncome;
@property (nonatomic, retain) NSNumber * totalExpenses;
@property (nonatomic, retain) NSSet *categories;
@end

@interface SpnMonth (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(SpnSpendCategory *)value;
- (void)removeCategoriesObject:(SpnSpendCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
