//
//  SpnCategory.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "SpnCategoryMO.h"
#import "SpnSubCategory.h"

@interface SpnCategory : SpnCategoryMO

+ (SpnCategory*)fetchCategoryWithName:(NSString*)categoryName inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

- (SpnSubCategory*)fetchSubCategoryWithName:(NSString*)subCategoryName inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
