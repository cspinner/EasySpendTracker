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
//#import "SpnMonth.h"
#import "SpnTransactionCategory.h"

@interface spnViewController_Home ()
@property UITextView* textView;

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
}

- (void)loadView
{
    // Create the view and store it to the view property of the controller
    // frame = width: 320.000000, height: 548.000000
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Create subviews next - i.e. labels, buttons, text fields...
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 300, 548)];
    
    // Create button object, set text, display frame, and action
    [self.textView setFont:[UIFont systemFontOfSize:10.0]];
    [self.view addSubview:self.textView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Adds any recurring transactions as necessary
    [self updateAllRecurrences];
    
    NSError* error;
    
    // Start date = The first of this month
    NSDateComponents* dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    [dateComponents setDay:1];
    NSDate* startDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    // End date = The last of the month
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* tempComponents = [[NSDateComponents alloc] init];
    [tempComponents setMonth:1];
    
    NSDate* thisDayNextMonth = [calendar dateByAddingComponents:tempComponents toDate:[NSDate date] options:0];
    
    tempComponents = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:thisDayNextMonth];
    [tempComponents setDay:1];
    
    // First day of the next month - this will be the end date
    NSDate* endDate = [calendar dateFromComponents:tempComponents];
    


    // Fetch all EXPENSE transactions since the first of the month
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnTransactionMO"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT(category.title MATCHES %@) AND (date >= %@) AND (date <= %@)", @"Income", startDate, endDate];
    [fetchRequest setPredicate:predicate];

    NSArray *expenseResults = [self.managedObjectContext                                                executeFetchRequest:fetchRequest error:&error];
    
    // Fetch all INCOME transactions since the first of the month
    predicate = [NSPredicate predicateWithFormat:@"(category.title MATCHES %@) AND (date >= %@) AND (date <= %@)", @"Income", startDate, endDate];
    [fetchRequest setPredicate:predicate];
    
    NSArray *incomeResults = [self.managedObjectContext                                                executeFetchRequest:fetchRequest error:&error];
    
    
    
    

                        
    
    NSMutableString* text = [[NSMutableString alloc] init];
    
    // First line
    [text appendFormat:@"Expenses since %@:\n", startDate];
    
    // Add summary text for each transaction
    for(SpnTransaction* transaction in expenseResults)
    {
        [text appendFormat:@"       %@ - %@ - $%.2f - %@\n", transaction.sectionName, transaction.merchant, transaction.value.floatValue, transaction.category.title];
    }
    
    // Income
    [text appendFormat:@"\n"];
    [text appendFormat:@"Income since %@:\n", startDate];
    
    // Add summary text for each transaction
    for(SpnTransaction* transaction in incomeResults)
    {
        [text appendFormat:@"       %@ - %@ - $%.2f - %@\n", transaction.sectionName, transaction.merchant, transaction.value.floatValue, transaction.category.title];
    }
    
    [text appendFormat:@"\n"];
    [text appendFormat:@"Total expense: $%@\n", [expenseResults valueForKeyPath: @"@sum.value.floatValue"]];
    [text appendFormat:@"Total income: $%@\n", [incomeResults valueForKeyPath: @"@sum.value.floatValue"]];
    
    [self.textView setText:text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateAllRecurrences
{
    NSError* error;
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnRecurrenceMO"];
    
    // Get all recurrences from the managed object context
    NSArray *recurrencesArray = [self.managedObjectContext                                                executeFetchRequest:fetchRequest error:&error];
    
    // Call the extend routine on them all. Transactions will be created through the end of the month, if they don't already exist
    [recurrencesArray makeObjectsPerformSelector:@selector(extendSeriesThroughEndOfMonth)];
}


@end
