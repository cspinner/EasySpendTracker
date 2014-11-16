//
//  spnTableViewController_Summary.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 8/22/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Summary.h"
#import "UIViewController+addTransactionHandles.h"
#import "SpnTransaction.h"
#import "SpnCategory.h"
#import "SpnSubCategory.h"
#import "spnTableViewController_PieChart_Cat.h"
#import "spnTableViewController_LinePlot_Cat.h"
#import "spnTableViewController_BarPlot.h"
#import "NSDate+Convenience.h"

@interface spnTableViewController_Summary ()

@property spnTableViewController_BarPlot* barPlotCashFlowByMonth;
@property spnTableViewController_PieChart_Cat* pieChartTableThisMonthExpenses;
@property spnTableViewController_PieChart_Cat* pieChartTableThisMonthIncomeExpenses;
@property spnTableViewController_PieChart_Cat* pieChartTableAllTimeExpenses;
@property spnTableViewController_PieChart_Cat* pieChartTableAllTimeIncomeExpenses;
@property spnTableViewController_LinePlot_Cat* linePlotAllExpenses;

@property NSArray* chartImageDefaults;
@property NSMutableArray* chartImageCache;

@end

#define BAR_PLOT_HEIGHT 200.0
#define PIE_CHART_HEIGHT 100.0
#define LINE_PLOT_HEIGHT 200.0

enum
{
    ROW_CASH_FLOW,
    ROW_THIS_MONTH_EXPENSE,
    ROW_THIS_MONTH_INCOME_EXPENSE,
    ROW_ALL_TIME_EXPENSE,
    ROW_ALL_TIME_INCOME_EXPENSE,
    ROW_LINE,
    ROW_COUNT
};

enum
{
    CELL_CHART_TAG_LABEL = 1,
    CELL_CHART_TAG_CACHED_IMG,
    CELL_CHART_TAG_IMG,
    CELL_CHART_TAG_ACTIVITY
};

int observeChartPreviewContext;

@implementation spnTableViewController_Summary

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
//        [self initCharts];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(spnAddButtonClicked:)];
    
    self.chartImageDefaults = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"Empty_Bar_Plot"], [UIImage imageNamed:@"Empty_Pie_Chart"], [UIImage imageNamed:@"Empty_Pie_Chart"], [UIImage imageNamed:@"Empty_Pie_Chart"], [UIImage imageNamed:@"Empty_Pie_Chart"], [UIImage imageNamed:@"Empty_Line_Plot"], nil];
    self.chartImageCache = [[NSMutableArray alloc] initWithArray:self.chartImageDefaults copyItems:YES];
    
    [self initCharts];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initCharts
{
    NSDate* firstDayOfNextMonth = [[NSDate dateStartOfMonth:[NSDate date]] offsetMonth:1];;
    
    // Last 4 month's cash flow
    self.barPlotCashFlowByMonth = [[spnTableViewController_BarPlot alloc] initWithStyle:UITableViewStyleGrouped];
    self.barPlotCashFlowByMonth.title = @"Cash Flow";
    self.barPlotCashFlowByMonth.startDate = [[NSDate dateStartOfMonth:[NSDate date]] offsetMonth:-3];
    self.barPlotCashFlowByMonth.endDate = firstDayOfNextMonth;
    self.barPlotCashFlowByMonth.managedObjectContext = self.managedObjectContext;
    [self.barPlotCashFlowByMonth addObserver:self forKeyPath:@"barPlotImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // This Month - Expenses
    self.pieChartTableThisMonthExpenses = [[spnTableViewController_PieChart_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableThisMonthExpenses.title = @"This Month's Expenses";
    self.pieChartTableThisMonthExpenses.startDate = [NSDate dateStartOfMonth:[NSDate date]];
    self.pieChartTableThisMonthExpenses.endDate = firstDayOfNextMonth;
    self.pieChartTableThisMonthExpenses.excludeCategories = [NSArray arrayWithObjects: [NSString stringWithFormat:@"Income"], nil];
    self.pieChartTableThisMonthExpenses.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableThisMonthExpenses addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // This Month - Income and Expenses
    self.pieChartTableThisMonthIncomeExpenses = [[spnTableViewController_PieChart_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableThisMonthIncomeExpenses.title = @"This Month's Income";
    self.pieChartTableThisMonthIncomeExpenses.startDate = [NSDate dateStartOfMonth:[NSDate date]];
    self.pieChartTableThisMonthIncomeExpenses.endDate = firstDayOfNextMonth;
    self.pieChartTableThisMonthIncomeExpenses.excludeCategories = nil;
    self.pieChartTableThisMonthIncomeExpenses.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableThisMonthIncomeExpenses addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // All Time - Expenses
    self.pieChartTableAllTimeExpenses = [[spnTableViewController_PieChart_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableAllTimeExpenses.title = @"All Time Expenses";
    self.pieChartTableAllTimeExpenses.startDate = nil;
    self.pieChartTableAllTimeExpenses.endDate = firstDayOfNextMonth;
    self.pieChartTableAllTimeExpenses.excludeCategories = [NSArray arrayWithObjects: [NSString stringWithFormat:@"Income"], nil];
    self.pieChartTableAllTimeExpenses.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableAllTimeExpenses addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // All Time - Income and Expenses
    self.pieChartTableAllTimeIncomeExpenses = [[spnTableViewController_PieChart_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableAllTimeIncomeExpenses.title = @"All Time Income";
    self.pieChartTableAllTimeIncomeExpenses.startDate = nil;
    self.pieChartTableAllTimeIncomeExpenses.endDate = firstDayOfNextMonth;
    self.pieChartTableAllTimeIncomeExpenses.excludeCategories = nil;
    self.pieChartTableAllTimeIncomeExpenses.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableAllTimeIncomeExpenses addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // Line Plot
    self.linePlotAllExpenses = [[spnTableViewController_LinePlot_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.linePlotAllExpenses.title = @"Spending - Last 12 Months";
    self.linePlotAllExpenses.startDate = [[NSDate dateStartOfMonth:[NSDate date]] offsetYear:-1];
    self.linePlotAllExpenses.endDate = firstDayOfNextMonth;
    self.linePlotAllExpenses.excludeCategories = [NSArray arrayWithObjects: [NSString stringWithFormat:@"Income"], nil];
    self.linePlotAllExpenses.includeCategories = nil;
    self.linePlotAllExpenses.managedObjectContext = self.managedObjectContext;
    self.linePlotAllExpenses.entityName = @"SpnCategoryMO";
    [self.linePlotAllExpenses addObserver:self forKeyPath:@"linePlotImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &observeChartPreviewContext)
    {
        UITableViewCell* cell;
        UIImage* previewImage;
        NSInteger row = 0;
        
        if (object == self.barPlotCashFlowByMonth)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_CASH_FLOW inSection:0]];
                    previewImage = self.barPlotCashFlowByMonth.barPlotImage;
                    row = ROW_CASH_FLOW;
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.pieChartTableThisMonthExpenses)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_THIS_MONTH_EXPENSE inSection:0]];
                    previewImage = self.pieChartTableThisMonthExpenses.pieChartImage;
                    row = ROW_THIS_MONTH_EXPENSE;
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.pieChartTableThisMonthIncomeExpenses)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_THIS_MONTH_INCOME_EXPENSE inSection:0]];
                    previewImage = self.pieChartTableThisMonthIncomeExpenses.pieChartImage;
                    row = ROW_THIS_MONTH_INCOME_EXPENSE;
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.pieChartTableAllTimeExpenses)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_ALL_TIME_EXPENSE inSection:0]];
                    previewImage = self.pieChartTableAllTimeExpenses.pieChartImage;
                    row = ROW_ALL_TIME_EXPENSE;
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.pieChartTableAllTimeIncomeExpenses)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_ALL_TIME_INCOME_EXPENSE inSection:0]];
                    previewImage = self.pieChartTableAllTimeIncomeExpenses.pieChartImage;
                    row = ROW_ALL_TIME_INCOME_EXPENSE;
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.linePlotAllExpenses)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_LINE inSection:0]];
                    previewImage = self.linePlotAllExpenses.linePlotImage;
                    row = ROW_LINE;
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        
        if ([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeSetting)
        {
            // If the preview image wasn't updated
            if (previewImage == nil)
            {
                // The preview image would be nil if there are no transactions to draw an image. For this case, just use the canned image.
                previewImage = self.chartImageDefaults[row];
                self.chartImageCache[row] = previewImage;
            }
            
            // get imageContainerView => cachedImageView
            UIImageView* cachedImageView = (UIImageView*)[cell viewWithTag:CELL_CHART_TAG_CACHED_IMG];
            cachedImageView.alpha = 1.0;
            
            // get imageContainerView => imageView
            UIImageView* imageView = (UIImageView*)[cell viewWithTag:CELL_CHART_TAG_IMG];
            imageView.image = previewImage;
            imageView.alpha = 0.0;
            
            // fancy image fade in with cached image fade out
            [UIView animateWithDuration:0.5 animations:^(void){
                // Fade in the new image
                imageView.alpha = 1.0;
                
            } completion:^(BOOL finished){
                // Next fade out the old image
                if (finished)
                {
                    [UIView animateWithDuration:0.5 animations:^(void){
                        
                        cachedImageView.alpha = 0.0;
                    }];
                }
            }];
            
            // Stop spinning wheel animation now that image is loaded
            UIActivityIndicatorView* activityView = (UIActivityIndicatorView*)[cell viewWithTag:CELL_CHART_TAG_ACTIVITY];
            [activityView stopAnimating];
            
            // save the image to the cache
            self.chartImageCache[row] = previewImage;
        }
    }
    
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Depending on the row, we might need to load a chart:
    
    // Assign cached image first:
    switch (indexPath.row)
    {
        case ROW_CASH_FLOW:
        case ROW_THIS_MONTH_EXPENSE:
        case ROW_THIS_MONTH_INCOME_EXPENSE:
        case ROW_ALL_TIME_EXPENSE:
        case ROW_ALL_TIME_INCOME_EXPENSE:
        case ROW_LINE:
        {
            // get imageContainerView => imageView
            UIImageView* cachedImageView = (UIImageView*)[cell viewWithTag:CELL_CHART_TAG_CACHED_IMG];
            
            // assign the previously obtained chart preview to the cell
            cachedImageView.image = self.chartImageCache[indexPath.row];
            cachedImageView.alpha = 1.0;
            
            UIActivityIndicatorView* activityView = (UIActivityIndicatorView*)[cell viewWithTag:CELL_CHART_TAG_ACTIVITY];
            [activityView startAnimating];
        }
            break;
            
        default:
            break;
    }
}

// <UITableViewDataSource> methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* reuseIdentifier = [NSArray arrayWithObjects:@"barPlotCell", @"pieChartCell", @"pieChartCell", @"pieChartCell", @"pieChartCell", @"linePlotCell", nil];
    
    // Must be in the same order as row enum
    NSArray* headerText = [NSArray arrayWithObjects:
                           @"CASH FLOW",
                           @"EXPENSES - THIS MONTH",
                           @"INCOME/EXPENSES - THIS MONTH",
                           @"EXPENSES - ALL TIME",
                           @"INCOME/EXPENSES - ALL TIME",
                           @"EXPENSES - LAST 12 MONTHS",
                           nil];
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier[indexPath.row]];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.row]];
        
        switch (indexPath.row)
        {
            case ROW_CASH_FLOW:
            {
                // Create text label
                UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 25.0)];
                textLabel.tag = CELL_CHART_TAG_LABEL;
                
                // Gather chart preview container
                UIImageView* cachedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, BAR_PLOT_HEIGHT)];
                cachedImageView.tag = CELL_CHART_TAG_CACHED_IMG;
                
                UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, BAR_PLOT_HEIGHT)];
                imageView.tag = CELL_CHART_TAG_IMG;
                
                UIView* imageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 25.0, self.tableView.bounds.size.width, imageView.frame.size.height)];
                [imageContainerView addSubview:cachedImageView];
                [imageContainerView addSubview:imageView];
                
                UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [activityView setFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, [self tableView:self.tableView heightForRowAtIndexPath:indexPath])];
                [activityView setHidesWhenStopped:YES];
                activityView.tag = CELL_CHART_TAG_ACTIVITY;
                
                [cell addSubview:textLabel];
                [cell addSubview:imageContainerView];
                [cell addSubview:activityView];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
                break;
                
            case ROW_THIS_MONTH_EXPENSE:
            case ROW_THIS_MONTH_INCOME_EXPENSE:
            case ROW_ALL_TIME_EXPENSE:
            case ROW_ALL_TIME_INCOME_EXPENSE:
            {
                // Create text label
                UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 25.0)];
                textLabel.tag = CELL_CHART_TAG_LABEL;
                
                // Gather chart preview container
                UIImageView* cachedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, PIE_CHART_HEIGHT)];
                cachedImageView.tag = CELL_CHART_TAG_CACHED_IMG;
                
                UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, PIE_CHART_HEIGHT)];
                imageView.tag = CELL_CHART_TAG_IMG;
                
                UIView* imageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 25.0, self.tableView.bounds.size.width, imageView.frame.size.height)];
                [imageContainerView addSubview:cachedImageView];
                [imageContainerView addSubview:imageView];
                
                UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [activityView setFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, [self tableView:self.tableView heightForRowAtIndexPath:indexPath])];
                [activityView setHidesWhenStopped:YES];
                activityView.tag = CELL_CHART_TAG_ACTIVITY;
                
                [cell addSubview:textLabel];
                [cell addSubview:imageContainerView];
                [cell addSubview:activityView];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
                break;
                
            case ROW_LINE:
            {
                // Create text label
                UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 25.0)];
                textLabel.tag = CELL_CHART_TAG_LABEL;
                
                // Gather chart preview container
                UIImageView* cachedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, LINE_PLOT_HEIGHT)];
                cachedImageView.tag = CELL_CHART_TAG_CACHED_IMG;
                
                UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, LINE_PLOT_HEIGHT)];
                imageView.tag = CELL_CHART_TAG_IMG;
                
                UIView* imageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 25.0, self.tableView.bounds.size.width, imageView.frame.size.height)];
                [imageContainerView addSubview:cachedImageView];
                [imageContainerView addSubview:imageView];
                
                UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [activityView setFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, [self tableView:self.tableView heightForRowAtIndexPath:indexPath])];
                [activityView setHidesWhenStopped:YES];
                activityView.tag = CELL_CHART_TAG_ACTIVITY;
                
                [cell addSubview:textLabel];
                [cell addSubview:imageContainerView];
                [cell addSubview:activityView];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
                break;


                
            default:
                break;
        }
        
        
        // Set text label based on section index
        UILabel* headerLabel = (UILabel*)[cell viewWithTag:CELL_CHART_TAG_LABEL];
        [headerLabel setText:headerText[indexPath.row]];
        [headerLabel setFont:[UIFont systemFontOfSize:12]];
        [headerLabel setTextColor:[UIColor grayColor]];
    }
    
    // Configure cell contents
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ROW_COUNT;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}


// <UITableViewDelegate> methods
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now's the time to command the chart view to generate the preview image.
    // The delay is allow the cell to become visible before the the image preview observer is triggered
    #define PERFORM_RELOAD_DELAY 0.001
    
    switch (indexPath.row)
    {
        case ROW_CASH_FLOW:
        {
            self.barPlotCashFlowByMonth.imageFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, BAR_PLOT_HEIGHT);
            [self.barPlotCashFlowByMonth performSelector:@selector(reloadData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
        }
            break;
            
        case ROW_THIS_MONTH_EXPENSE:
        {
            self.pieChartTableThisMonthExpenses.imageFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, PIE_CHART_HEIGHT);
            [self.pieChartTableThisMonthExpenses performSelector:@selector(reloadData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
        }
            break;
            
        case ROW_THIS_MONTH_INCOME_EXPENSE:
        {
            self.pieChartTableThisMonthIncomeExpenses.imageFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, PIE_CHART_HEIGHT);
            [self.pieChartTableThisMonthIncomeExpenses performSelector:@selector(reloadData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
        }
            break;
            
        case ROW_ALL_TIME_EXPENSE:
        {
            self.pieChartTableAllTimeExpenses.imageFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, PIE_CHART_HEIGHT);
            [self.pieChartTableAllTimeExpenses performSelector:@selector(reloadData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
        }
            break;
            
        case ROW_ALL_TIME_INCOME_EXPENSE:
        {
            self.pieChartTableAllTimeIncomeExpenses.imageFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, PIE_CHART_HEIGHT);
            [self.pieChartTableAllTimeIncomeExpenses performSelector:@selector(reloadData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
        }
            break;
            
        case ROW_LINE:
        {
            self.linePlotAllExpenses.imageFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, LINE_PLOT_HEIGHT);
            [self.linePlotAllExpenses performSelector:@selector(reloadAllCategoriesPlotData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
        }
            break;

        default:
            break;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Must be in the same order as row enums
    NSArray* rowHeight = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:BAR_PLOT_HEIGHT+25],
                          [NSNumber numberWithFloat:PIE_CHART_HEIGHT+25],
                          [NSNumber numberWithFloat:PIE_CHART_HEIGHT+25],
                          [NSNumber numberWithFloat:PIE_CHART_HEIGHT+25],
                          [NSNumber numberWithFloat:PIE_CHART_HEIGHT+25],
                          [NSNumber numberWithFloat:LINE_PLOT_HEIGHT+25],
                          nil];
    
    return (CGFloat)[rowHeight[indexPath.row] floatValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case ROW_THIS_MONTH_EXPENSE:
            [[self navigationController] pushViewController:self.pieChartTableThisMonthExpenses animated:YES];
            break;
            
        case ROW_THIS_MONTH_INCOME_EXPENSE:
            [[self navigationController] pushViewController:self.pieChartTableThisMonthIncomeExpenses animated:YES];
            break;
            
        case ROW_ALL_TIME_EXPENSE:
            [[self navigationController] pushViewController:self.pieChartTableAllTimeExpenses animated:YES];
            break;
            
        case ROW_ALL_TIME_INCOME_EXPENSE:
            [[self navigationController] pushViewController:self.pieChartTableAllTimeIncomeExpenses animated:YES];
            break;
            
        case ROW_LINE:
            [[self navigationController] pushViewController:self.linePlotAllExpenses animated:YES];
            break;
            
        case ROW_CASH_FLOW:
        default:
            break;
    }
}

@end
