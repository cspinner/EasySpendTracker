//
//  spnViewController_Home.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/21/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnViewController_Home.h"
#import "UIViewController+addTransactionHandles.h"
#import "SpnTransaction.h"
#import "SpnCategory.h"
#import "SpnSubCategory.h"
#import "spnTableViewController_PieChart.h"

@interface spnViewController_Home ()

@property NSDate* firstDayOfThisMonth;
@property NSDate* firstDayOfNextMonth;

@property UITextView* textView;

@property NSArray *expenseResultsThisMonth;
@property NSArray *incomeResultsThisMonth;

@property spnTableViewController_PieChart* pieChartTableThisMonthExpenses;
@property spnTableViewController_PieChart* pieChartTableThisMonthIncome;
@property spnTableViewController_PieChart* pieChartTableAllTimeExpenses;
@property spnTableViewController_PieChart* pieChartTableAllTimeIncome;
@property UIButton* button;
@end

@implementation spnViewController_Home

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
}

- (void)loadView
{
    // Create the view and store it to the view property of the controller
    // frame = width: 320.000000, height: 548.000000
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Create subviews next - i.e. labels, buttons, text fields...
    //self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 300, 548)];
    
    // Create button object, set text, display frame, and action
    //[self.textView setFont:[UIFont systemFontOfSize:10.0]];
    //[self.textView setDelegate:self];
    //[self.view addSubview:self.textView];
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
    [self.button setTitle:@"Press Me" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(showPies) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.button];

}

-(void)showPies
{
    [[self navigationController] pushViewController:self.pieChartTableThisMonthExpenses animated:YES];
//    [[self navigationController] pushViewController:self.pieChartTableThisMonthIncome animated:YES];
//    [[self navigationController] pushViewController:self.pieChartTableAllTimeExpenses animated:YES];
//    [[self navigationController] pushViewController:self.pieChartTableAllTimeIncome animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
    
    // This Month - Income
    self.pieChartTableThisMonthIncome = [[spnTableViewController_PieChart alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableThisMonthIncome.title = @"This Month's Income";
    self.pieChartTableThisMonthIncome.startDate = self.firstDayOfThisMonth;
    self.pieChartTableThisMonthIncome.endDate = self.firstDayOfNextMonth;
    self.pieChartTableThisMonthIncome.excludeCategories = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] valueForKey:@"title"];
    self.pieChartTableThisMonthIncome.managedObjectContext = self.managedObjectContext;
    
    // All Time - Expenses
    self.pieChartTableAllTimeExpenses = [[spnTableViewController_PieChart alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableAllTimeExpenses.title = @"All Time Expenses";
    self.pieChartTableAllTimeExpenses.startDate = nil;
    self.pieChartTableAllTimeExpenses.endDate = nil;
    self.pieChartTableAllTimeExpenses.excludeCategories = [NSArray arrayWithObjects: [NSString stringWithFormat:@"Income"], nil];
    self.pieChartTableAllTimeExpenses.managedObjectContext = self.managedObjectContext;

    // All Time - Income
    self.pieChartTableAllTimeIncome = [[spnTableViewController_PieChart alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableAllTimeIncome.title = @"All Time Income";
    self.pieChartTableAllTimeIncome.startDate = nil;
    self.pieChartTableAllTimeIncome.endDate = nil;
    self.pieChartTableAllTimeIncome.excludeCategories = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] valueForKey:@"title"];
    self.pieChartTableAllTimeIncome.managedObjectContext = self.managedObjectContext;
    
    

    

                        
    
//    NSMutableString* text = [[NSMutableString alloc] init];
//    
//    // First line
//    [text appendFormat:@"Expenses since %@:\n", firstDayOfThisMonth];
//    
//    // Add summary text for each transaction
//    for(SpnTransaction* transaction in expenseResultsThisMonth)
//    {
//        [text appendFormat:@" %@ - %@ - $%.2f - %@, %@\n", transaction.sectionName, transaction.merchant, transaction.value.floatValue, transaction.subCategory.category.title, transaction.subCategory.title];
//    }
//    
//    // Income
//    [text appendFormat:@"\n"];
//    [text appendFormat:@"Income since %@:\n", firstDayOfThisMonth];
//    
//    // Add summary text for each transaction
//    for(SpnTransaction* transaction in incomeResultsThisMonth)
//    {
//        [text appendFormat:@" %@ - %@ - $%.2f - %@, %@\n", transaction.sectionName, transaction.merchant, transaction.value.floatValue, transaction.subCategory.category.title, transaction.subCategory.title];
//    }
//    
//    // Totals
//    NSNumber* expenseTotal, *incomeTotal, *budgetDelta;
//    
//    // This month
//    expenseTotal = [expenseResultsThisMonth valueForKeyPath: @"@sum.value"];
//    incomeTotal = [incomeResultsThisMonth valueForKeyPath: @"@sum.value"];
//    budgetDelta = [NSNumber numberWithFloat:incomeTotal.floatValue - expenseTotal.floatValue];
//    [text appendFormat:@"\n"];
//    [text appendFormat:@"Total expense: $%.2f\n", expenseTotal.floatValue];
//    [text appendFormat:@"Total income: $%.2f\n", incomeTotal.floatValue];
//    [text appendFormat:@"Delta: $%.2f\n", budgetDelta.floatValue];
//    
//    // Last month
//    expenseTotal = [expenseResultsLastMonth valueForKeyPath: @"@sum.value"];
//    incomeTotal = [incomeResultsLastMonth valueForKeyPath: @"@sum.value"];
//    budgetDelta = [NSNumber numberWithFloat:incomeTotal.floatValue - expenseTotal.floatValue];
//    [text appendFormat:@"\n"];
//    [text appendFormat:@"Total expense from last month: $%.2f\n", expenseTotal.floatValue];
//    [text appendFormat:@"Total income from last month: $%.2f\n", incomeTotal.floatValue];
//    [text appendFormat:@"Delta: $%.2f\n", budgetDelta.floatValue];
//    
//    [self.textView setText:text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}




@end
