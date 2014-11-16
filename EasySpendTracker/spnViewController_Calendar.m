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
#import "spnViewController_Expense.h"
#import "spnViewController_Income.h"

@interface spnViewController_Calendar ()

@property (nonatomic)  NSFetchedResultsController* fetchedResultsController;
@property NSDate* fromDate;
@property NSDate* toDate;

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

// Action handler for the navigation bar's left bar button item.
- (void)selectTodaysDate
{
    [self setSelectedDate:[NSDate dateStartOfDay:[NSDate date]]];
}

//<KalDataSource> methods
- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
    [self resetFetchedResultsController];
    self.fromDate = fromDate;
    self.toDate = toDate;
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error])
    {
        // Update to handle the error appropriately.
        NSLog(@"Calendar Transaction Fetch Error: %@, %@", error, [error userInfo]);
        exit(-1);
    }
    
//    NSLog(@"loadedDataSource. %lu transactions fetched", self.fetchedResultsController.fetchedObjects.count);
    [delegate loadedDataSource:self];
}

- (void)resetFetchedResultsController
{
    _fetchedResultsController = nil;
}

- (NSFetchedResultsController*)fetchedResultsController
{
    // Return the instance if it already exists
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    // Otherwise, initialize the instance and then return it:
    
    // Create fetch request and fetch controller
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnTransactionMO"];
    
    NSSortDescriptor *sortTransactionsByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    
    // Assign the sort descriptor to the fetch request
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortTransactionsByDate, nil]];
    
    NSMutableArray* predicateArray = [[NSMutableArray alloc] init];
    
    // Create a predicate that accepts transactions from a specified start date
    if (self.fromDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date >= %@)", self.fromDate];
        
        [predicateArray addObject:predicate];
    }
    
    // Create a predicate that accepts transactions that come before a specified end date
    if (self.toDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date <= %@)", self.toDate];
        
        [predicateArray addObject:predicate];
    }
    
    // Combine the predicates if any were created
    if (predicateArray.count > 0)
    {
        [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicateArray]];
    }
    
    [fetchRequest setFetchBatchSize:0];
    [fetchRequest setFetchLimit:0];
    
    // First clear the cache from the FRC
    [NSFetchedResultsController deleteCacheWithName:@"CacheCalTransactions"];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"CacheCalTransactions"];
    [_fetchedResultsController setDelegate:self];
    
    return _fetchedResultsController;
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
//    NSMutableArray* markedDatesArray = [[NSMutableArray alloc] init];
//   
//    for (SpnTransaction* transaction in self.fetchedTransactions)
//    {
//        [markedDatesArray addObject:[NSDate dateStartOfDay:transaction.date]];
//    }
    
    
    NSMutableArray* markedDatesArray = [[NSMutableArray alloc] init];
    
    for (SpnTransaction* transaction in self.fetchedResultsController.fetchedObjects)
    {
        [markedDatesArray addObject:[NSDate dateStartOfDay:transaction.date]];
    }

//    NSLog(@"markedDates: %lu", markedDatesArray.count);
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
        self.filteredTransactions  = [[self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicateArray]] mutableCopy];
    }
    
//    NSLog(@"loaded %lu ItemsFromDate: %@", self.filteredTransactions.count, fromDate);
}

- (void)removeAllItems
{
//    *        This message will be sent before loadItemsFromDate:toDate
//    *        as well as any time that Kal wants to clear the table view
//    *        beneath the calendar (for example, when switching between months).
//    *        You should respond to this message by removing all objects
//    *        from the list from which you vend UITableViewCells.
    [self.filteredTransactions removeAllObjects];
//    NSLog(@"removeAllItems");
}

- (void)selectedDate:(NSDate *)date
{
//    *        This message will be sent during the didSelectDate method after
//    *        loadItemsFromDate:toDate:
    [self setPreferredDate:date];
}

//<UITableViewDelegate> methods
//Handled entirely by parent

//<UITableViewDataSource> methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"numberOfRowsInSection: %lu", (unsigned long)self.filteredTransactions.count);
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
    
//    NSLog(@"cellForRowAtIndexPath: %lu", indexPath.row);
    return cell;
}

//<UITableViewDelegate> methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SEL doneButtonSelector = sel_registerName("doneButtonClicked:");
    
    // Get transaction corresponding to selected cell
    SpnTransaction* transaction = self.filteredTransactions[indexPath.row];
 
    // Create and Push transaction detail view controller
    if(transaction.type.integerValue == EXPENSE_TRANSACTION_TYPE)
    {
        spnViewController_Expense* transactionTableViewController = [[spnViewController_Expense alloc] init];
        
        transactionTableViewController.title = @"Transaction";
        transactionTableViewController.managedObjectContext = self.managedObjectContext;
        transactionTableViewController.transaction = transaction;
        
        // Add done and cancel buttons
        transactionTableViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:transactionTableViewController action:doneButtonSelector];
        
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                         style:self.navigationItem.backBarButtonItem.style
                                        target:nil
                                        action:nil];
        
        // Present the view
        [[self navigationController] pushViewController:transactionTableViewController animated:YES];
    }
    else // INCOME_TRANSACTION_TYPE
    {
        spnViewController_Income* transactionTableViewController = [[spnViewController_Income alloc] init];
        
        transactionTableViewController.title = @"Transaction";
        transactionTableViewController.managedObjectContext = self.managedObjectContext;
        transactionTableViewController.transaction = transaction;
        transactionTableViewController.isNew = NO;
        
        // Add done and cancel buttons
        transactionTableViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:transactionTableViewController action:doneButtonSelector];
        
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                         style:self.navigationItem.backBarButtonItem.style
                                        target:nil
                                        action:nil];
        
        // Present the view
        [[self navigationController] pushViewController:transactionTableViewController animated:YES];
    }
}

//<NSFetchedResultsControllerDelegate> methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
//    [tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath
{
//    NSLog(@"Change object type: %lu", type);
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(spnTransactionCellView*)[tableView cellForRowAtIndexPath:indexPath] withTransaction:[self.fetchedResultsController objectAtIndexPath:newIndexPath]];
            break;
            
        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:[NSArray
//                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray
//                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController*)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
//            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
//            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
//    [tableView endUpdates];
//    NSLog(@"Post notification");
    [[NSNotificationCenter defaultCenter] postNotificationName:KalDataSourceChangedNotification object:self];
    [self didSelectBeginDate:self.preferredDate endDate:self.preferredDate];
}


@end
