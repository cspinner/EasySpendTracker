//
//  spnTableViewController_Categories.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/25/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Categories.h"
#import "spnTableViewController_Transactions.h"
#import "UIViewController+addTransactionHandles.h"
#import "UIView+spnViewCtgy.h"
#import "spnCategoryCellView.h"
#import "SpnSpendCategory.h"
#import "spnUtils.h"

@interface spnTableViewController_Categories ()

@end

@implementation spnTableViewController_Categories

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
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self.delegate action:@selector(monthSelect)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(spnAddButtonClicked:)];
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

- (void)configureCell:(spnCategoryCellView*)cell atIndexPath:(NSIndexPath*)indexPath
{
    SpnSpendCategory* category = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Write cell contents
    [cell setName:category.title withTotal:category.total.floatValue forMonth:[[[spnUtils sharedUtils] dateFormatterMonth] stringFromDate:[NSDate date]] withBudget:0.00];
}

// <UITableViewDataSource> methods
- (spnCategoryCellView *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"CategoryCell";
    spnCategoryCellView* cell = nil;

    // Acquire reuse cell object from the table view
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
    {
        // Create cell if reuse cell doesn't exist.
        cell = [[spnCategoryCellView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo>sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [self.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
    
    [self saveContext:self.managedObjectContext];
}

// <UITableViewDelegate> methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get reference to selected item from the fetch controller
    SpnSpendCategory* category = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Create and Push transaction detail view controller
    spnTableViewController_Transactions* transactionsTableViewController = [[spnTableViewController_Transactions alloc] initWithStyle:UITableViewStyleGrouped];
    [transactionsTableViewController setTitle:[category title]];
    [transactionsTableViewController setManagedObjectContext:self.managedObjectContext];
    
    // Create fetch request and fetch controller
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnTransactionMO"];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"category == %@", category];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:20];
    
    [NSFetchedResultsController deleteCacheWithName:[NSString stringWithFormat:@"Cache%@Transactions", category.title]];
    [transactionsTableViewController setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sectionName" cacheName:[NSString stringWithFormat:@"Cache%@Transactions", category.title]]];
    [transactionsTableViewController.fetchedResultsController setDelegate:transactionsTableViewController];
    
    [[self navigationController] pushViewController:transactionsTableViewController animated:YES];
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
            [self configureCell:(spnCategoryCellView*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
