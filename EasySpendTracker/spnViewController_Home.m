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
#import "spnPieChart.h"

@interface spnViewController_Home ()

@property NSDate* firstDayOfThisMonth;
@property NSDate* firstDayOfNextMonth;

@property UITextView* textView;
@property spnPieChart* expensePieChartThisMonth;
@property spnPieChart* expensePieChartAllTime;
@property spnPieChart* incomePieChart;
@property NSString* focusCategory;

@property NSArray *expenseResultsThisMonth;
@property NSArray *incomeResultsThisMonth;

@end

int pieChartCategoryContext;
int pieChartSubCategoryContext;

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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    
    
    self.expensePieChartThisMonth = [[spnPieChart alloc] initWithContext:&pieChartCategoryContext];
    self.expensePieChartThisMonth.delegate = self;
    
//    UIImageView* imageView = [[UIImageView alloc] initWithImage:[self.expensePieChart image]];
//    [self.view addSubview:imageView];

    //[self.expensePieChartThisMonth renderInView:self.view withTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme] animated:YES];
    
    
    self.expensePieChartAllTime = [[spnPieChart alloc] initWithContext:&pieChartCategoryContext];
    self.expensePieChartAllTime.delegate = self;
    [self.expensePieChartAllTime renderInView:self.view withTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme] animated:YES];

    

    

                        
    
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

-(NSArray*)getExpenseTransactionsFromStartDate:(NSDate*)startDate toEndDate:(NSDate*)endDate
{
    // Fetch all EXPENSE transactions in date range
    NSError* error;
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnTransactionMO"];
    NSPredicate *predicate;
    
    // No start date
    if (startDate == nil)
    {
        // No start and no end date specified
        if (endDate == nil)
        {
            predicate = [NSPredicate predicateWithFormat:@"NOT(subCategory.category.title MATCHES %@)", @"Income"];
        }
        // End date with no start date
        else
        {
            predicate = [NSPredicate predicateWithFormat:@"NOT(subCategory.category.title MATCHES %@) AND (date < %@)", @"Income", endDate];
        }
    }
    // Start date with no end date
    else if (endDate == nil)
    {
        predicate = [NSPredicate predicateWithFormat:@"NOT(subCategory.category.title MATCHES %@) AND (date >= %@)", @"Income", startDate];
    }
    // Start and End date specified
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"NOT(subCategory.category.title MATCHES %@) AND (date >= %@) AND (date < %@)", @"Income", startDate, endDate];
    }
    
    [fetchRequest setPredicate:predicate];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

-(NSArray*)getIncomeTransactionsFromStartDate:(NSDate*)startDate toEndDate:(NSDate*)endDate
{
    // Fetch all INCOME transactions in date range
    NSError* error;
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnTransactionMO"];
    NSPredicate *predicate;
    
    // No start date
    if (startDate == nil)
    {
        // No start and no end date specified
        if (endDate == nil)
        {
            predicate = [NSPredicate predicateWithFormat:@"(subCategory.category.title MATCHES %@)", @"Income"];
        }
        // End date with no start date
        else
        {
            predicate = [NSPredicate predicateWithFormat:@"(subCategory.category.title MATCHES %@) AND (date < %@)", @"Income", endDate];
        }
    }
    // Start date with no end date
    else if (endDate == nil)
    {
        predicate = [NSPredicate predicateWithFormat:@"(subCategory.category.title MATCHES %@) AND (date >= %@)", @"Income", startDate];
    }
    // Start and End date specified
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"(subCategory.category.title MATCHES %@) AND (date >= %@) AND (date < %@)", @"Income", startDate, endDate];
    }
    
    [fetchRequest setPredicate:predicate];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

-(NSArray*)getCategoryTotalsForTransactions:(NSArray*)transactions
{
    NSMutableArray* totals = [[NSMutableArray alloc] init];
    
    // Get array of unique category titles
    NSArray* categoryTitles = [transactions valueForKeyPath:@"@distinctUnionOfObjects.subCategory.category.title"];
    
    for(NSString* categoryTitle in categoryTitles)
    {
        // Get array of transactions for each category, by category title
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"subCategory.category.title MATCHES[cd] %@", categoryTitle];
        NSArray* filteredTransactions = [transactions filteredArrayUsingPredicate:predicate];
        
        // Store the sum of values of those transactions to the array
        [totals addObject:[filteredTransactions valueForKeyPath:@"@sum.value"]];
    }
    
    return totals;
}

-(NSArray*)getCategoryTitlesForTransactions:(NSArray*)transactions
{
    return [transactions valueForKeyPath:@"@distinctUnionOfObjects.subCategory.category.title"];
}

-(NSArray*)getSubCategoryTotalsForTransactions:(NSArray*)transactions
{
    NSMutableArray* totals = [[NSMutableArray alloc] init];
    
    // Get array of unique sub-category titles
    NSArray* subCategoryTitles = [transactions valueForKeyPath:@"@distinctUnionOfObjects.subCategory.title"];
    
    for(NSString* subCategoryTitle in subCategoryTitles)
    {
        // Get array of transactions for each category, by category title
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"subCategory.title MATCHES[cd] %@", subCategoryTitle];
        NSArray* filteredTransactions = [transactions filteredArrayUsingPredicate:predicate];
        
        // Store the sum of values of those transactions to the array
        [totals addObject:[filteredTransactions valueForKeyPath:@"@sum.value"]];
    }
    
    return totals;
}

-(NSArray*)getSubCategoryTitlesForTransactions:(NSArray*)transactions
{
    return [transactions valueForKeyPath:@"@distinctUnionOfObjects.subCategory.title"];
}

//<spnPieChartDelegate> methods>
-(NSArray*)dataArrayForPieChart:(spnPieChart*)pieChart
{
    NSError* error;
//    NSCalendar* calendar = [NSCalendar currentCalendar];
//    
//    // The first of this month
//    NSDateComponents* dateComponents = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
//    [dateComponents setDay:1];
//    NSDate* firstDayOfThisMonth = [calendar dateFromComponents:dateComponents];
//    
//    NSDateComponents* tempComponents = [[NSDateComponents alloc] init];
//    [tempComponents setMonth:1];
//    
//    NSDate* thisDayNextMonth = [calendar dateByAddingComponents:tempComponents toDate:[NSDate date] options:0];
//    
//    tempComponents = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:thisDayNextMonth];
//    [tempComponents setDay:1];
//    
//    // First day of the next month
//    NSDate* firstDayOfNextMonth = [calendar dateFromComponents:tempComponents];
//    
//    tempComponents = [tempComponents init]; // reinitalize component
//    [tempComponents setMonth:-1];
//    
//    // First day of last month
//    NSDate* firstDayOfLastMonth = [calendar dateFromComponents:tempComponents];
    
    
    
//    // Fetch all EXPENSE transactions for this month
//    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnTransactionMO"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT(subCategory.category.title MATCHES %@) AND (date >= %@) AND (date < %@)", @"Income", self.firstDayOfThisMonth, self.firstDayOfNextMonth];
//    [fetchRequest setPredicate:predicate];
//    
//    self.expenseResultsThisMonth = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    
//    // Fetch all INCOME transactions for this month
//    predicate = [NSPredicate predicateWithFormat:@"(subCategory.category.title MATCHES %@) AND (date >= %@) AND (date < %@)", @"Income", self.firstDayOfThisMonth, self.firstDayOfNextMonth];
//    [fetchRequest setPredicate:predicate];
//    
//    self.incomeResultsThisMonth = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    

    
    
    
//    // Fetch all EXPENSE transactions for last month
//    predicate = [NSPredicate predicateWithFormat:@"NOT(subCategory.category.title MATCHES %@) AND (date >= %@) AND (date < %@)", @"Income", self.firstDayOfLastMonth, self.firstDayOfThisMonth];
//    [fetchRequest setPredicate:predicate];
//    
//    NSArray *expenseResultsLastMonth = [self.managedObjectContext                                                executeFetchRequest:fetchRequest error:&error];
//    
//    // Fetch all INCOME transactions for last month
//    predicate = [NSPredicate predicateWithFormat:@"(subCategory.category.title MATCHES %@) AND (date >= %@) AND (date < %@)", @"Income", self.firstDayOfLastMonth, self.firstDayOfThisMonth];
//    [fetchRequest setPredicate:predicate];
//    
//    NSArray *incomeResultsLastMonth = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    
    
    
    
    // EXPENSE
    if (pieChart == self.expensePieChartThisMonth)
    {
        NSArray* totals = [[NSArray alloc] init];
        
        if (pieChart.context == &pieChartCategoryContext)
        {
            // Get category totals for transactions this month
            totals = [self getCategoryTotalsForTransactions:[self getExpenseTransactionsFromStartDate:self.firstDayOfThisMonth toEndDate:self.firstDayOfNextMonth]];
        }
        else if (pieChart.context == &pieChartSubCategoryContext)
        {
            // Get sub-category totals for transactions this month that belong to the focus category
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"subCategory.category.title MATCHES[cd] %@", self.focusCategory];
            NSArray* thisMonthExpenseTransactions = [self getExpenseTransactionsFromStartDate:self.firstDayOfThisMonth toEndDate:self.firstDayOfNextMonth];
            NSArray* thisMonthExpenseTransactionsInFocusCategory = [thisMonthExpenseTransactions filteredArrayUsingPredicate:predicate];
            
            totals = [self getSubCategoryTotalsForTransactions:thisMonthExpenseTransactionsInFocusCategory];
        }
        
        return totals;
    }
    else if (pieChart == self.expensePieChartAllTime)
    {
        NSArray* totals = [[NSArray alloc] init];
        
        if (pieChart.context == &pieChartCategoryContext)
        {
            // Get category totals for transactions all time
            totals = [self getCategoryTotalsForTransactions:[self getExpenseTransactionsFromStartDate:nil toEndDate:nil]];
        }
        else if (pieChart.context == &pieChartSubCategoryContext)
        {
            // Get sub-category totals for transactions of all time that belong to the focus category
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"subCategory.category.title MATCHES[cd] %@", self.focusCategory];
            NSArray* allTimeExpenseTransactions = [self getExpenseTransactionsFromStartDate:nil toEndDate:nil];
            NSArray* allTimeExpenseTransactionsInFocusCategory = [allTimeExpenseTransactions filteredArrayUsingPredicate:predicate];
            
            totals = [self getSubCategoryTotalsForTransactions:allTimeExpenseTransactionsInFocusCategory];
        }
        
        return totals;
    }
    // INCOME
    else if (pieChart == self.incomePieChart)
    {
        NSMutableArray* totals = [[NSMutableArray alloc] init];
        
//        // Get array of unique category titles for this month's expenses
//        NSArray* categoryTitles = [self.incomeResultsThisMonth valueForKeyPath:@"@distinctUnionOfObjects.subCategory.category.title"];
//        
//        for(NSString* categoryTitle in categoryTitles)
//        {
//            // Get array of transactions for each category, by category title
//            predicate = [NSPredicate predicateWithFormat:@"subCategory.category.title MATCHES[cd] %@", categoryTitle];
//            NSArray* filteredTransactions = [self.incomeResultsThisMonth filteredArrayUsingPredicate:predicate];
//            
//            // Store the sum of values of those transactions to the array
//            [totals addObject:[filteredTransactions valueForKeyPath:@"@sum.value"]];
//        }
        
        return totals;
    }
    else
    {
        return [NSArray arrayWithObject:[NSNumber numberWithFloat:0.0]];
    }
}

-(NSArray*)titleArrayForPieChart:(spnPieChart*)pieChart
{
    // EXPENSE
    if (pieChart == self.expensePieChartThisMonth)
    {
        if (pieChart.context == &pieChartCategoryContext)
        {
            // Get category totals for transactions this month
            return [self getCategoryTitlesForTransactions:[self getExpenseTransactionsFromStartDate:self.firstDayOfThisMonth toEndDate:self.firstDayOfNextMonth]];
        }
        else if (pieChart.context == &pieChartSubCategoryContext)
        {
            // Get sub-category titles for transactions this month that belong to the focus category
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"subCategory.category.title MATCHES[cd] %@", self.focusCategory];
            NSArray* thisMonthExpenseTransactions = [self getExpenseTransactionsFromStartDate:self.firstDayOfThisMonth toEndDate:self.firstDayOfNextMonth];
            NSArray* thisMonthExpenseTransactionsInFocusCategory = [thisMonthExpenseTransactions filteredArrayUsingPredicate:predicate];
            
            return [self getSubCategoryTitlesForTransactions:thisMonthExpenseTransactionsInFocusCategory];
        }
    }
    // EXPENSE
    else if (pieChart == self.expensePieChartAllTime)
    {
        if (pieChart.context == &pieChartCategoryContext)
        {
            // Get category totals for transactions this month
            return [self getCategoryTitlesForTransactions:[self getExpenseTransactionsFromStartDate:nil toEndDate:nil]];
        }
        else if (pieChart.context == &pieChartSubCategoryContext)
        {
            // Get sub-category titles for transactions this month that belong to the focus category
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"subCategory.category.title MATCHES[cd] %@", self.focusCategory];
            NSArray* allTimeExpenseTransactions = [self getExpenseTransactionsFromStartDate:self.firstDayOfThisMonth toEndDate:self.firstDayOfNextMonth];
            NSArray* allTimeExpenseTransactionsInFocusCategory = [allTimeExpenseTransactions filteredArrayUsingPredicate:predicate];
            
            return [self getSubCategoryTitlesForTransactions:allTimeExpenseTransactionsInFocusCategory];
        }
    }
    // INCOME
    else if (pieChart == self.incomePieChart)
    {
        if (pieChart.context == &pieChartCategoryContext)
        {
            return [self.incomeResultsThisMonth valueForKeyPath:@"@distinctUnionOfObjects.subCategory.category.title"];
        }
        else if (pieChart.context == &pieChartSubCategoryContext)
        {
            return [self.incomeResultsThisMonth valueForKeyPath:@"@distinctUnionOfObjects.subCategory.title"];
        }
    }
    
    // default
    return [NSArray arrayWithObject:@""];
}

-(void)pieChart:(spnPieChart*)pieChart entryWasSelectedAtIndex:(NSUInteger)idx
{
    if (pieChart == self.expensePieChartThisMonth)
    {
        if (pieChart.context == &pieChartCategoryContext)
        {
            self.focusCategory = [[self getCategoryTitlesForTransactions:[self getExpenseTransactionsFromStartDate:self.firstDayOfThisMonth toEndDate:self.firstDayOfNextMonth]] objectAtIndex:idx];
        }
    }
    else if (pieChart == self.expensePieChartAllTime)
    {
        if (pieChart.context == &pieChartCategoryContext)
        {
            self.focusCategory = [[self getCategoryTitlesForTransactions:[self getExpenseTransactionsFromStartDate:nil toEndDate:nil]] objectAtIndex:idx];
        }
    }
    else if (pieChart == self.incomePieChart)
    {
        self.focusCategory = [[self.incomeResultsThisMonth valueForKeyPath:@"@distinctUnionOfObjects.subCategory.category.title"] objectAtIndex:idx];
    }
    else
    {
        
    }
    
    // change context to sub-category
    pieChart.context = &pieChartSubCategoryContext;
}


@end
