//
//  spnTableViewController_LinePlot.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/7/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_LinePlot.h"
#import "UIViewController+addTransactionHandles.h"
#import "spnLinePlot.h"
//#import "spnTableViewController_SubCategories.h"
//#import "spnTableViewController_Transactions.h"
//#import "SpnCategory.h"
//#import "SpnSubCategory.h"

@interface spnTableViewController_LinePlot ()

// These two are sorted together
@property NSArray* linePlotXYValues;
@property NSArray* linePlotXLabels;

@end

@implementation spnTableViewController_LinePlot

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(spnAddButtonClicked:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

-(void)reloadData
{
//    self.pieChartCntrl = [[spnLinePlot alloc] initWithContext:&pieChartCategoryContext];
    self.linePlotCntrl = [[spnLinePlot alloc] initWithContext:nil];
    self.linePlotCntrl.delegate = self;
    
    // retrieve list of values as the data source:
    NSMutableArray* XYValues = [[NSMutableArray alloc] init];

    // Get list of transactions for the specified date range, excluding the specified categories
    NSMutableArray* transactions = [[self getTransactionsFromStartDate:self.startDate toEndDate:self.endDate excludingCategories:self.excludeCategories] mutableCopy];
    
    // Get array of section names for those transactions in the sorted order
    NSMutableArray* uniqueSectionNames = [[transactions valueForKeyPath:@"@distinctUnionOfObjects.sectionName"] mutableCopy];

    [uniqueSectionNames sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateStyle: NSDateFormatterMediumStyle];
        
        NSDate* date1 = [dateFormatter dateFromString:obj1];
        NSDate* date2 = [dateFormatter dateFromString:obj2];
        
        return [date1 compare:date2];
    }];
    
    // Sum the transactions for each section
    NSUInteger x = 0;
    NSNumber* cumulativeValue = [NSNumber numberWithFloat:0.0f];
    for (NSString* sectionName in uniqueSectionNames)
    {
        NSPredicate* sectionPredicate = [NSPredicate predicateWithFormat:@"sectionName MATCHES[cd] %@", sectionName];
        NSArray* transactionsInSection = [transactions filteredArrayUsingPredicate:sectionPredicate];
        
        NSNumber* valueOfSection = [transactionsInSection valueForKeyPath:@"@sum.value"];
        
        cumulativeValue = [NSNumber numberWithFloat:cumulativeValue.floatValue + valueOfSection.floatValue];
        
//        [XYValues addObject:@{ @(CPTScatterPlotFieldX): sectionName, @(CPTScatterPlotFieldY): valueOfSection}];
        [XYValues addObject:@{ @(CPTScatterPlotFieldX): @(x), @(CPTScatterPlotFieldY): cumulativeValue}];
        x++;
    }
    
    self.linePlotXYValues = [NSArray arrayWithArray:XYValues];
    
//    [self updateSourceDataForLinePlot:self.linePlotCntrl];
}

-(UIImage*)linePlotImageWithFrame:(CGRect)frame
{
    [self reloadData];
    return [self.linePlotCntrl imageWithFrame:frame];
}

// <UITableViewDataSource> methods
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    switch (indexPath.row)
//    {
//        case PIECHART_TABLE_TEXT_ROW:
//        {
//            UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
//            
//            if (self.focusCategory == nil)
//            {
//                // Set category count
//                [cell.textLabel setText:[NSString stringWithFormat:@"%ld Categories", self.pieChartValues.count]];
//            }
//            else
//            {
//                // Set focus category name
//                [cell.textLabel setText:self.focusCategory];
//                
//                // Add chevron button
//                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//            }
//            
//            [cell.detailTextLabel setText:[NSString stringWithFormat:@"$%.2f", [[self.pieChartValues valueForKeyPath:@"@sum.self"] floatValue]]];
//            
//            return cell;
//        }
//            break;
//            
//        case PIECHART_TABLE_PLOT_ROW:
//        {
//            UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//            
//            CGRect bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width);
//            
//            UIView* pieChartView = [[UIView alloc] initWithFrame:bounds];
//            
//            [self.linePlotCntrl renderInView:pieChartView withTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme] forPreview:NO animated:YES];
//            
//            // Create new height that accounts for the legend view - assume two columns and 24 pix per entry
//            CGFloat newHeight = pieChartView.bounds.size.height + LEGEND_AREA_HEIGHT(self.pieChartNames.count);
//            [pieChartView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, newHeight)];
//            self.pieChartCntrl.pieChart.centerAnchor = CGPointMake(0.5, (newHeight - (self.pieChartCntrl.pieChart.pieRadius+10.0))/newHeight);
//            
//            [cell addSubview:pieChartView];
//            
//            return cell;
//        }
//            break;
//            
//        default:
//            return nil;
//            break;
//    }
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return PIECHART_TABLE_ROW_COUNT;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // The table view should not be re-orderable.
//    return NO;
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}

// <UITableViewDelegate> methods
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleNone;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    switch (indexPath.row)
//    {
//        case PIECHART_TABLE_TEXT_ROW:
//        {
//            if (self.focusCategory != nil)
//            {
//                // Get reference to selected item
//                SpnCategory* category = [SpnCategory fetchCategoryWithName:self.focusCategory inManagedObjectContext:self.managedObjectContext];
//                
//                // Create and Push transaction detail view controller
//                spnTableViewController_SubCategories* subCategoryTableViewController = [[spnTableViewController_SubCategories alloc] initWithStyle:UITableViewStyleGrouped];
//                [subCategoryTableViewController setTitle:[category title]];
//                [subCategoryTableViewController setCategoryTitle:[category title]];
//                [subCategoryTableViewController setStartDate:self.startDate];
//                [subCategoryTableViewController setEndDate:self.endDate];
//                [subCategoryTableViewController setManagedObjectContext:self.managedObjectContext];
//                
//                [[self navigationController] pushViewController:subCategoryTableViewController animated:YES];
//            }
//        }
//            break;
//            
//        default:
//            break;
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 0.001;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    switch (indexPath.row)
//    {
//        case PIECHART_TABLE_PLOT_ROW:
//            return self.view.bounds.size.width+LEGEND_AREA_HEIGHT(self.pieChartNames.count);
//            break;
//            
//        case PIECHART_TABLE_TEXT_ROW:
//        default:
//            return 44.0;
//            break;
//    }
//}
//
-(NSArray*)getTransactionsFromStartDate:(NSDate*)startDate toEndDate:(NSDate*)endDate excludingCategories:(NSArray*)exclusionCategories
{
    NSError* error;
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnTransactionMO"];
    
    NSMutableArray* predicateArray = [[NSMutableArray alloc] init];
    
    // Create a predicate that excludes transactions from the specified categories
    if ((exclusionCategories != nil) && (exclusionCategories.count > 0))
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT(subCategory.category.title IN %@)", exclusionCategories];
        
        [predicateArray addObject:predicate];
    }

    // Create a predicate that accepts transactions from a specified start date
    if (startDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date >= %@)", startDate];
        
        [predicateArray addObject:predicate];
    }
    
    // Create a predicate that accepts transactions that come before a specified end date
    if (endDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date < %@)", endDate];
        
        [predicateArray addObject:predicate];
    }
    
    // Combine the predicates if any were created
    if (predicateArray.count > 0)
    {
        [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicateArray]];
    }

    return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}
//
//-(void)sortArraysTogetherBasedOnArray:(NSMutableArray**)numberArray secondArray:(NSMutableArray**)secondArray
//{
//    // Create permutation array
//    NSMutableArray *p = [NSMutableArray arrayWithCapacity:(*numberArray).count];
//    
//    // Create array of numbers 0 - n
//    for (NSUInteger i = 0 ; i < (*numberArray).count; i++)
//    {
//        [p addObject:[NSNumber numberWithInteger:i]];
//    }
//    
//    // Rearrange the 0 - n array based on the desired order of numberArray
//    [p sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
//     {
//         // Sort routine wants to sort objects in ascending order, so our comparator needs to return the opposite to force it to sort in descending order.
//         if (NSOrderedAscending == [[(*numberArray) objectAtIndex:[obj1 integerValue]] compare:[(*numberArray) objectAtIndex:[obj2 integerValue]]])
//         {
//             return NSOrderedDescending;
//         }
//         
//         if (NSOrderedDescending == [[(*numberArray) objectAtIndex:[obj1 integerValue]] compare:[(*numberArray) objectAtIndex:[obj2 integerValue]]])
//         {
//             return NSOrderedAscending;
//         }
//         
//         return NSOrderedSame;
//     }];
//    
//    // Create array objects to hold the sorted arrays
//    NSMutableArray *sortedFirst = [NSMutableArray arrayWithCapacity:(*numberArray).count];
//    NSMutableArray *sortedSecond = [NSMutableArray arrayWithCapacity:(*numberArray).count];
//    
//    // Enumerate through the rearranged 0 - n array. This is the order that both arrays will need.
//    [p enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
//     {
//         NSUInteger pos = [obj intValue];
//         [sortedFirst addObject:[(*numberArray) objectAtIndex:pos]];
//         [sortedSecond addObject:[(*secondArray) objectAtIndex:pos]];
//     }];
//    
//    *numberArray = [[NSMutableArray alloc] initWithArray:sortedFirst copyItems:YES];
//    *secondArray = [[NSMutableArray alloc] initWithArray:sortedSecond copyItems:YES];
//}
//
//-(void)updateCategoryValuesAndNamesForTransactions:(NSArray*)transactions forKeyPath:(NSString*)keyPath
//{
//    NSMutableArray* valuesArray = [[NSMutableArray alloc] init];
//    
//    // Get array of unique category titles
//    NSMutableArray* namesArray = [transactions valueForKeyPath:[NSString stringWithFormat:@"@distinctUnionOfObjects.%@", keyPath]];
//    
//    for(NSString* categoryTitle in namesArray)
//    {
//        // Get array of transactions for each category, by category title
//        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K MATCHES[cd] %@", keyPath, categoryTitle];
//        NSArray* filteredTransactions = [transactions filteredArrayUsingPredicate:predicate];
//        
//        // Store the sum of values of those transactions to the array
//        [valuesArray addObject:[filteredTransactions valueForKeyPath:@"@sum.value"]];
//    }
//    
//    [self sortArraysTogetherBasedOnArray:&valuesArray secondArray:&namesArray];
//    
//    self.pieChartValues = [[NSMutableArray alloc] initWithArray:valuesArray copyItems:YES];
//    self.pieChartNames = [[NSMutableArray alloc] initWithArray:namesArray copyItems:YES];
//}

-(void)updateSourceDataForLinePlot:(spnLinePlot*)linePlot
{
    if (linePlot.context == nil)
    {
//        NSArray* transactions = [self getTransactionsFromStartDate:self.startDate toEndDate:self.endDate excludingCategories:self.excludeCategories];
//        [self updateCategoryValuesAndNamesForTransactions:transactions forKeyPath:[NSString stringWithFormat:@"subCategory.category.title"]];
    }
//    else if (pieChart.context == &pieChartSubCategoryContext)
//    {
//        NSArray* transactions = [self getTransactionsFromStartDate:self.startDate toEndDate:self.endDate excludingCategories:nil];
//        
//        // Narrow transactions by focus category
//        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"subCategory.category.title MATCHES[cd] %@", self.focusCategory];
//        NSArray* filteredTransactions = [transactions filteredArrayUsingPredicate:predicate];
//        
//        [self updateCategoryValuesAndNamesForTransactions:filteredTransactions forKeyPath:[NSString stringWithFormat:@"subCategory.title"]];
//    }
    
}

//<spnLinePlotDelegate> methods>
-(NSArray*)dataArrayForLinePlot:(spnLinePlot *)linePlot
{
    return self.linePlotXYValues;
}

-(NSArray*)xLabelArrayForLinePlot:(spnLinePlot *)linePlot
{
    return self.linePlotXLabels;
}

//-(void)pieChart:(spnLinePlot*)pieChart entryWasSelectedAtIndex:(NSUInteger)idx
//{
//    if (pieChart.context == &pieChartCategoryContext)
//    {
//        // Assert focus category for sub-category view
//        self.focusCategory = [self.pieChartNames objectAtIndex:idx];
//        
//        // change context to sub-category
//        pieChart.context = &pieChartSubCategoryContext;
//        
//        [self updateSourceDataForPieChart:pieChart];
//    }
//    else if (pieChart.context == &pieChartSubCategoryContext)
//    {
//        // Get reference to selected item
//        SpnCategory* category = [SpnCategory fetchCategoryWithName:self.focusCategory inManagedObjectContext:self.managedObjectContext];
//        SpnSubCategory* subCategory = [category fetchSubCategoryWithName:[self.pieChartNames objectAtIndex:idx] inManagedObjectContext:self.managedObjectContext];
//        
//        // Create and Push transaction detail view controller
//        spnTableViewController_Transactions* transactionsTableViewController = [[spnTableViewController_Transactions alloc] initWithStyle:UITableViewStyleGrouped];
//        [transactionsTableViewController setTitle:[subCategory title]];
//        [transactionsTableViewController setCategoryTitle:[category title]];
//        [transactionsTableViewController setSubCategoryTitle:[subCategory title]];
//        [transactionsTableViewController setStartDate:self.startDate];
//        [transactionsTableViewController setEndDate:self.endDate];
//        [transactionsTableViewController setManagedObjectContext:self.managedObjectContext];
//        
//        [[self navigationController] pushViewController:transactionsTableViewController animated:YES];
//    }
//}

//-(void)linePlot:(spnLinePlot*)linePlot reloadedPlot:(CPTPieChart *)plot
//{
//    // Plot data was reloaded - so refresh table
//    [self.tableView reloadData];
//}


@end
