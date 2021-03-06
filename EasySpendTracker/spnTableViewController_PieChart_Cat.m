//
//  spnTableViewController_PieChart_Cat.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/27/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_PieChart_Cat.h"
#import "spnTableViewController_PieChart_SubCat.h"
#import "spnTransactionFetchOp.h"
#import "spnPieChartProcessDataOp.h"

@interface spnTableViewController_PieChart_Cat ()

// the queue to run operations
@property (nonatomic, strong) NSOperationQueue* queue;
@property spnTransactionFetchOp* fetchOperation;
@property spnPieChartProcessDataOp* processDataOperation;

@end

@implementation spnTableViewController_PieChart_Cat

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
            // Set category count
            [cell.textLabel setText:[NSString stringWithFormat:@"%lu Categories", (unsigned long)self.pieChartValues.count]];
            
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

-(void)updateSourceDataForPieChart:(spnPieChart*)pieChart
{
    // Need to create a week reference of self to avoid retain loop when accessing self within the block.
    __unsafe_unretained typeof(self) weakSelf = self;
    self.processDataOperation = [[spnPieChartProcessDataOp alloc] init];
    self.processDataOperation.transactionIDs = nil; // set in fetchOperation's completion block
    self.processDataOperation.keyPath = [NSString stringWithFormat:@"subCategory.category.title"];
    self.processDataOperation.predicate = nil;
    self.processDataOperation.persistentStoreCoordinator = [self.managedObjectContext persistentStoreCoordinator];
    self.processDataOperation.dataReturnBlock = ^(NSMutableArray* pieChartValues, NSMutableArray* pieChartNames) {
        
        weakSelf.pieChartValues = [[NSMutableArray alloc] initWithArray:pieChartValues copyItems:YES];
        weakSelf.pieChartNames = [[NSMutableArray alloc] initWithArray:pieChartNames copyItems:YES];
    };
    self.processDataOperation.completionBlock = ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakSelf.pieChartNames.count > 0)
            {
                // Retrieve pie chart image once data processing is complete
                weakSelf.pieChartImage = [pieChart imageWithFrame:weakSelf.imageFrame];
                
                // Update pie chart table summary cell
                NSIndexPath* chartCellIndexPath = [NSIndexPath indexPathForRow:PIECHART_TABLE_TEXT_ROW inSection:0];
                UITableViewCell* cell = [weakSelf.tableView cellForRowAtIndexPath:chartCellIndexPath];
                [weakSelf configureCell:cell atIndexPath:chartCellIndexPath];
                
                // Update pie chart table chart cell
                chartCellIndexPath = [NSIndexPath indexPathForRow:PIECHART_TABLE_PLOT_ROW inSection:0];
                cell = [weakSelf.tableView cellForRowAtIndexPath:chartCellIndexPath];
                [weakSelf configureCell:cell atIndexPath:chartCellIndexPath];
            }
            else
            {
                // Nothing to show
                weakSelf.pieChartImage = nil;
            }
            
        });
    };
    
    self.fetchOperation = [[spnTransactionFetchOp alloc] init];
    self.fetchOperation.startDate = self.startDate;
    self.fetchOperation.endDate = self.endDate;
    self.fetchOperation.persistentStoreCoordinator = [self.managedObjectContext persistentStoreCoordinator];
    self.fetchOperation.excludeCategories = self.excludeCategories;
    self.fetchOperation.includeCategories = nil; // includes all
    self.fetchOperation.includeSubCategories = nil; // includes all
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
    // Prepare sub category pie chart view
    spnTableViewController_PieChart_SubCat* subCategoryPieChart = [[spnTableViewController_PieChart_SubCat alloc] initWithStyle:UITableViewStyleGrouped];
    subCategoryPieChart.focusCategory = [self.pieChartNames objectAtIndex:idx];
    subCategoryPieChart.title = [NSString stringWithFormat:@"%@", self.pieChartNames[idx]];
    subCategoryPieChart.startDate = self.startDate;
    subCategoryPieChart.endDate = self.endDate;
    subCategoryPieChart.excludeCategories = nil;
    subCategoryPieChart.managedObjectContext = self.managedObjectContext;

    [subCategoryPieChart reloadData];
    
    [[self navigationController] pushViewController:subCategoryPieChart animated:YES];
}

@end
