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
#import "UIView+spnViewCategory.h"
#import "spnSpendTracker.h"
#import "spnCategoryCellView.h"
#import "SpnSpendCategory.h"
#import "spnViewController_Months.h"

@interface spnTableViewController_Categories ()

@property (nonatomic) NSFetchedResultsController* fetchedResultsController;

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(selectMonth)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(spnAddButtonClicked:)];
    
    // If the month property is not set
    if(!self.month)
    {
        self.month = [self fetchInitialMonth];
    }
    
    [self changeMonth:self.month];
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

- (SpnMonth*)fetchInitialMonth
{
    SpnMonth* month = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SpnMonth" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:1];
    
    NSError* error;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(fetchResults != nil)
    {
        // Target category was found
        if([fetchResults count] != 0)
        {
            // set the return value
            month = [fetchResults objectAtIndex:0];
        }
    }

    return month;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
        entityForName:@"SpnSpendCategory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
        initWithKey:@"lastModifiedDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];

    [fetchRequest setFetchBatchSize:20];
    
    //[NSFetchedResultsController deleteCacheWithName:[NSString stringWithFormat:@"Cache%@Categories", self.month]];
    self.fetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
        managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:[NSString stringWithFormat:@"Cache%@Categories", self.month]];
    self.fetchedResultsController.delegate = self;
    
    return self.fetchedResultsController;
}

- (void)configureCell:(spnCategoryCellView*)cell atIndexPath:(NSIndexPath*)indexPath
{
    SpnSpendCategory* category = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Write cell contents
    [cell setName:category.title withTotal:category.total.floatValue forMonth:[[[spnSpendTracker sharedManager] dateFormatterMonth] stringFromDate:[NSDate date]] withBudget:0.00];
    
    
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
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
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
    
    [[spnSpendTracker sharedManager] saveContext];
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
    [transactionsTableViewController setCategory:category];
    
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

- (void)selectMonth
{
    // Create and Push month selector view controller
    spnViewController_Months* monthsTableViewController = [[spnViewController_Months alloc] initWithStyle:UITableViewStyleGrouped];
    [monthsTableViewController setTitle:@"Select Month"];
    [monthsTableViewController setManagedObjectContext:self.managedObjectContext];
    [monthsTableViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:monthsTableViewController];
    
    monthsTableViewController.delegate = self;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)closeMonthViewCntrl
{
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeMonth:(SpnMonth*)newMonth
{
    if(newMonth)
    {
        // Delete results controller cache file before modifying the predicate
        [NSFetchedResultsController deleteCacheWithName:[NSString stringWithFormat:@"Cache%@Categories", self.month]];
        
        // Set new month and update predicate
        self.month = newMonth;
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"month == %@", self.month];
        [[[self fetchedResultsController] fetchRequest] setPredicate:predicate];
        
        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error])
        {
            // Update to handle the error appropriately.
            NSLog(@"Category Fetch Error: %@, %@", error, [error userInfo]);
            exit(-1);
        }
        
        self.title = [[[spnSpendTracker sharedManager] dateFormatterMonthYear] stringFromDate:self.month.date];
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UILabel* sectionHeader = [[UILabel alloc] init];
//    [sectionHeader setText:[NSString stringWithFormat:@"Section %ld:", (long)section]];
//    [sectionHeader sizeToFit];
//    
//    return sectionHeader;
//}

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
