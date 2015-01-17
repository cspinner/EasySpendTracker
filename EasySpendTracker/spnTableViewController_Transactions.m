//
//  spnTableViewController_Transactions.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/29/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Transactions.h"
#import "UIViewController+addTransactionHandles.h"
#import "spnTransactionCellView.h"
#import "spnViewController_Expense.h"
#import "spnViewController_Income.h"
#import "SpnTransaction.h"
#import "spnSpendTracker.h"
#import "iAd/iAd.h"
#import "spnInAppPurchaseManager.h"

@interface spnTableViewController_Transactions ()

@property (nonatomic)  NSFetchedResultsController* fetchedResultsController;

@property (nonatomic, strong) UISearchDisplayController* mySearchDisplayController;
@property UISearchBar* searchBar;
@property NSMutableArray* searchResults;

@end

#define CELL_HEIGHT 44.0
#define FETCH_LIMIT 250

const float epsilon = 0.000001;

typedef NS_ENUM(NSInteger, TransSearchBarButtonIndexType)
{
    SEARCHBAR_ALL_BUTTON_INDEX,
    SEARCHBAR_AMOUNT_BUTTON_INDEX,
    SEARCHBAR_MERCHANT_BUTTON_INDEX,
    SEARCHBAR_NOTES_BUTTON_INDEX,
    SEARCHBAR_BUTTON_INDEX_COUNT
};

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
    
    // search bar init
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, CELL_HEIGHT)];
    [self.searchBar setDelegate:self];
    [self.searchBar setPlaceholder:@"Search for Transaction"];
    [self.searchBar setScopeButtonTitles:[NSArray arrayWithObjects:@"All", @"Amount", @"Merchant", @"Notes", nil]];
    
    // search display controller
    self.mySearchDisplayController = [[UISearchDisplayController alloc]
                                      initWithSearchBar:self.searchBar contentsController:self];
    [self.mySearchDisplayController setDelegate:self];
    [self.mySearchDisplayController setSearchResultsDataSource:self];
    [self.mySearchDisplayController setSearchResultsDelegate:self];
    
    // initialize empty search results array
    self.searchResults = [[NSMutableArray alloc] initWithCapacity:0];
    
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
    
    [self setCanDisplayBannerAds:![[spnInAppPurchaseManager sharedManager] productPurchased:spnInAppProduct_AdFreeUpgrade]];
    
    // Display the search bar
    [self.tableView setTableHeaderView:self.searchBar];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    static BOOL isFirstAppearance = YES;
    
    [super viewDidAppear:animated];
    
    if (isFirstAppearance)
    {
        // Scroll to the row nearest to the present date - assumes transactions are presorted by newest to oldest
        NSDate* todaysDate = [NSDate date];
        for (SpnTransaction* transaction in [self.fetchedResultsController fetchedObjects])
        {
            NSComparisonResult dateCompareResult = [todaysDate compare:transaction.date];
            
            if ((dateCompareResult == NSOrderedSame) ||
                (dateCompareResult == NSOrderedDescending))
            {
                [self.tableView scrollToRowAtIndexPath:[self.fetchedResultsController indexPathForObject:transaction] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                break;
            }
        }
        
        isFirstAppearance = NO;
    }
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
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnTransactionMO"];
    
    NSSortDescriptor *sortTransactionsByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    
    // Assign the sort descriptor to the fetch request
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortTransactionsByDate, nil]];
    
    NSMutableArray* predicateArray = [[NSMutableArray alloc] init];
    
    // Create a predicate that accepts transactions from a specified start date
    if (self.startDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date >= %@)", self.startDate];
        
        [predicateArray addObject:predicate];
    }
    
    // Create a predicate that accepts transactions that come before a specified end date
    if (self.endDate != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date < %@)", self.endDate];
        
        [predicateArray addObject:predicate];
    }
    
    // Create a predicate for the category title
    if (self.categoryTitles != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"subCategory.category.title IN %@", self.categoryTitles];
        
        [predicateArray addObject:predicate];
    }
    
    // Create a predicate for the subCategory title
    if (self.subCategoryTitles != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"subCategory.title IN %@", self.subCategoryTitles];
        
        [predicateArray addObject:predicate];
    }
    
    // Create a predicate for the merchant title
    if (self.merchantTitles != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"merchant IN %@", self.merchantTitles];
        
        [predicateArray addObject:predicate];
    }
    
    // Combine the predicates if any were created
    if (predicateArray.count > 0)
    {
        [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicateArray]];
    }

    [fetchRequest setFetchBatchSize:FETCH_LIMIT];
    [fetchRequest setFetchLimit:FETCH_LIMIT];
    
    [NSFetchedResultsController deleteCacheWithName:@"CacheTransactions"];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sectionName" cacheName:@"CacheTransactions"];
    [_fetchedResultsController setDelegate:self];
    
    return _fetchedResultsController;
}

// this method is called to load more transactions when the user scrolls to the last row
- (void)loadMoreTransactions
{
    // If we fetched exactly the number of entries as the fetch limit, there's probably more to fetch
    if (self.fetchedResultsController.fetchRequest.fetchLimit == [[self.fetchedResultsController fetchedObjects] count])
    {
        // First clear the cache from the FRC
        [NSFetchedResultsController deleteCacheWithName:@"CacheTransactions"];
        
        // Set the new fetch limit to the present limit plus another FETCH_LIMIT
        NSUInteger newFetchLimit = self.fetchedResultsController.fetchRequest.fetchLimit + FETCH_LIMIT;
        [self.fetchedResultsController.fetchRequest setFetchLimit:newFetchLimit];
        
        NSError *error;
        if (![self.fetchedResultsController performFetch:&error])
        {
            // Update to handle the error appropriately.
            NSLog(@"Transaction Fetch Error: %@, %@", error, [error userInfo]);
            exit(-1);
        }
        
        [self.tableView reloadData];
    }
}

- (void)configureCell:(spnTransactionCellView*)cell withTransaction:(SpnTransaction*)transaction showDate:(BOOL)showDate
{
    // Write cell contents
    NSString* category = [transaction valueForKeyPath:@"subCategory.category.title"];
    NSDate* dateForDisplay = showDate ? transaction.date : nil;
    
    [cell setValue:transaction.value.floatValue withMerchant:transaction.merchant isIncome:[category isEqualToString:@"Income"] onDate:dateForDisplay isRecurring:(transaction.recurrence != nil)];
}

- (void)filterContentForSearchText:(NSString*)searchText scopeButtonIndex:(NSInteger)scopeButtonIndex
{
    // Remove all objects from the filtered search array
    [self.searchResults removeAllObjects];
    
    NSArray* fetchedObjects = [self.fetchedResultsController fetchedObjects];
    
    NSPredicate* predicate;
    
    // Set predicate based on scope option
    switch (scopeButtonIndex)
    {
        case SEARCHBAR_AMOUNT_BUTTON_INDEX:
        {
            // Search text for the amount must be preceded by the dollar sign since we're expecting currency
            NSString* numberString = searchText;
            NSRange currencySymbolRange = [numberString rangeOfString:@"$"];
            if (currencySymbolRange.location == NSNotFound)
            {
                // Prepend the currency symbol to the front of the received string.
                NSString* currencySymbol = @"$";
                numberString = [currencySymbol stringByAppendingString:numberString];
            }
            
            // Parse search text and convert to a number
            NSNumberFormatter* valueFormatter = [[NSNumberFormatter alloc] init];
            [valueFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [valueFormatter setCurrencyCode:@"USD"];
            NSNumber* numberToSearchFor = [valueFormatter numberFromString:numberString];
            
            // Protect against NaN
            numberToSearchFor = ((!numberToSearchFor.floatValue) ? [NSNumber numberWithFloat:0.0] : numberToSearchFor);
            
            // Predicate searches float value in sizable range since it is never safe to directly compare two floats
            predicate = [NSPredicate predicateWithFormat:@"(value >= %f) AND (value =< %f)", numberToSearchFor.floatValue - epsilon, numberToSearchFor.floatValue + epsilon];
        }
            break;
            
        case SEARCHBAR_MERCHANT_BUTTON_INDEX:
        {
            predicate = [NSPredicate predicateWithFormat:@"merchant CONTAINS[cd] %@", searchText];
        }
            break;
            
        case SEARCHBAR_NOTES_BUTTON_INDEX:
        {
            predicate = [NSPredicate predicateWithFormat:@"notes CONTAINS[cd] %@", searchText];
        }
            break;
            
        case SEARCHBAR_ALL_BUTTON_INDEX:
        default:
        {
            // Search text for the amount must be preceded by the dollar sign since we're expecting currency
            NSNumber* numberToSearchFor;
            {
                NSString* numberString = searchText;
                NSRange currencySymbolRange = [numberString rangeOfString:@"$"];
                
                if (currencySymbolRange.location == NSNotFound)
                {
                    // Prepend the currency symbol to the front of the received string.
                    NSString* currencySymbol = @"$";
                    numberString = [currencySymbol stringByAppendingString:numberString];
                }
                
                // Parse search text and convert to a number
                NSNumberFormatter* valueFormatter = [[NSNumberFormatter alloc] init];
                [valueFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [valueFormatter setCurrencyCode:@"USD"];
                numberToSearchFor = [valueFormatter numberFromString:numberString];
                
                // Protect against NaN
                numberToSearchFor = ((!numberToSearchFor.floatValue) ? [NSNumber numberWithFloat:0.0] : numberToSearchFor);
            }
            
            // Predicate searches float value in sizable range since it is never safe to directly compare two floats
            predicate = [NSPredicate predicateWithFormat:@"((value >= %f) AND (value =< %f)) OR (merchant CONTAINS[cd] %@) OR (notes CONTAINS[cd] %@)", numberToSearchFor.floatValue - epsilon, numberToSearchFor.floatValue + epsilon, searchText, searchText];
        }
            break;
    }
    
    self.searchResults = [NSMutableArray arrayWithArray:[fetchedObjects filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"TransactionCell";
    
    // Acquire reuse cell object from the table view
    spnTransactionCellView* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        // Create cell if reuse cell doesn't exist.
        cell = [[spnTransactionCellView alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (self.tableView == tableView)
    {
        [self configureCell:cell withTransaction:[self.fetchedResultsController objectAtIndexPath:indexPath] showDate:NO];
        
        if ((indexPath.section == ([self numberOfSectionsInTableView:tableView] - 1)) &&
            (indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1)))
        {
            [self loadMoreTransactions];
        }
    }
    else // self.searchDisplayController.searchResultsTableView
    {
        [self configureCell:cell withTransaction:[self.searchResults objectAtIndex:indexPath.row] showDate:YES];
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
    else // self.searchDisplayController.searchResultsTableView
    {
        return 1;
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
    else // self.searchDisplayController.searchResultsTableView
    {
        return self.searchResults.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.tableView == tableView)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        
        return [sectionInfo name];
    }
    else // self.searchDisplayController.searchResultsTableView
    {
        return nil;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle)
    {
        case UITableViewCellEditingStyleDelete:
        {
            // delete the reminder object associated with the row
            [[spnSpendTracker sharedManager] deleteTransaction:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SEL doneButtonSelector = sel_registerName("doneButtonClicked:");
    
    // Get transaction corresponding to selected cell
    SpnTransaction* transaction;
    
    if (self.tableView == tableView)
    {
        transaction = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    else // self.searchDisplayController.searchResultsTableView
    {
        transaction = [self.searchResults objectAtIndex:indexPath.row];
    }

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
    
    //NSLog(@"%li", (long)[self.tableView numberOfRowsInSection:indexPath.section]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.tableView == tableView)
    {
        return 30;
    }
    else // self.searchDisplayController.searchResultsTableView
    {
        return 0.001;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

#pragma mark - NSFetchedResultsControllerDelegate methods

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
            [self configureCell:(spnTransactionCellView*)[tableView cellForRowAtIndexPath:indexPath] withTransaction:[self.fetchedResultsController objectAtIndexPath:newIndexPath] showDate:NO];
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

#pragma mark - UISearchDisplayDelegate methods

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

#pragma mark - property overrides

- (void)setCategoryTitles:(NSArray *)categoryTitles
{
    _categoryTitles = categoryTitles;
    _fetchedResultsController = nil;
}

- (void)setSubCategoryTitles:(NSArray *)subCategoryTitles
{
    _subCategoryTitles = subCategoryTitles;
    _fetchedResultsController = nil;
}

- (void)setMerchantTitles:(NSArray *)merchantTitles
{
    _merchantTitles = merchantTitles;
    _fetchedResultsController = nil;
}

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
