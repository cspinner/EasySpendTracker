//
//  spnTableViewController_LinePlot_Cat.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/9/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_LinePlot_Cat.h"
#import "spnTableViewController_LinePlot_SubCat.h"

@interface spnTableViewController_LinePlot_Cat ()

@end

@implementation spnTableViewController_LinePlot_Cat

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.linePlotTableType = LINE_PLOT_TABLE_TYPE_CAT;
    }
    return self;
}

- (void)viewDidLoad {
    // initialize predicate array
    self.frcPredicateArray = [[NSMutableArray alloc] init];
    
    // Create a predicate that excludes transactions from the specified categories
    if ((self.excludeCategories != nil) && (self.excludeCategories.count > 0))
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT(title IN %@)", self.excludeCategories];
        
        [self.frcPredicateArray addObject:predicate];
    }
    
    // Create a predicate that includes transactions from the specified categories
    if ((self.includeCategories != nil) && (self.includeCategories.count > 0))
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title IN %@", self.includeCategories];
        
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

//<UITableViewDelegate> methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Display subcategory line plot for the selected category indicated by section name
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[indexPath.section];
    
    spnTableViewController_LinePlot_SubCat *subCategoryLinePlotTableView = [[spnTableViewController_LinePlot_SubCat alloc] initWithStyle:UITableViewStyleGrouped];
    subCategoryLinePlotTableView.title = @"Spending - Last 12 Months";
    subCategoryLinePlotTableView.startDate = self.startDate;
    subCategoryLinePlotTableView.endDate = self.endDate;
    subCategoryLinePlotTableView.excludeCategories = nil;
    subCategoryLinePlotTableView.includeCategories = [NSArray arrayWithObject:sectionInfo.name];
    subCategoryLinePlotTableView.managedObjectContext = self.managedObjectContext;
    subCategoryLinePlotTableView.entityName = @"SpnSubCategoryMO";
    
    [[self navigationController] pushViewController:subCategoryLinePlotTableView animated:YES];
}

@end
