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
    
    NSError* error;
    
    // Start date = The first of this month
    // End date = Now
    NSDate* endDate = [NSDate date];
    NSDateComponents* dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:endDate];
    [dateComponents setDay:1];
    NSDate* startDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];

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


@end
