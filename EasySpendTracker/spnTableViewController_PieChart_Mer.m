//
//  spnTableViewController_PieChart_Mer.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 12/26/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_PieChart_Mer.h"
#import "spnTransactionFetchOp.h"
#import "spnPieChartProcessDataOp.h"
#import "spnTableViewController_Transactions.h"

@interface spnTableViewController_PieChart_Mer ()

// the queue to run operations
@property (nonatomic, strong) NSOperationQueue* queue;
@property spnTransactionFetchOp* fetchOperation;
@property spnPieChartProcessDataOp* processDataOperation;

@end

@implementation spnTableViewController_PieChart_Mer

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
            [cell.textLabel setText:[NSString stringWithFormat:@"%lu Merchants", (unsigned long)self.pieChartValues.count]];
            
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
    self.processDataOperation.keyPath = [NSString stringWithFormat:@"merchant"];
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
                
                // Update pie chart table cell
                NSIndexPath* chartCellIndexPath = [NSIndexPath indexPathForRow:PIECHART_TABLE_PLOT_ROW inSection:0];
                UITableViewCell* cell = [weakSelf.tableView cellForRowAtIndexPath:chartCellIndexPath];
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
    // Get reference to selected item
    NSString* merchantTitle = [self.pieChartNames objectAtIndex:idx];
    
    // Create and Push transaction detail view controller
    spnTableViewController_Transactions* transactionsTableViewController = [[spnTableViewController_Transactions alloc] initWithStyle:UITableViewStyleGrouped];
    [transactionsTableViewController setTitle:merchantTitle];
    [transactionsTableViewController setCategoryTitle:nil];
    [transactionsTableViewController setSubCategoryTitle:nil];
    [transactionsTableViewController setMerchantTitle:merchantTitle];
    [transactionsTableViewController setStartDate:self.startDate];
    [transactionsTableViewController setEndDate:self.endDate];
    [transactionsTableViewController setManagedObjectContext:self.managedObjectContext];
    
    [[self navigationController] pushViewController:transactionsTableViewController animated:YES];
}

@end
