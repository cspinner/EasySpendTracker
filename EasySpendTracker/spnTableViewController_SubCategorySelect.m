//
//  spnTableViewController_SubCategorySelect.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/26/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_SubCategorySelect.h"

@interface spnTableViewController_SubCategorySelect ()

@end

@implementation spnTableViewController_SubCategorySelect

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create fetch request
    NSError* error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnSubCategoryMO"];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"lastModifiedDate" ascending:NO];
    
    // All sub-categories for this main category
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"category.title MATCHES %@", self.mainCategoryTitle];
    
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
