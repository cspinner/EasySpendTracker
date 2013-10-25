//
//  SpnMonthMO.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SpnSpendCategoryMO;

@interface SpnMonthMO : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSNumber * totalExpenses;
@property (nonatomic, retain) NSNumber * totalIncome;
@property (nonatomic, retain) NSSet *categories;
@end

@interface SpnMonthMO (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(SpnSpendCategoryMO *)value;
- (void)removeCategoriesObject:(SpnSpendCategoryMO *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
