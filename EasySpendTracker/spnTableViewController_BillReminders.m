//
//  spnTableViewController_BillReminders.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 11/21/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_BillReminders.h"
#import "UIViewController+addTransactionHandles.h"
#import "SpnBillReminder.h"
#import "spnViewController_BillReminder.h"
#import "spnSpendTracker.h"

@interface spnTableViewController_BillReminders ()

@property (nonatomic)  NSFetchedResultsController* fetchedResultsController;

@end

#define CELL_HEIGHT 44.0

@implementation spnTableViewController_BillReminders

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
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error])
    {
        // Update to handle the error appropriately.
        NSLog(@"Transaction Fetch Error: %@, %@", error, [error userInfo]);
        exit(-1);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[spnSpendTracker sharedManager] updateAllReminders];
    
    [self.tableView reloadData];
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
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnBillReminderMO"];
    
    NSSortDescriptor *sortRemindersByDate = [[NSSortDescriptor alloc] initWithKey:@"dateDue" ascending:YES];
    
    // Assign the sort descriptor to the fetch request
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortRemindersByDate, nil]];
    
    NSMutableArray* predicateArray = [[NSMutableArray alloc] init];
    
    // Combine the predicates if any were created
    if (predicateArray.count > 0)
    {
        [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicateArray]];
    }
    
    [NSFetchedResultsController deleteCacheWithName:@"CacheReminders"];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sectionName" cacheName:@"CacheReminders"];
    [_fetchedResultsController setDelegate:self];
    
    return _fetchedResultsController;
}

- (void)configureCell:(UITableViewCell*)cell withReminder:(SpnBillReminder*)reminder
{
    NSString* paidStatusStr;
    
    switch (reminder.paidStatus)
    {
        case PAID_STATUS_UNPAID:
            paidStatusStr = @"UNPAID";
            [cell.detailTextLabel setTextColor:[UIColor redColor]];
            break;
            
        case PAID_STATUS_PAID:
            paidStatusStr = @"PAID";
            [cell.detailTextLabel setTextColor:[UIColor colorWithRed:0.0 green:0.39 blue:0.0 alpha:1.0]];
            break;
            
        case PAID_STATUS_NONE:
        default:
            paidStatusStr = @"PENDING";
            [cell.detailTextLabel setTextColor:[UIColor grayColor]];
            break;
    }
    
    [cell.textLabel setText:reminder.merchant];
    [cell.detailTextLabel setText:paidStatusStr];
}

// <UITableViewDataSource> methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"ReminderCell";
    
    // Acquire reuse cell object from the table view
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        // Create cell if reuse cell doesn't exist.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (self.tableView == tableView)
    {
        [self configureCell:cell withReminder:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.tableView == tableView)
    {
        return [[self.fetchedResultsController sections] count];
    }
    else
    {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of row.
    if (self.tableView == tableView)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        
        return [sectionInfo numberOfObjects];
    }
    else
    {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.tableView == tableView)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        
        return [sectionInfo name];
    }
    else
    {
        return nil;
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SEL doneButtonSelector = sel_registerName("doneButtonClicked:");
    
    // Get transaction corresponding to selected cell
    SpnBillReminder* reminder;
    
    if (self.tableView == tableView)
    {
        reminder = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        // Create and Push transaction detail view controller
        spnViewController_BillReminder* reminderViewController = [[spnViewController_BillReminder alloc] init];
        
        reminderViewController.title = @"Bill Reminder";
        reminderViewController.managedObjectContext = self.managedObjectContext;
        reminderViewController.billReminder = reminder;
        
        // Add done and cancel buttons
        reminderViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:reminderViewController action:doneButtonSelector];
        
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                         style:self.navigationItem.backBarButtonItem.style
                                        target:nil
                                        action:nil];
        
        // Present the view
        [[self navigationController] pushViewController:reminderViewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.tableView == tableView)
    {
        return 30;
    }
    else
    {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

// <NSFetchedResultsControllerDelegate> methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] withReminder:[self.fetchedResultsController objectAtIndexPath:newIndexPath]];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController*)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


@end
