//
//  spnTransactionFetchOp.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/23/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTransactionFetchOp.h"

@interface spnTransactionFetchOp()

@end

@implementation spnTransactionFetchOp

- (id)init
{
    self = [super init];
    if (self) {
        // sub class specific init. Note this is invoked from the calling thread
    }
    return self;
}

// main is invoked by the NSOperationQueue
- (void)main
{
    @autoreleasepool
    {
        NSError* error;
        NSMutableArray* objectIDs = [[NSMutableArray alloc] init];
        
        // Create a managed object context unique to this operation
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        
        // Create fetch request
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnTransactionMO"];
        
        NSMutableArray* predicateArray = [[NSMutableArray alloc] init];
        
        // Create a predicate that excludes transactions from the specified categories
        if ((self.excludeCategories != nil) && (self.excludeCategories.count > 0))
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT(subCategory.category.title IN %@)", self.excludeCategories];
            
            [predicateArray addObject:predicate];
        }
        
        // Create a predicate that includes transactions from the specified categories
        if ((self.includeCategories != nil) && (self.includeCategories.count > 0))
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subCategory.category.title IN %@", self.includeCategories];
            
            [predicateArray addObject:predicate];
        }
        
        // Create a predicate that includes transactions from the specified subcategories
        if ((self.includeSubCategories != nil) && (self.includeSubCategories.count > 0))
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subCategory.title IN %@", self.includeSubCategories];
            
            [predicateArray addObject:predicate];
        }
        
        // Create a predicate that accepts transactions from a specified start date
        if (self.startDate != nil)
        {
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date >= %@)", self.startDate];
            
            [predicateArray addObject:predicate];
        }
        
        // Create a predicate that accepts transactions that come before a specified end date
        if (self.endDate != nil)
        {
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date < %@)", self.endDate];
            
            [predicateArray addObject:predicate];
        }
        
        // Combine the predicates if any were created
        if (predicateArray.count > 0)
        {
            [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicateArray]];
        }
        
        NSArray* objects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (NSManagedObject* object in objects)
        {
            if (self.isCancelled) break;
            
            [objectIDs addObject:object.objectID];
        }
        
        // Call completion block
        if(self.dataReturnBlock)
        {
            self.dataReturnBlock(objectIDs, error);
        }
    }
}

@end
