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
#import "SpnBillReminder.h"
#import "spnTransactionCellView.h"
#import "spnViewController_Expense.h"
#import "spnViewController_Income.h"
#import "spnViewController_BillReminder.h"

@interface spnViewController_Calendar ()

@property (nonatomic)  NSFetchedResultsController* fetchedResultsController_Transactions;
@property (nonatomic)  NSFetchedResultsController* fetchedResultsController_Reminders;
@property NSDate* fromDate;
@property NSDate* toDate;

@property NSMutableArray* filteredTransactions;
@property NSMutableArray* filteredReminders;

@end

enum
{
    SECTION_IDX_REMINDER,
    SECTION_IDX_TRANSACTION,
    SECTION_IDX_COUNT
};

@implementation spnViewController_Calendar

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Today", @"") style:UIBarButtonItemStylePlain target:self action:@selector(selectTodaysDate)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(spnAddButtonClicked:)];
}


- (NSFetchedResultsController*)fetchedResultsController_Transactions
{
    // Return the instance if it already exists
    if (_fetchedResultsController_Transactions != nil)
    {
        return _fetchedResultsController_Transactions;
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
    
    _fetchedResultsController_Transactions = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"CacheCalTransactions"];
    [_fetchedResultsController_Transactions setDelegate:self];
    
    return _fetchedResultsController_Transactions;
}

- (NSFetchedResultsController*)fetchedResultsController_Reminders
{
    // Return the instance if it already exists
    if (_fetchedResultsController_Reminders != nil)
    {
        return _fetchedResultsController_Reminders;
    }
    
    // Otherwise, initialize the instance and then return it:
    
    // Create fetch request and fetch controller
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnBillReminderMO"];
    
    NSSortDescriptor *sortRemindersByDate = [[NSSortDescriptor alloc] initWithKey:@"dateDue" ascending:YES];
    
    // Assign the sort descriptor to the fetch request
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortRemindersByDate, nil]];
    
    NSMutableArray* predicateArray = [[NSMutableArray alloc] init];
    
    // Create a predicate that accepts reminders from a specified start date
    if (self.fromDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(dateDue >= %@)", self.fromDate];
        
        [predicateArray addObject:predicate];
    }
    
    // Create a predicate that accepts transactions that come before a specified end date
    if (self.toDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(dateDue <= %@)", self.toDate];
        
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
    [NSFetchedResultsController deleteCacheWithName:@"CacheCalReminders"];
    
    _fetchedResultsController_Reminders = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"CacheCalReminders"];
    [_fetchedResultsController_Reminders setDelegate:self];
    
    return _fetchedResultsController_Reminders;
}


- (void)filterFetchedTransactionsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
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
        self.filteredTransactions  = [[self.fetchedResultsController_Transactions.fetchedObjects filteredArrayUsingPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicateArray]] mutableCopy];
    }
    
    //    NSLog(@"loaded %lu ItemsFromDate: %@", self.filteredTransactions.count, fromDate);
}

- (void)filterFetchedRemindersFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSMutableArray* predicateArray = [[NSMutableArray alloc] init];
    
    // Create a predicate that accepts transactions from a specified start date
    if (fromDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(dateDue >= %@)", fromDate];
        
        [predicateArray addObject:predicate];
    }
    
    // Create a predicate that accepts transactions that come before a specified end date
    if (toDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(dateDue <= %@)", toDate];
        
        [predicateArray addObject:predicate];
    }
    
    // Combine the predicates if any were created
    if (predicateArray.count > 0)
    {
        self.filteredReminders  = [[self.fetchedResultsController_Reminders.fetchedObjects filteredArrayUsingPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicateArray]] mutableCopy];
    }
    
    //    NSLog(@"loaded %lu ItemsFromDate: %@", self.filteredTransactions.count, fromDate);
}

// Action handler for the navigation bar's left bar button item.
- (void)selectTodaysDate
{
    [self setSelectedDate:[NSDate dateStartOfDay:[NSDate date]]];
}

- (void)resetFetchedResultsController
{
    _fetchedResultsController_Transactions = nil;
    _fetchedResultsController_Reminders = nil;
}

- (void)configureCell:(spnTransactionCellView*)cell withTransaction:(SpnTransaction*)transaction
{
    // Write cell contents
    NSString* category = [transaction valueForKeyPath:@"subCategory.category.title"];

    // Write cell contents
    [cell.textLabel setText:transaction.merchant];
    [cell.textLabel setFont:[UIFont systemFontOfSize:11.5]];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:11.5]];
    
    if ([category isEqualToString:@"Income"])
    {
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"$%.2f", transaction.value.floatValue]];
        [cell.detailTextLabel setTextColor:[UIColor blackColor]];
    }
    else
    {
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"($%.2f)", transaction.value.floatValue]];
        [cell.detailTextLabel setTextColor:[UIColor redColor]];
    }
}

- (void)configureCell:(UITableViewCell*)cell withReminder:(SpnBillReminder*)reminder
{
    // Write cell contents
    [cell.textLabel setText:reminder.merchant];
    [cell.textLabel setFont:[UIFont systemFontOfSize:11.5]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"$%.2f", reminder.value.floatValue]];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:11.5]];
}

#pragma mark - KalDataSource methods
- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
    [self resetFetchedResultsController];
    self.fromDate = fromDate;
    self.toDate = toDate;
    
    NSError *error;
    if (![self.fetchedResultsController_Transactions performFetch:&error])
    {
        // Update to handle the error appropriately.
        NSLog(@"Calendar Transaction Fetch Error: %@, %@", error, [error userInfo]);
        exit(-1);
    }
    
    if (![self.fetchedResultsController_Reminders performFetch:&error])
    {
        // Update to handle the error appropriately.
        NSLog(@"Calendar Reminder Fetch Error: %@, %@", error, [error userInfo]);
        exit(-1);
    }
    
//    NSLog(@"loadedDataSource. %lu transactions fetched", self.fetchedResultsController.fetchedObjects.count);
    [delegate loadedDataSource:self];
}

- (NSArray *)markedDatesAFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
//    *        This message will be sent to your dataSource immediately
//    *        after you issue the loadedDataSource: callback message
//    *        from the body of your presentingDatesFrom:to:delegate method.
//    *        You should respond to this message by returning an array of NSDates
//    *        for each day in the specified range which has associated application
//    *        data.
//    *
//    *        Dates returned from markedDatesAFrom:to: will be marked with a gray dot.
//    *
//    *        If this message is received but the application data is not yet
//    *        ready, your code should immediately return an empty NSArray.

    NSMutableArray* markedDatesArray = [[NSMutableArray alloc] init];
    
    for (SpnTransaction* transaction in self.fetchedResultsController_Transactions.fetchedObjects)
    {
        [markedDatesArray addObject:[NSDate dateStartOfDay:transaction.date]];
    }

//    NSLog(@"markedDatesA: %lu", markedDatesArray.count);
    return markedDatesArray;
}

- (NSArray *)markedDatesBFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    //    *        This message will be sent to your dataSource immediately
    //    *        after you issue the loadedDataSource: callback message
    //    *        from the body of your presentingDatesFrom:to:delegate method.
    //    *        You should respond to this message by returning an array of NSDates
    //    *        for each day in the specified range which has associated application
    //    *        data.
    //    *
    //    *        Dates returned from markedDatesBFrom:to: will be marked with a blue circle.
    //    *
    //    *        If this message is received but the application data is not yet
    //    *        ready, your code should immediately return an empty NSArray.
    
    NSMutableArray* markedDatesArray = [[NSMutableArray alloc] init];
    
    for (SpnBillReminder* reminder in self.fetchedResultsController_Reminders.fetchedObjects)
    {
        [markedDatesArray addObject:[NSDate dateStartOfDay:reminder.dateDue]];
    }
    
    //    NSLog(@"markedDatesB: %lu", markedDatesArray.count);
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
    [self filterFetchedTransactionsFromDate:fromDate toDate:toDate];
    [self filterFetchedRemindersFromDate:fromDate toDate:toDate];
}

- (void)removeAllItems
{
//    *        This message will be sent before loadItemsFromDate:toDate
//    *        as well as any time that Kal wants to clear the table view
//    *        beneath the calendar (for example, when switching between months).
//    *        You should respond to this message by removing all objects
//    *        from the list from which you vend UITableViewCells.
    [self.filteredTransactions removeAllObjects];
    [self.filteredReminders removeAllObjects];
//    NSLog(@"removeAllItems");
}

- (void)selectedDate:(NSDate *)date
{
//    *        This message will be sent during the didSelectDate method after
//    *        loadItemsFromDate:toDate:
    [self setPreferredDate:date];
}

#pragma mark - UITableViewDelegate methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width, headerView.frame.size.height)];
    
    // Must be in the same order as SECTION_IDX_* enums
    NSArray* headerText = [NSArray arrayWithObjects:
                           @"BILLS",
                           @"TRANSACTIONS",
                           nil];
    
    // Set text based on section index
    [headerLabel setText:headerText[section]];
    [headerLabel setFont:[UIFont systemFontOfSize:12]];
    [headerLabel setTextColor:[UIColor grayColor]];
    
    [headerView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // only show a section header if there is data
    if ((section == SECTION_IDX_REMINDER) && (self.filteredReminders.count > 0))
    {
        return 25.0;
    }
    else if ((section == SECTION_IDX_TRANSACTION) && (self.filteredTransactions.count > 0))
    {
        return 25.0;
    }
    else
    {
        return 0.001;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SEL doneButtonSelector = sel_registerName("doneButtonClicked:");
    
    if (indexPath.section == SECTION_IDX_REMINDER)
    {
        // Get transaction corresponding to selected cell
        SpnBillReminder* reminder = self.filteredReminders[indexPath.row];
        
        // Create and Push reminder detail view controller
        spnViewController_BillReminder* reminderTableViewController = [[spnViewController_BillReminder alloc] init];
        
        reminderTableViewController.title = reminder.merchant;
        reminderTableViewController.managedObjectContext = self.managedObjectContext;
        reminderTableViewController.billReminder = reminder;
        
        // Add done and cancel buttons
        reminderTableViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:reminderTableViewController action:doneButtonSelector];
        
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                         style:self.navigationItem.backBarButtonItem.style
                                        target:nil
                                        action:nil];
        
        // Present the view
        [[self navigationController] pushViewController:reminderTableViewController animated:YES];
    }
    else if (indexPath.section == SECTION_IDX_TRANSACTION)
    {
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
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_IDX_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_IDX_REMINDER)
    {
        //    NSLog(@"numberOfRowsInSection %lu: %lu", section, (unsigned long)self.filteredReminders.count);
        return self.filteredReminders.count;
    }
    else if (section == SECTION_IDX_TRANSACTION)
    {
        //    NSLog(@"numberOfRowsInSection %lu: %lu", section, (unsigned long)self.filteredTransactions.count);
        return self.filteredTransactions.count;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_IDX_REMINDER)
    {
        static NSString* CellIdentifier = @"CalendarRemEventCell";
        
        // Acquire reuse cell object from the table view
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell)
        {
            // Create cell if reuse cell doesn't exist.
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        [self configureCell:cell withReminder:self.filteredReminders[indexPath.row]];
        
        //    NSLog(@"cellForRowAtIndexPath: %lu", indexPath.row);
        return cell;
    }
    else if (indexPath.section == SECTION_IDX_TRANSACTION)
    {
        static NSString* CellIdentifier = @"CalendarTransEventCell";
        
        // Acquire reuse cell object from the table view
//        spnTransactionCellView* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        spnTransactionCellView* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell)
        {
            // Create cell if reuse cell doesn't exist.
//            cell = [[spnTransactionCellView alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell = (spnTransactionCellView*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        [self configureCell:cell withTransaction:self.filteredTransactions[indexPath.row]];
        
        //    NSLog(@"cellForRowAtIndexPath: %lu", indexPath.row);
        return cell;
    }
    else
    {
        return nil;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate methods

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
            if (controller == self.fetchedResultsController_Reminders)
            {
                [self configureCell:[previewTableView cellForRowAtIndexPath:indexPath] withReminder:[self.fetchedResultsController_Reminders objectAtIndexPath:newIndexPath]];
            }
            else if (controller == self.fetchedResultsController_Transactions)
            {
                [self configureCell:(spnTransactionCellView*)[previewTableView cellForRowAtIndexPath:indexPath] withTransaction:[self.fetchedResultsController_Transactions objectAtIndexPath:newIndexPath]];
            }
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
