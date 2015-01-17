//
//  spnTableViewController_Categories.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/25/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Categories.h"
#import "UIViewController+addTransactionHandles.h"
#import "iAd/iAd.h"
#import "spnInAppPurchaseManager.h"

@interface spnTableViewController_Categories ()

@property (nonatomic, strong) UISearchDisplayController* mySearchDisplayController;
@property UISearchBar* searchBar;
@property NSMutableArray* searchResults;

@end

#define CELL_HEIGHT 44.0

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
    
    // search bar init
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, CELL_HEIGHT)];
    [self.searchBar setDelegate:self];
    [self.searchBar setPlaceholder:@"Search for category"];
    
    // search display controller
    self.mySearchDisplayController = [[UISearchDisplayController alloc]
                                    initWithSearchBar:self.searchBar contentsController:self];
    [self.mySearchDisplayController setDelegate:self];
    [self.mySearchDisplayController setSearchResultsDataSource:self];
    [self.mySearchDisplayController setSearchResultsDelegate:self];
    
    // initialize empty search results array
    self.searchResults = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(spnAddButtonClicked:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setCanDisplayBannerAds:![[spnInAppPurchaseManager sharedManager] productPurchased:spnInAppProduct_AdFreeUpgrade]];
    
    // Display the search bar
    [self.tableView setTableHeaderView:self.searchBar];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.entityName];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"lastModifiedDate" ascending:NO];
    
    // Assign the sort descriptor to the fetch request
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSMutableArray* predicateArray = [[NSMutableArray alloc] init];
    
    // Create a predicate that accepts transactions from a specified start date
    if (self.startDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(lastModifiedDate >= %@)", self.startDate];
        
        [predicateArray addObject:predicate];
    }
    
    // Create a predicate that accepts transactions that come before a specified end date
    if (self.endDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(lastModifiedDate < %@)", self.endDate];
        
        [predicateArray addObject:predicate];
    }
    
    // Create a predicate for the category title
    if (self.predicate != nil)
    {
        [predicateArray addObject:self.predicate];
    }
    
    // Combine the predicates if any were created
    if (predicateArray.count > 0)
    {
        [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicateArray]];
    }
    
    [fetchRequest setFetchBatchSize:20];
    
    [NSFetchedResultsController deleteCacheWithName:[NSString stringWithFormat:@"Cache%@", self.entityName]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:[NSString stringWithFormat:@"Cache%@", self.entityName]];
    
    [_fetchedResultsController setDelegate:self];
    
    return _fetchedResultsController;
}

// <UITableViewDataSource> methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"CategoryCell";
    UITableViewCell* cell = nil;

    // Acquire reuse cell object from the table view
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
    {
        // Create cell if reuse cell doesn't exist.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Call sub class specific cell configure
    if ([self.delegate respondsToSelector:@selector(configureCell:withObject:)])
    {
        if (self.tableView == tableView)
        {
            [self.delegate configureCell:cell withObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        }
        else // self.searchDisplayController.searchResultsTableView
        {
            [self.delegate configureCell:cell withObject:[self.searchResults objectAtIndex:indexPath.row]];
        }
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableView == tableView)
    {
        id <NSFetchedResultsSectionInfo>sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    else // self.searchDisplayController.searchResultsTableView
    {
        return self.searchResults.count;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.tableView == tableView)
    {
        // Return the number of sections.
        return [[self.fetchedResultsController sections] count];
    }
    else // self.searchDisplayController.searchResultsTableView
    {
        return 1;
    }
}

// <UITableViewDelegate> methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView == tableView)
    {
        if ([self.delegate respondsToSelector:@selector(selectedObjectIndexPath:)])
        {
            [self.delegate selectedObjectIndexPath:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        }
    }
    else // self.searchDisplayController.searchResultsTableView
    {
        [self.delegate selectedObjectIndexPath:[self.searchResults objectAtIndex:indexPath.row]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.tableView == tableView)
    {
        return 0.001;
    }
    else // self.searchDisplayController.searchResultsTableView
    {
        return 0.001;
    }
    
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
            // Call sub class specific cell configure
            if ([self.delegate respondsToSelector:@selector(configureCell:withObject:)])
            {
                [self.delegate configureCell:[tableView cellForRowAtIndexPath:indexPath] withObject:[self.fetchedResultsController objectAtIndexPath:newIndexPath]];
            }
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

//<UISearchDisplayDelegate> methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scopeButtonIndex:[self.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scopeButtonIndex:searchOption];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scopeButtonIndex:(NSInteger)scopeButtonIndex
{
    // Remove all objects from the filtered search array
    [self.searchResults removeAllObjects];
    
    NSArray* fetchedObjects = [self.fetchedResultsController fetchedObjects];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchText];
    
    self.searchResults = [NSMutableArray arrayWithArray:[fetchedObjects filteredArrayUsingPredicate:predicate]];
}

#pragma mark - property overrides

- (void)setStartDate:(NSDate *)startDate
{
    _startDate = startDate;
    _fetchedResultsController = nil;
}

- (void)setEndDate:(NSDate *)endDate
{
    _endDate = endDate;
    _fetchedResultsController = nil;
}

@end
