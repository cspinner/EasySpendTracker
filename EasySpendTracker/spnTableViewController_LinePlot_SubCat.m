//
//  spnTableViewController_LinePlot_SubCat.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/9/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_LinePlot_SubCat.h"
#import "spnTableViewController_Transactions.h"

@interface spnTableViewController_LinePlot_SubCat ()

@end

@implementation spnTableViewController_LinePlot_SubCat

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.linePlotTableType = LINE_PLOT_TABLE_TYPE_SUBCAT;
    }
    return self;
}

- (void)viewDidLoad {
    // initialize predicate array
    self.frcPredicateArray = [[NSMutableArray alloc] init];
    
    // Create a predicate that excludes transactions from the specified categories
    if ((self.excludeCategories != nil) && (self.excludeCategories.count > 0))
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT(category.title IN %@)", self.excludeCategories];
        
        [self.frcPredicateArray addObject:predicate];
    }
    
    // Create a predicate that includes transactions from the specified categories
    if ((self.includeCategories != nil) && (self.includeCategories.count > 0))
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category.title IN %@", self.includeCategories];
        
        [self.frcPredicateArray addObject:predicate];
    }
    
    // Create a predicate that accepts transactions from a specified start date
    if (self.startDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(lastModifiedDate >= %@)", self.startDate];
        
        [self.frcPredicateArray addObject:predicate];
    }
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[indexPath.section];
    
    // Create and Push transaction detail view controller
    spnTableViewController_Transactions* transactionsTableViewController = [[spnTableViewController_Transactions alloc] initWithStyle:UITableViewStyleGrouped];
    [transactionsTableViewController setTitle:sectionInfo.name];
    [transactionsTableViewController setCategoryTitle:self.includeCategories[0]];
    [transactionsTableViewController setSubCategoryTitle:sectionInfo.name];
    [transactionsTableViewController setStartDate:self.startDate];
    [transactionsTableViewController setEndDate:self.endDate];
    [transactionsTableViewController setManagedObjectContext:self.managedObjectContext];
    
    [[self navigationController] pushViewController:transactionsTableViewController animated:YES];
}



@end
