//
//  spnTableViewController_PieChart_SubCat.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/27/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_PieChart_SubCat.h"
#import "spnTableViewController_SubCategories.h"
#import "spnTableViewController_Transactions.h"
#import "spnTransactionFetchOp.h"
#import "spnPieChartProcessDataOp.h"
#import "SpnCategory.h"

@interface spnTableViewController_PieChart_SubCat ()

// the queue to run spnTransactionFetchOp
@property (nonatomic, strong) NSOperationQueue* queue;
@property spnTransactionFetchOp* fetchOperation;
@property spnPieChartProcessDataOp* processDataOperation;

@property NSMutableArray* otherNamesArray;
@property NSMutableArray* otherValuesArray;

@end

#define MAX_ENTRIES 10

@implementation spnTableViewController_PieChart_SubCat

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        // Create the operation queue that will run any operations
        self.queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case PIECHART_TABLE_TEXT_ROW:
        {
            // Set focus category name
            [cell.textLabel setText:self.focusCategory];
            
            // Add chevron button
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"$%.2f", [[self.pieChartValues valueForKeyPath:@"@sum.self"] floatValue]]];
        }
            break;
            
        case PIECHART_TABLE_PLOT_ROW:
        {
            CGRect bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width);
            
            UIView* pieChartView = [[UIView alloc] initWithFrame:bounds];
            
            [self.pieChartCntrl renderInView:pieChartView withTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme] forPreview:NO animated:YES];
            
            // Create new height that accounts for the legend view - assume two columns and 24 pix per entry
            CGFloat newHeight = pieChartView.bounds.size.height + LEGEND_AREA_HEIGHT(self.pieChartNames.count);
            [pieChartView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, newHeight)];
            self.pieChartCntrl.pieChart.centerAnchor = CGPointMake(0.5, (newHeight - (self.pieChartCntrl.pieChart.pieRadius+10.0))/newHeight);
            
            [cell addSubview:pieChartView];
        }
            break;
            
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case PIECHART_TABLE_TEXT_ROW:
        {
            // Get reference to selected item
            SpnCategory* category = [SpnCategory fetchCategoryWithName:self.focusCategory inManagedObjectContext:self.managedObjectContext];
            
            // Create and Push transaction detail view controller
            spnTableViewController_SubCategories* subCategoryTableViewController = [[spnTableViewController_SubCategories alloc] initWithStyle:UITableViewStyleGrouped];
            [subCategoryTableViewController setTitle:[category title]];
            [subCategoryTableViewController setCategoryTitle:[category title]];
            [subCategoryTableViewController setStartDate:self.startDate];
            [subCategoryTableViewController setEndDate:self.endDate];
            [subCategoryTableViewController setManagedObjectContext:self.managedObjectContext];
            
            [[self navigationController] pushViewController:subCategoryTableViewController animated:YES];
        }
            break;
            
        default:
            break;
    }
}

-(void)postProcessNames:(NSMutableArray*)names andValues:(NSMutableArray*)values
{
    self.otherNamesArray = [[NSMutableArray alloc] init];
    self.otherValuesArray = [[NSMutableArray alloc] init];
    
    if (values.count > MAX_ENTRIES)
    {
        // Add objects to the 'others' array, Remove the objects from the original array
        for (NSInteger idx = values.count-1; idx >= MAX_ENTRIES-1; idx--)
        {
            [self.otherNamesArray addObject:names[idx]];
            [names removeObjectAtIndex:idx];
            [self.otherValuesArray addObject:values[idx]];
            [values removeObjectAtIndex:idx];
        }
    }
    
    // Add a single 'Other' entry to the main arrays
    if (self.otherValuesArray.count > 0)
    {
        [names addObject:@"Other"];
        [values addObject:[self.otherValuesArray valueForKeyPath:@"@sum.self"]];
    }
}

-(void)updateSourceDataForPieChart:(spnPieChart*)pieChart
{
    // Need to create a week reference of self to avoid retain loop when accessing self within the block.
    __unsafe_unretained typeof(self) weakSelf = self;
    self.processDataOperation = [[spnPieChartProcessDataOp alloc] init];
    self.processDataOperation.transactionIDs = nil; // set in fetchOperation's completion block
    self.processDataOperation.keyPath = [NSString stringWithFormat:@"subCategory.title"];
    self.processDataOperation.predicate = [NSPredicate predicateWithFormat:@"subCategory.category.title MATCHES[cd] %@", self.focusCategory];
    self.processDataOperation.persistentStoreCoordinator = [self.managedObjectContext persistentStoreCoordinator];
    self.processDataOperation.dataReturnBlock = ^(NSMutableArray* pieChartValues, NSMutableArray* pieChartNames) {
        
        weakSelf.pieChartValues = [[NSMutableArray alloc] initWithArray:pieChartValues copyItems:YES];
        weakSelf.pieChartNames = [[NSMutableArray alloc] initWithArray:pieChartNames copyItems:YES];
    };
    self.processDataOperation.completionBlock = ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakSelf.pieChartNames.count > 0)
            {
                [weakSelf postProcessNames:weakSelf.pieChartNames andValues:weakSelf.pieChartValues];
                
                // Update pie chart table summary cell
                NSIndexPath* chartCellIndexPath = [NSIndexPath indexPathForRow:PIECHART_TABLE_TEXT_ROW inSection:0];
                UITableViewCell* cell = [weakSelf.tableView cellForRowAtIndexPath:chartCellIndexPath];
                [weakSelf configureCell:cell atIndexPath:chartCellIndexPath];
                
                // Update pie chart table chart cell
                chartCellIndexPath = [NSIndexPath indexPathForRow:PIECHART_TABLE_PLOT_ROW inSection:0];
                cell = [weakSelf.tableView cellForRowAtIndexPath:chartCellIndexPath];
                [weakSelf configureCell:cell atIndexPath:chartCellIndexPath];
            }
        });
    };
    
    self.fetchOperation = [[spnTransactionFetchOp alloc] init];
    self.fetchOperation.startDate = self.startDate;
    self.fetchOperation.endDate = self.endDate;
    self.fetchOperation.persistentStoreCoordinator = [self.managedObjectContext persistentStoreCoordinator];
    self.fetchOperation.excludeCategories = self.excludeCategories;
    self.fetchOperation.dataReturnBlock = ^(NSMutableArray* objectIDs, NSError* error) {
        
        weakSelf.processDataOperation.transactionIDs = objectIDs;
    };
    
    // Process data operation depends on the fetch operation
    [self.processDataOperation addDependency:self.fetchOperation];
    
    // start the operations
    [self.queue addOperation:self.fetchOperation];
    [self.queue addOperation:self.processDataOperation];
}

//<spnPieChartDelegate> methods>
-(void)pieChart:(spnPieChart*)pieChart entryWasSelectedAtIndex:(NSUInteger)idx
{
    // Get reference to selected item
    SpnCategory* category = [SpnCategory fetchCategoryWithName:self.focusCategory inManagedObjectContext:self.managedObjectContext];
    
    NSArray* subCategoryTitles;
    NSString* transactionsTableViewControllerTitle;
    
    // Get reference to selected item
    if (idx < (MAX_ENTRIES-1))
    {
        subCategoryTitles = @[self.pieChartNames[idx]];
        transactionsTableViewControllerTitle = [NSString stringWithFormat:@"$%.2f", [self.pieChartValues[idx] floatValue]];
    }
    else
    {
        subCategoryTitles = self.otherNamesArray;
        transactionsTableViewControllerTitle = [NSString stringWithFormat:@"$%.2f", [[self.otherValuesArray valueForKeyPath:@"@sum.self"] floatValue]];
    }
    
    // Create and Push transaction detail view controller
    spnTableViewController_Transactions* transactionsTableViewController = [[spnTableViewController_Transactions alloc] initWithStyle:UITableViewStyleGrouped];
    [transactionsTableViewController setTitle:transactionsTableViewControllerTitle];
    [transactionsTableViewController setCategoryTitles:@[category.title]];
    [transactionsTableViewController setSubCategoryTitles:subCategoryTitles];
    [transactionsTableViewController setMerchantTitles:nil];
    [transactionsTableViewController setStartDate:self.startDate];
    [transactionsTableViewController setEndDate:self.endDate];
    [transactionsTableViewController setManagedObjectContext:self.managedObjectContext];
    
    [[self navigationController] pushViewController:transactionsTableViewController animated:YES];
}


@end
