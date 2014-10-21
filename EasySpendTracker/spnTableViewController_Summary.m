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

@interface spnTableViewController_Summary ()

@property NSDate* thisMonthLastYear;
@property NSDate* firstDayOfThisMonth;
@property NSDate* firstDayOfNextMonth;

@property spnTableViewController_PieChart_Cat* pieChartTableThisMonthExpenses;
@property spnTableViewController_PieChart_Cat* pieChartTableThisMonthIncomeExpenses;
@property spnTableViewController_PieChart_Cat* pieChartTableAllTimeExpenses;
@property spnTableViewController_PieChart_Cat* pieChartTableAllTimeIncomeExpenses;
@property spnTableViewController_LinePlot_Cat* categoryLinePlotTableView;

@property NSMutableArray* chartImageCache;

@end

#define PIE_CHART_HEIGHT 100.0
#define LINE_PLOT_HEIGHT 200.0

enum
{
    ROW_SUMMARY,
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
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    // The first of this month
    NSDateComponents* dateComponents = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    [dateComponents setDay:1];
    self.firstDayOfThisMonth = [calendar dateFromComponents:dateComponents];
    [dateComponents setDay:0];
    
    // This month, one year ago
    NSDateComponents* tempComponents = [[NSDateComponents alloc] init];
    [tempComponents setYear:-1];
    self.thisMonthLastYear = [calendar dateByAddingComponents:tempComponents toDate:self.firstDayOfThisMonth options:0];
    
    [tempComponents setMonth:1];
    [tempComponents setYear:0];
    
    NSDate* thisDayNextMonth = [calendar dateByAddingComponents:tempComponents toDate:[NSDate date] options:0];
    
    tempComponents = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:thisDayNextMonth];
    [tempComponents setDay:1];
    
    // First day of the next month
    self.firstDayOfNextMonth = [calendar dateFromComponents:tempComponents];
    
    
    
    self.chartImageCache = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"Empty_Pie_Chart"], [UIImage imageNamed:@"Empty_Pie_Chart"], [UIImage imageNamed:@"Empty_Pie_Chart"], [UIImage imageNamed:@"Empty_Pie_Chart"], [UIImage imageNamed:@"Empty_Pie_Chart"], [UIImage imageNamed:@"Empty_Line_Plot"], nil];
    
//    [self updatePieCharts];
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
    // This Month - Expenses
    self.pieChartTableThisMonthExpenses = [[spnTableViewController_PieChart_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableThisMonthExpenses.title = @"This Month's Expenses";
    self.pieChartTableThisMonthExpenses.startDate = self.firstDayOfThisMonth;
    self.pieChartTableThisMonthExpenses.endDate = self.firstDayOfNextMonth;
    self.pieChartTableThisMonthExpenses.excludeCategories = [NSArray arrayWithObjects: [NSString stringWithFormat:@"Income"], nil];
    self.pieChartTableThisMonthExpenses.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableThisMonthExpenses addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // This Month - Income and Expenses
    self.pieChartTableThisMonthIncomeExpenses = [[spnTableViewController_PieChart_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableThisMonthIncomeExpenses.title = @"This Month's Income";
    self.pieChartTableThisMonthIncomeExpenses.startDate = self.firstDayOfThisMonth;
    self.pieChartTableThisMonthIncomeExpenses.endDate = self.firstDayOfNextMonth;
    self.pieChartTableThisMonthIncomeExpenses.excludeCategories = nil;
    self.pieChartTableThisMonthIncomeExpenses.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableThisMonthIncomeExpenses addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // All Time - Expenses
    self.pieChartTableAllTimeExpenses = [[spnTableViewController_PieChart_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableAllTimeExpenses.title = @"All Time Expenses";
    self.pieChartTableAllTimeExpenses.startDate = nil;
    self.pieChartTableAllTimeExpenses.endDate = nil;
    self.pieChartTableAllTimeExpenses.excludeCategories = [NSArray arrayWithObjects: [NSString stringWithFormat:@"Income"], nil];
    self.pieChartTableAllTimeExpenses.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableAllTimeExpenses addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // All Time - Income and Expenses
    self.pieChartTableAllTimeIncomeExpenses = [[spnTableViewController_PieChart_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableAllTimeIncomeExpenses.title = @"All Time Income";
    self.pieChartTableAllTimeIncomeExpenses.startDate = nil;
    self.pieChartTableAllTimeIncomeExpenses.endDate = nil;
    self.pieChartTableAllTimeIncomeExpenses.excludeCategories = nil;
    self.pieChartTableAllTimeIncomeExpenses.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableAllTimeIncomeExpenses addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // Line Plot
    self.categoryLinePlotTableView = [[spnTableViewController_LinePlot_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.categoryLinePlotTableView.title = @"Spending - Last 12 Months";
    self.categoryLinePlotTableView.startDate = self.thisMonthLastYear;
    self.categoryLinePlotTableView.endDate = nil;
    self.categoryLinePlotTableView.excludeCategories = [NSArray arrayWithObjects: [NSString stringWithFormat:@"Income"], nil];
    self.categoryLinePlotTableView.includeCategories = nil;
    self.categoryLinePlotTableView.managedObjectContext = self.managedObjectContext;
    self.categoryLinePlotTableView.entityName = @"SpnCategoryMO";
    [self.categoryLinePlotTableView addObserver:self forKeyPath:@"linePlotImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &observeChartPreviewContext)
    {
        UITableViewCell* cell;
        UIImage* previewImage;
        NSInteger row = 0;
        
        if (object == self.pieChartTableThisMonthExpenses)
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
        else if (object == self.categoryLinePlotTableView)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_LINE inSection:0]];
                    previewImage = self.categoryLinePlotTableView.linePlotImage;
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
            // get imageContainerView => imageView
            UIImageView* imageView = (UIImageView*)[cell viewWithTag:CELL_CHART_TAG_IMG];
            imageView.image = previewImage;
            imageView.alpha = 0.0;
            
            // fancy image fade in with cached image fade out
            [UIView animateWithDuration:0.5 animations:^(void){
                
                imageView.alpha = 1.0;
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
    // this will dispatch a concurrent task to recompute a preview image - KVO is used to detect when this is complete
    switch (indexPath.row)
    {
        case ROW_THIS_MONTH_EXPENSE:
        {
            self.pieChartTableThisMonthExpenses.imageFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, PIE_CHART_HEIGHT);
            [self.pieChartTableThisMonthExpenses reloadData];
            
            UILabel* textLabel = (UILabel*)[cell viewWithTag:CELL_CHART_TAG_LABEL];
            [textLabel setText:@"This Month's Expenses:"];
        }
            break;
            
        case ROW_THIS_MONTH_INCOME_EXPENSE:
        {
            self.pieChartTableThisMonthIncomeExpenses.imageFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, PIE_CHART_HEIGHT);
            [self.pieChartTableThisMonthIncomeExpenses reloadData];
            
            UILabel* textLabel = (UILabel*)[cell viewWithTag:CELL_CHART_TAG_LABEL];
            [textLabel setText:@"This Month's Income/Expenses:"];
        }
            break;
            
        case ROW_ALL_TIME_EXPENSE:
        {
            self.pieChartTableAllTimeExpenses.imageFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, PIE_CHART_HEIGHT);
            [self.pieChartTableAllTimeExpenses reloadData];
            
            UILabel* textLabel = (UILabel*)[cell viewWithTag:CELL_CHART_TAG_LABEL];
            [textLabel setText:@"All Time Expenses:"];
        }
            break;
            
        case ROW_ALL_TIME_INCOME_EXPENSE:
        {
            self.pieChartTableAllTimeIncomeExpenses.imageFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, PIE_CHART_HEIGHT);
            [self.pieChartTableAllTimeIncomeExpenses reloadData];
            
            UILabel* textLabel = (UILabel*)[cell viewWithTag:CELL_CHART_TAG_LABEL];
            [textLabel setText:@"All Time Income/Expenses:"];
        }
            break;
            
        case ROW_LINE:
        {
            self.categoryLinePlotTableView.imageFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, LINE_PLOT_HEIGHT);
            [self.categoryLinePlotTableView reloadAllCategoriesPlotData];
            
            UILabel* textLabel = (UILabel*)[cell viewWithTag:CELL_CHART_TAG_LABEL];
            [textLabel setText:@"Spending - Last 12 Months:"];
        }
            break;
            
        default:
            break;
    }
    
    switch (indexPath.row)
    {
        case ROW_SUMMARY:
        {
            NSArray *expenseResultsThisMonth;
            NSArray *incomeResultsThisMonth;
            NSNumber* expenseTotalThisMonth;
            NSNumber* incomeTotalThisMonth;
            NSError* error;
            
            UILabel* textLabel = (UILabel*)[cell viewWithTag:1];
            
            NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SpnTransactionMO"];
            NSPredicate* predicate;
            
            // Get all expense results from this month
            predicate = [NSPredicate predicateWithFormat:@"NOT(subCategory.category.title LIKE %@) AND (date >= %@) AND (date < %@)", @"Income", self.firstDayOfThisMonth, self.firstDayOfNextMonth];
            fetchRequest.predicate = predicate;
            
            expenseResultsThisMonth = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            expenseTotalThisMonth = [expenseResultsThisMonth valueForKeyPath:@"@sum.value"];
            
            // Get all income results from this month
            predicate = [NSPredicate predicateWithFormat:@"(subCategory.category.title LIKE %@) AND (date >= %@) AND (date < %@)", @"Income", self.firstDayOfThisMonth, self.firstDayOfNextMonth];
            fetchRequest.predicate = predicate;
            
            incomeResultsThisMonth = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            incomeTotalThisMonth = [incomeResultsThisMonth valueForKeyPath:@"@sum.value"];
            
            [textLabel setText:[NSString stringWithFormat:@"Income: $%.2f - Expenses: $%.2f = Balance: $%.2f", incomeTotalThisMonth.floatValue, expenseTotalThisMonth.floatValue, (incomeTotalThisMonth.floatValue - expenseTotalThisMonth.floatValue)]];
        }
            break;
            
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
    NSArray* reuseIdentifier = [NSArray arrayWithObjects:@"summaryCell", @"pieChartCell", @"pieChartCell", @"pieChartCell", @"pieChartCell", @"linePlotCell", nil];
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier[indexPath.row]];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.row]];
        
        switch (indexPath.row)
        {
            case ROW_SUMMARY:
            {
                // Create text label
                UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 44.0)];
                textLabel.tag = CELL_CHART_TAG_LABEL;
                textLabel.adjustsFontSizeToFitWidth = YES;
    
                [cell addSubview:textLabel];
            }
                break;
                
            case ROW_THIS_MONTH_EXPENSE:
            case ROW_THIS_MONTH_INCOME_EXPENSE:
            case ROW_ALL_TIME_EXPENSE:
            case ROW_ALL_TIME_INCOME_EXPENSE:
            {
                // Create text label
                UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 44.0)];
                textLabel.tag = CELL_CHART_TAG_LABEL;
                
                // Gather chart preview container
                UIImageView* cachedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, PIE_CHART_HEIGHT)];
                cachedImageView.tag = CELL_CHART_TAG_CACHED_IMG;
                
                UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, PIE_CHART_HEIGHT)];
                imageView.tag = CELL_CHART_TAG_IMG;
                
                UIView* imageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44.0, self.tableView.bounds.size.width, imageView.frame.size.height)];
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
                UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 44.0)];
                textLabel.tag = CELL_CHART_TAG_LABEL;
                
                // Gather chart preview container
                UIImageView* cachedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, LINE_PLOT_HEIGHT)];
                cachedImageView.tag = CELL_CHART_TAG_CACHED_IMG;
                
                UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, LINE_PLOT_HEIGHT)];
                imageView.tag = CELL_CHART_TAG_IMG;
                
                UIView* imageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44.0, self.tableView.bounds.size.width, imageView.frame.size.height)];
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
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Must be in the same order as row enums
    NSArray* rowHeight = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:44],
                          [NSNumber numberWithFloat:PIE_CHART_HEIGHT+44],
                          [NSNumber numberWithFloat:PIE_CHART_HEIGHT+44],
                          [NSNumber numberWithFloat:PIE_CHART_HEIGHT+44],
                          [NSNumber numberWithFloat:PIE_CHART_HEIGHT+44],
                          [NSNumber numberWithFloat:LINE_PLOT_HEIGHT+44],
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
            [[self navigationController] pushViewController:self.categoryLinePlotTableView animated:YES];
            break;
            
        default:
            break;
    }
}

@end
