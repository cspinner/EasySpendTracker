//
//  SpnCategory.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/24/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "SpnCategory.h"
#import "SpnSubCategory.h"

@implementation SpnCategory

static int subCategoriesObservanceContext;

+ (SpnCategory*)fetchCategoryWithName:(NSString*)categoryName inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    NSError *error = nil;
    SpnCategory* category = nil;
    
    // Find categories (but should only be one) matching the specified name
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SpnCategoryMO"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title MATCHES[cd] %@)", categoryName];
    [fetchRequest setPredicate:predicate];
    
    NSMutableArray *mutableFetchResults = [[managedObjectContext                                                executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if (mutableFetchResults == nil)
    {
        // Error
    }
    else
    {
        // Target category was found
        if([mutableFetchResults count] != 0)
        {
            // set the return value - again, assumes only 1 match and so return the first in the array
            category = [mutableFetchResults objectAtIndex:0];
        }
        else
        {
            // Category not found - add a new one
            category = [[SpnCategory alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnCategoryMO" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
            
            // Perform additional initialization.
            [category setLastModifiedDate:[NSDate date]];
            [category setTitle:categoryName];
        }
    }
    
    return category;
}

- (SpnSubCategory*)fetchSubCategoryWithName:(NSString*)subCategoryName inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    SpnSubCategory* subCategory;
    
    // Search for an existing sub category of this category
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title MATCHES[cd] %@)", subCategoryName];
    
    NSSet *filteredResults = [self.subCategories filteredSetUsingPredicate:predicate];
    
    // Sub-category was found
    if([filteredResults count] != 0)
    {
        // set the return value - again, assumes only 1 match and so return the first in the array
        subCategory = [filteredResults anyObject];
    }
    else
    {
        // Sub-Category not found - add a new one
        subCategory = [[SpnSubCategory alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnSubCategoryMO" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
        
        // Perform additional initialization.
        [subCategory setLastModifiedDate:[NSDate date]];
        [subCategory setTitle:subCategoryName];
        
        // Add the sub-category to this category
        [self addSubCategoriesObject:subCategory];
    }
    
    return subCategory;
}

- (void)awakeFromInsert
{
    // Called when this category is inserted into the managed object context.
    
    [super awakeFromInsert];
    
    // Monitor changes to the transactions set
    [self addObserver:self forKeyPath:@"subCategories" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&subCategoriesObservanceContext];
}

- (void)awakeFromFetch
{
    // Called when this category is fetched from the memory store.
    
    [super awakeFromFetch];
    
    // Monitor changes to the transactions set
    [self addObserver:self forKeyPath:@"subCategories" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&subCategoriesObservanceContext];
}

- (void)willTurnIntoFault
{
    // Called when this category is being sent to the store
    [super willTurnIntoFault];
    
    // Remove all observances this instance has
    [self removeObserver:self forKeyPath:@"subCategories" context:&subCategoriesObservanceContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &subCategoriesObservanceContext)
    {
        switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
        {
            case NSKeyValueChangeRemoval:
            {
                // Is there a better way?
                if (self.subCategories.count == nil ||
                    self.subCategories.count == 0)
                {
                    [self.managedObjectContext deleteObject:self];
                    NSLog(@"Removing empty category");
                }
            }
                break;
                
            case NSKeyValueChangeReplacement:
            case NSKeyValueChangeSetting:
            case NSKeyValueChangeInsertion:
            default:
                break;
        }
        
        // Update last modified date
        self.lastModifiedDate = [NSDate date];
    }
    
}




@end
