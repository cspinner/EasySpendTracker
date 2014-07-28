//
//  spnTableViewController_MainCategorySelect.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/26/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_MainCategorySelect.h"

@interface spnTableViewController_MainCategorySelect ()

@end

@implementation spnTableViewController_MainCategorySelect


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create fetch request
    NSError* error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnCategoryMO"];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"lastModifiedDate" ascending:NO];
    
    // All categories for expenses (excludes Income)
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"NOT(title MATCHES %@)", @"Income"];
    
    // Assign the sort and predicate descriptor to the fetch request on the TITLEs of the categories
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"title", nil]];
    [fetchRequest setReturnsDistinctResults:YES];
    
    // Fetch the categories
    self.categoryTitleDictionaryArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}


@end
