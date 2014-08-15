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
//#import "CorePlot-CocoaTouch.h"
#import "spnSimplePieChart.h"

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
    //[self.view setBackgroundColor:[UIColor blueColor]];
    
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
    
    NSError* error;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    // The first of this month
    NSDateComponents* dateComponents = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    [dateComponents setDay:1];
    NSDate* firstDayOfThisMonth = [calendar dateFromComponents:dateComponents];

    NSDateComponents* tempComponents = [[NSDateComponents alloc] init];
    [tempComponents setMonth:1];
    
    NSDate* thisDayNextMonth = [calendar dateByAddingComponents:tempComponents toDate:[NSDate date] options:0];
    
    tempComponents = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:thisDayNextMonth];
    [tempComponents setDay:1];
    
    // First day of the next month
    NSDate* firstDayOfNextMonth = [calendar dateFromComponents:tempComponents];
    
    tempComponents = [tempComponents init]; // reinitalize component
    [tempComponents setMonth:-1];
    
    // First day of last month
    NSDate* firstDayOfLastMonth = [calendar dateFromComponents:tempComponents];
    


    // Fetch all EXPENSE transactions for this month
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnTransactionMO"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT(subCategory.category.title MATCHES %@) AND (date >= %@) AND (date < %@)", @"Income", firstDayOfThisMonth, firstDayOfNextMonth];
    [fetchRequest setPredicate:predicate];

    NSArray *expenseResultsThisMonth = [self.managedObjectContext                                                executeFetchRequest:fetchRequest error:&error];
    
    // Fetch all INCOME transactions for this month
    predicate = [NSPredicate predicateWithFormat:@"(subCategory.category.title MATCHES %@) AND (date >= %@) AND (date < %@)", @"Income", firstDayOfThisMonth, firstDayOfNextMonth];
    [fetchRequest setPredicate:predicate];
    
    NSArray *incomeResultsThisMonth = [self.managedObjectContext                                                executeFetchRequest:fetchRequest error:&error];
    
    
    
    
    
    
    
    
    // Fetch all EXPENSE transactions for last month
    predicate = [NSPredicate predicateWithFormat:@"NOT(subCategory.category.title MATCHES %@) AND (date >= %@) AND (date < %@)", @"Income", firstDayOfLastMonth, firstDayOfThisMonth];
    [fetchRequest setPredicate:predicate];
    
    NSArray *expenseResultsLastMonth = [self.managedObjectContext                                                executeFetchRequest:fetchRequest error:&error];
    
    // Fetch all INCOME transactions for last month
    predicate = [NSPredicate predicateWithFormat:@"(subCategory.category.title MATCHES %@) AND (date >= %@) AND (date < %@)", @"Income", firstDayOfLastMonth, firstDayOfThisMonth];
    [fetchRequest setPredicate:predicate];
    
    NSArray *incomeResultsLastMonth = [self.managedObjectContext                                                executeFetchRequest:fetchRequest error:&error];
    
    
    
    
//    NSString *const 	kCPTDarkGradientTheme
// 	A graph theme with dark gray gradient backgrounds and light gray lines. More...
//    
//    NSString *const 	kCPTPlainBlackTheme
// 	A graph theme with black backgrounds and white lines. More...
//    
//    NSString *const 	kCPTPlainWhiteTheme
// 	A graph theme with white backgrounds and black lines. More...
//    
//    NSString *const 	kCPTSlateTheme
// 	A graph theme with colors that match the default iPhone navigation bar, toolbar buttons, and table views. More...
//    
//    NSString *const 	kCPTStocksTheme
    
    spnSimplePieChart* pieChart = [[spnSimplePieChart alloc] init];
    [pieChart killGraph];
    [pieChart renderInView:self.view withTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme] animated:YES];
    
//    // Create pieChart from theme
//    CPTXYGraph *pieChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
//    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
//    [pieChart applyTheme:theme];
//    
//    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
//    hostingView.hostedGraph = pieChart;
//    
//    pieChart.paddingLeft   = 20.0;
//    pieChart.paddingTop    = 20.0;
//    pieChart.paddingRight  = 20.0;
//    pieChart.paddingBottom = 20.0;
//    
//    pieChart.axisSet = nil;
//    
//    CPTMutableTextStyle *whiteText = [CPTMutableTextStyle textStyle];
//    whiteText.color = [CPTColor whiteColor];
//    
//    pieChart.titleTextStyle = whiteText;
//    pieChart.title          = @"Graph Title";
//    
//    // Add pie chart
//    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
//    piePlot.dataSource      = self;
//    piePlot.pieRadius       = 131.0;
//    piePlot.identifier      = @"Pie Chart 1";
//    piePlot.startAngle      = M_PI_4;
//    piePlot.sliceDirection  = CPTPieDirectionCounterClockwise;
//    piePlot.centerAnchor    = CGPointMake(0.5, 0.38);
//    piePlot.borderLineStyle = [CPTLineStyle lineStyle];
//    piePlot.delegate        = self;
//    [pieChart addPlot:piePlot];
//    
//    [self.view addSubview:hostingView];

    

                        
    
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

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 5;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if ( index >= 5 ) {
        return nil;
    }
    
    if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
        return [NSNumber numberWithUnsignedInteger:1+index];
    }
    else {
        return [NSNumber numberWithUnsignedInteger:index];
    }
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    CPTTextLayer *label            = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
    CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];
    
    textStyle.color = [CPTColor lightGrayColor];
    label.textStyle = textStyle;
    return label;
}

-(CGFloat)radialOffsetForPieChart:(CPTPieChart *)piePlot recordIndex:(NSUInteger)index
{
    CGFloat offset = 0.0;
    
    if ( index == 0 ) {
        offset = piePlot.pieRadius / 8.0;
    }
    
    return offset;
}

/*-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index;
 * {
 *  return nil;
 * }*/

#pragma mark -
#pragma mark Delegate Methods

-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
//    pieChart.title = [NSString stringWithFormat:@"Selected index: %lu", (unsigned long)index];
}

//-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
//{
//    CPTPieChart *piePlot             = (CPTPieChart *)[pieChart plotWithIdentifier:@"Pie Chart 1"];
//    CABasicAnimation *basicAnimation = (CABasicAnimation *)theAnimation;
//    
//    [piePlot removeAnimationForKey:basicAnimation.keyPath];
//    [piePlot setValue:basicAnimation.toValue forKey:basicAnimation.keyPath];
//    [piePlot repositionAllLabelAnnotations];
//}


@end
