//
//  spnTableViewController_PieChart.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 8/17/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_PieChart.h"
#import "UIViewController+addTransactionHandles.h"

@interface spnTableViewController_PieChart ()

@end

@implementation spnTableViewController_PieChart

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

- (void)reloadData
{
    self.pieChartCntrl = [[spnPieChart alloc] init];
    self.pieChartCntrl.delegate = self;
    
    [self updateSourceDataForPieChart:self.pieChartCntrl];
}

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    // to be overriden by sub-class
}

-(void)updateSourceDataForPieChart:(spnPieChart*)pieChart
{
    // to be overriden by sub-class
}

// <UITableViewDataSource> methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* CellIdentifiers = [NSArray arrayWithObjects:@"InfoCell", @"PieChartCell", nil];
    
    // Acquire reuse cell object from the table view
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifiers[indexPath.row]];
    
    if (!cell)
    {
        // Create cell if reuse cell doesn't exist.
        switch (indexPath.row)
        {
            case PIECHART_TABLE_TEXT_ROW:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifiers[indexPath.row]];
            }
                break;
                
            case PIECHART_TABLE_PLOT_ROW:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifiers[indexPath.row]];
            }
                break;
                
            default:
                return nil;
                break;
        }
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return PIECHART_TABLE_ROW_COUNT;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// <UITableViewDelegate> methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case PIECHART_TABLE_PLOT_ROW:
            return self.view.bounds.size.width+LEGEND_AREA_HEIGHT(self.pieChartNames.count);
            break;
            
        case PIECHART_TABLE_TEXT_ROW:
        default:
            return 44.0;
            break;
    }
}

//<spnPieChartDelegate> methods>
-(NSArray*)dataArrayForPieChart:(spnPieChart*)pieChart
{
    return self.pieChartValues;
}

-(NSArray*)titleArrayForPieChart:(spnPieChart*)pieChart
{
    return self.pieChartNames;
}

-(void)pieChart:(spnPieChart*)pieChart entryWasSelectedAtIndex:(NSUInteger)idx
{
    // to be overridden by sub-class
}

-(void)pieChart:(spnPieChart*)pieChart reloadedPlot:(CPTPieChart *)plot
{
    // Plot data was reloaded - so refresh table
    [self.tableView reloadData];
}


@end
