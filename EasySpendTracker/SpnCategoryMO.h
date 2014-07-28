//
//  SpnCategoryMO.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/26/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SpnSubCategoryMO;

@interface SpnCategoryMO : NSManagedObject

@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *subCategories;
@end

@interface SpnCategoryMO (CoreDataGeneratedAccessors)

- (void)addSubCategoriesObject:(SpnSubCategoryMO *)value;
- (void)removeSubCategoriesObject:(SpnSubCategoryMO *)value;
- (void)addSubCategories:(NSSet *)values;
- (void)removeSubCategories:(NSSet *)values;

@end
