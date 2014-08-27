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
#import "spnTableViewController_PieChart.h"

@interface spnTableViewController_Summary ()

@property NSDate* firstDayOfThisMonth;
@property NSDate* firstDayOfNextMonth;

@property NSArray *expenseResultsThisMonth;
@property NSArray *incomeResultsThisMonth;

@property spnTableViewController_PieChart* pieChartTableThisMonthExpenses;
@property spnTableViewController_PieChart* pieChartTableThisMonthIncome;
@property spnTableViewController_PieChart* pieChartTableAllTimeExpenses;
@property spnTableViewController_PieChart* pieChartTableAllTimeIncome;

@end

enum
{
    ROW_SUMMARY,
    ROW_THIS_MONTH_EXPENSE,
    ROW_THIS_MONTH_INCOME,
    ROW_ALL_TIME_EXPENSE,
    ROW_ALL_TIME_INCOME,
    ROW_COUNT
};

@implementation spnTableViewController_Summary

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
    
    NSDateComponents* tempComponents = [[NSDateComponents alloc] init];
    [tempComponents setMonth:1];
    
    NSDate* thisDayNextMonth = [calendar dateByAddingComponents:tempComponents toDate:[NSDate date] options:0];
    
    tempComponents = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:thisDayNextMonth];
    [tempComponents setDay:1];
    
    // First day of the next month
    self.firstDayOfNextMonth = [calendar dateFromComponents:tempComponents];
    
    [self updatePieCharts];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updatePieCharts];
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

-(void)updatePieCharts
{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SpnCategoryMO"];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"NOT(title MATCHES[cd] %@)", @"Income"];
    fetchRequest.predicate = predicate;
    NSError* error;
    
    // This Month - Expenses
    self.pieChartTableThisMonthExpenses = [[spnTableViewController_PieChart alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableThisMonthExpenses.title = @"This Month's Expenses";
    self.pieChartTableThisMonthExpenses.startDate = self.firstDayOfThisMonth;
    self.pieChartTableThisMonthExpenses.endDate = self.firstDayOfNextMonth;
    self.pieChartTableThisMonthExpenses.excludeCategories = [NSArray arrayWithObjects: [NSString stringWithFormat:@"Income"], nil];
    self.pieChartTableThisMonthExpenses.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableThisMonthExpenses reloadData];
    
    // This Month - Income
    self.pieChartTableThisMonthIncome = [[spnTableViewController_PieChart alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableThisMonthIncome.title = @"This Month's Income";
    self.pieChartTableThisMonthIncome.startDate = self.firstDayOfThisMonth;
    self.pieChartTableThisMonthIncome.endDate = self.firstDayOfNextMonth;
    self.pieChartTableThisMonthIncome.excludeCategories = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] valueForKey:@"title"];
    self.pieChartTableThisMonthIncome.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableThisMonthIncome reloadData];
    
    // All Time - Expenses
    self.pieChartTableAllTimeExpenses = [[spnTableViewController_PieChart alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableAllTimeExpenses.title = @"All Time Expenses";
    self.pieChartTableAllTimeExpenses.startDate = nil;
    self.pieChartTableAllTimeExpenses.endDate = nil;
    self.pieChartTableAllTimeExpenses.excludeCategories = [NSArray arrayWithObjects: [NSString stringWithFormat:@"Income"], nil];
    self.pieChartTableAllTimeExpenses.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableAllTimeExpenses reloadData];
    
    // All Time - Income
    self.pieChartTableAllTimeIncome = [[spnTableViewController_PieChart alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableAllTimeIncome.title = @"All Time Income";
    self.pieChartTableAllTimeIncome.startDate = nil;
    self.pieChartTableAllTimeIncome.endDate = nil;
    self.pieChartTableAllTimeIncome.excludeCategories = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] valueForKey:@"title"];
    self.pieChartTableAllTimeIncome.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableAllTimeIncome reloadData];
}

// <UITableViewDataSource> methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* reuseIdentifier = [NSArray arrayWithObjects:@"summaryCell", @"thisMonthExpenseCell", @"thisMonthIncomeCell", @"allTimeMonthExpenseCell", @"allTimeIncomeCell", nil];
    
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
                [textLabel setText:@"Summary Stuff goes here - TBD"];
                [cell addSubview:textLabel];
            }
                break;
                
            case ROW_THIS_MONTH_EXPENSE:
            {
                // Create text label
                UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 44.0)];
                [textLabel setText:@"This Month's Expenses:"];
                
                // Gather chart preview
                UIImage* previewImage = [self.pieChartTableThisMonthExpenses pieChartImageWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 100.0)];
                UIImageView* imageView = [[UIImageView alloc] initWithImage:previewImage];
                
                UIView* imageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44.0, self.tableView.bounds.size.width, imageView.frame.size.height)];
                [imageContainerView addSubview:imageView];
                
                [cell addSubview:textLabel];
                [cell addSubview:imageContainerView];
                
            }
                break;
                
            case ROW_THIS_MONTH_INCOME:
            {
                // Create text label
                UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 44.0)];
                [textLabel setText:@"This Month's Income:"];
                
                // Gather chart preview
                UIImage* previewImage = [self.pieChartTableThisMonthIncome pieChartImageWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 100.0)];
                UIImageView* imageView = [[UIImageView alloc] initWithImage:previewImage];
                
                UIView* imageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44.0, self.tableView.bounds.size.width, imageView.frame.size.height)];
                [imageContainerView addSubview:imageView];
                
                [cell addSubview:textLabel];
                [cell addSubview:imageContainerView];
            }
                break;
                
            case ROW_ALL_TIME_EXPENSE:
            {
                // Create text label
                UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 44.0)];
                [textLabel setText:@"All Time Expenses:"];
                
                // Gather chart preview
                UIImage* previewImage = [self.pieChartTableAllTimeExpenses pieChartImageWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 100.0)];
                UIImageView* imageView = [[UIImageView alloc] initWithImage:previewImage];
                
                UIView* imageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44.0, self.tableView.bounds.size.width, imageView.frame.size.height)];
                [imageContainerView addSubview:imageView];
                
                [cell addSubview:textLabel];
                [cell addSubview:imageContainerView];
                
            }
                break;
                
            case ROW_ALL_TIME_INCOME:
            {
                // Create text label
                UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 44.0)];
                [textLabel setText:@"All Time Income:"];
                
                // Gather chart preview
                UIImage* previewImage = [self.pieChartTableAllTimeIncome pieChartImageWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 100.0)];
                UIImageView* imageView = [[UIImageView alloc] initWithImage:previewImage];
                
                UIView* imageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44.0, self.tableView.bounds.size.width, imageView.frame.size.height)];
                [imageContainerView addSubview:imageView];
                
                [cell addSubview:textLabel];
                [cell addSubview:imageContainerView];
            }
                break;


                
            default:
                break;
        }
    }
    
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
                          [NSNumber numberWithFloat:144],
                          [NSNumber numberWithFloat:144],
                          [NSNumber numberWithFloat:144],
                          [NSNumber numberWithFloat:144],
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
            
        case ROW_THIS_MONTH_INCOME:
            [[self navigationController] pushViewController:self.pieChartTableThisMonthIncome animated:YES];
            break;
            
        case ROW_ALL_TIME_EXPENSE:
            [[self navigationController] pushViewController:self.pieChartTableAllTimeExpenses animated:YES];
            break;
            
        case ROW_ALL_TIME_INCOME:
            [[self navigationController] pushViewController:self.pieChartTableAllTimeIncome animated:YES];
            break;
            
        default:
            break;
    }
}

@end
