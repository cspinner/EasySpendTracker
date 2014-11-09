//
//  spnViewController_Calendar.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 11/7/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnViewController_Calendar.h"
#import "spnTransactionFetchOp.h"
#import "UIViewController+addTransactionHandles.h"
#import "NSDateAdditions.h"
#import "NSDate+Convenience.h"
#import "SpnTransaction.h"
#import "spnTransactionCellView.h"

@interface spnViewController_Calendar ()

// the queue to run operations
@property (nonatomic, strong) NSOperationQueue* queue;
@property spnTransactionFetchOp* fetchOperation;
@property NSMutableArray* fetchedTransactionObjectIDs;
@property NSMutableArray* fetchedTransactions;
@property NSMutableArray* filteredTransactions;

@end

@implementation spnViewController_Calendar

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Today", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(selectTodaysDate)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(spnAddButtonClicked:)];
    
    // Create the operation queue that will run any operations
    self.queue = [[NSOperationQueue alloc] init];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    [self selectTodaysDate];
//}

// Action handler for the navigation bar's left bar button item.
- (void)selectTodaysDate
{
    [self setSelectedDate:[NSDate dateStartOfDay:[NSDate date]]];
}

//<KalDataSource> methods
- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
//    *        This message will be sent whenever the calendar
//    *        switches to a different month. This code should respond by
//    *        loading application data for the specified range of dates and sending the
//    *        loadedDataSource: callback message as soon as the appplication data
//    *        is ready and available in memory. If the lookup of your application
//    *        data is expensive, you should perform the lookup using an asynchronous
//    *        API (like NSURLConnection for web service resources) or in a background
//    *        thread.
//    *
//    *        If the application data for the new month is already in-memory,
//    *        you must still issue the callback.
    
    // Need to create a week reference of self to avoid retain loop when accessing self within the block.
    __unsafe_unretained typeof(self) weakSelf = self;
    NSLog(@"startfetch");
    self.fetchOperation = [[spnTransactionFetchOp alloc] init];
    self.fetchOperation.startDate = fromDate;
    self.fetchOperation.endDate = toDate;
    self.fetchOperation.persistentStoreCoordinator = [self.managedObjectContext persistentStoreCoordinator];
    self.fetchOperation.excludeCategories = nil; // excludes none
    self.fetchOperation.includeCategories = nil; // includes all
    self.fetchOperation.includeSubCategories = nil; // includes all
    self.fetchOperation.dataReturnBlock = ^(NSMutableArray* objectIDs, NSError* error) {
        
        weakSelf.fetchedTransactionObjectIDs = [NSMutableArray arrayWithArray:objectIDs];
    };
    self.fetchOperation.completionBlock = ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Convert object IDs into objects
            weakSelf.fetchedTransactions = [[NSMutableArray alloc] init];
            for (NSManagedObjectID* transactionID in weakSelf.fetchedTransactionObjectIDs)
            {
                [weakSelf.fetchedTransactions addObject:[weakSelf.managedObjectContext objectWithID:transactionID]];
            }
            
            NSLog(@"loadedDataSource");
            [delegate loadedDataSource:weakSelf];
        });
    };
    
    // start the operations
    [self.queue addOperation:self.fetchOperation];
    
    
}

- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
//    *        This message will be sent to your dataSource immediately
//    *        after you issue the loadedDataSource: callback message
//    *        from the body of your presentingDatesFrom:to:delegate method.
//    *        You should respond to this message by returning an array of NSDates
//    *        for each day in the specified range which has associated application
//    *        data.
//    *
//    *        If this message is received but the application data is not yet
//    *        ready, your code should immediately return an empty NSArray.
    NSMutableArray* markedDatesArray = [[NSMutableArray alloc] init];
   
    for (SpnTransaction* transaction in self.fetchedTransactions)
    {
        [markedDatesArray addObject:[NSDate dateStartOfDay:transaction.date]];
    }
    NSLog(@"markedDates");
    return markedDatesArray;
}

- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
//    *        This message will be sent every time
//    *        that the user taps a day on the calendar. This should respond
//    *        to this message by updating the list from which you vend
//    *        UITableViewCells.
//    *
//    *        If this message is received but the application data is not yet
//    *        ready, this code should do nothing.
    NSMutableArray* predicateArray = [[NSMutableArray alloc] init];
    
    // Create a predicate that accepts transactions from a specified start date
    if (fromDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date >= %@)", fromDate];
        
        [predicateArray addObject:predicate];
    }
    
    // Create a predicate that accepts transactions that come before a specified end date
    if (toDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date <= %@)", toDate];
        
        [predicateArray addObject:predicate];
    }
    
    // Combine the predicates if any were created
    if (predicateArray.count > 0)
    {
        self.filteredTransactions  = [[self.fetchedTransactions filteredArrayUsingPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicateArray]] mutableCopy];
    }
    NSLog(@"loadItemsFromDate: %@", fromDate);
}

- (void)removeAllItems
{
//    *        This message will be sent before loadItemsFromDate:toDate
//    *        as well as any time that Kal wants to clear the table view
//    *        beneath the calendar (for example, when switching between months).
//    *        You should respond to this message by removing all objects
//    *        from the list from which you vend UITableViewCells.
    [self.filteredTransactions removeAllObjects];
    NSLog(@"removeAllItems");
}

//<UITableViewDelegate> methods
//Handled entirely by parent

//<UITableViewDataSource> methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection: %lu", (unsigned long)self.filteredTransactions.count);
    return self.filteredTransactions.count;
}

- (void)configureCell:(spnTransactionCellView*)cell withTransaction:(SpnTransaction*)transaction
{
    // Write cell contents
    NSString* category = [transaction valueForKeyPath:@"subCategory.category.title"];
    
    [cell setValue:transaction.value.floatValue withMerchant:transaction.merchant isIncome:[category isEqualToString:@"Income"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"CalendarEventCell";

    // Acquire reuse cell object from the table view
    spnTransactionCellView* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
    {
        // Create cell if reuse cell doesn't exist.
        cell = [[spnTransactionCellView alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell withTransaction:self.filteredTransactions[indexPath.row]];
    
    NSLog(@"cellForRowAtIndexPath: %lu", indexPath.row);
    return cell;
}




@end
