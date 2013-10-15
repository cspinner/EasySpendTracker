//
//  spnTableViewController_Transactions.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/29/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Transactions.h"
#import "UIViewController+addTransactionHandles.h"
#import "UIView+spnViewCategory.h"
#import "spnTransactionCellView.h"
#import "spnTableViewController_Transaction.h"
#import "SpnTransaction.h"
#import "spnSpendTracker.h"

@interface spnTableViewController_Transactions ()

@property (nonatomic) NSFetchedResultsController* fetchedResultsController;

@end

@implementation spnTableViewController_Transactions

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(spnAddButtonClicked:)];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error])
    {
        // Update to handle the error appropriately.
        NSLog(@"Transaction Fetch Error: %@, %@", error, [error userInfo]);
        exit(-1);
    }
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

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SpnTransaction" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"category == %@", self.category];
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setFetchBatchSize:20];

    //[NSFetchedResultsController deleteCacheWithName:@"CacheTransactions"]; //tbd
    self.fetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sectionName" cacheName:[NSString stringWithFormat:@"Cache%@Transactions", self.category.title]];
    self.fetchedResultsController.delegate = self;
    
    return self.fetchedResultsController;
}

- (void)configureCell:(spnTransactionCellView*)cell atIndexPath:(NSIndexPath*)indexPath
{
    SpnTransaction* transaction = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Write cell contents
    [cell setValue:transaction.value.floatValue withMerchant:[transaction merchant] onDate:[transaction date] withDescription:[transaction notes]];
}

// <UITableViewDataSource> methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"TransactionCell";
    spnTransactionCellView* cell = nil;
    
    // Acquire reuse cell object from the table view
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        // Create cell if reuse cell doesn't exist.
        cell = [[spnTransactionCellView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    //NSLog(@"%lu", (unsigned long)[sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
   
    return [sectionInfo name];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [self.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];

        // Delete parent category too if this was the last transaction to be deleted
        if([self.tableView numberOfRowsInSection:indexPath.section] == 1)
        {
            [self.managedObjectContext deleteObject:[((SpnTransaction*)[self.fetchedResultsController objectAtIndexPath:indexPath]) category]];
        }
    }
    
    [[spnSpendTracker sharedManager] saveContext];
}

// <UITableViewDelegate> methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get transaction corresponding to selected cell
    SpnTransaction* transaction = [self.fetchedResultsController objectAtIndexPath:indexPath];

    // Create and Push transaction detail view controller
    spnTableViewController_Transaction* transactionTableViewController = [[spnTableViewController_Transaction alloc] initWithStyle:UITableViewStyleGrouped];
    transactionTableViewController.title = @"Transaction";
    
    transactionTableViewController.transaction = transaction;
    [[self navigationController] pushViewController:transactionTableViewController animated:YES];
    
    //NSLog(@"%li", (long)[self.tableView numberOfRowsInSection:indexPath.section]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height;
    
    if(section == 0)
    {
        height = 32.0;
    }
    else
    {
        height = 12.0;
    }
    return height;
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
            [self configureCell:(spnTransactionCellView*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
