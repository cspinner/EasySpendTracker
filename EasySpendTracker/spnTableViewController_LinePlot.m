//
//  spnTableViewController_LinePlot.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/7/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_LinePlot.h"
#import "UIViewController+addTransactionHandles.h"
#import "spnTransactionFetchOp.h"
#import "spnLineChartProcessDataOp.h"
#import "iAd/iAd.h"
#import "spnInAppPurchaseManager.h"

@interface spnTableViewController_LinePlot ()

@property (nonatomic)  NSFetchedResultsController* fetchedResultsController;

// the queue to run operations
@property (nonatomic, strong) NSOperationQueue* queue;

// These two are sorted together
@property NSMutableArray* allCategoriesPlotXYValues;
@property NSMutableArray* allCategoriesPlotXLabels;

// Local Line Plots and data
@property NSMutableArray* categoryLinePlots;
@property NSMutableArray* categoriesPlotXYValues; // array of arrays
@property NSMutableArray* categoriesPlotXLabels; // array of arrays

@end

#define LINE_PLOT_HEIGHT 200.0

enum
{
    CELL_CHART_TAG_LABEL = 1,
    CELL_CHART_TAG_PLOT,
    CELL_CHART_TAG_ACTIVITY
};

@implementation spnTableViewController_LinePlot

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        // Create the operation queue that will run any operations
        self.queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(void)viewDidLoad
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
    
    // Init the line plot and data/label arrays
    NSUInteger capacity = [self.fetchedResultsController fetchedObjects].count;
    self.categoryLinePlots = [[NSMutableArray alloc] initWithCapacity:capacity];
    self.categoriesPlotXYValues = [[NSMutableArray alloc] initWithCapacity:capacity];
    self.categoriesPlotXLabels = [[NSMutableArray alloc] initWithCapacity:capacity];
    
    // Add initialized objects
    for (NSUInteger i = 0; i < capacity; i++)
    {
        spnLinePlot* plot = [[spnLinePlot alloc] init];
        plot.delegate = self;
        
        [self.categoryLinePlots addObject:plot];
        [self.categoriesPlotXYValues addObject:[[NSMutableArray alloc] init]];
        [self.categoriesPlotXLabels addObject:[[NSMutableArray alloc] init]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self setCanDisplayBannerAds:![[spnInAppPurchaseManager sharedManager] productPurchased:spnInAppProduct_AdFreeUpgrade]];
    
    [self.tableView reloadData];
}

// Must be overridden by subclass
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
    
    NSSortDescriptor *sortCategoriesByDate = [[NSSortDescriptor alloc] initWithKey:@"lastModifiedDate" ascending:NO];
    
    // Assign the sort descriptor to the fetch request
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortCategoriesByDate, nil]];
    
    // Combine the predicates if any were created
    if ((self.frcPredicateArray != nil) && (self.frcPredicateArray.count > 0))
    {
        [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:self.frcPredicateArray]];
    }
    
    NSString* cacheName = [NSString stringWithFormat:@"LinePlotCache%@", self.entityName];
    [NSFetchedResultsController deleteCacheWithName:cacheName];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"title" cacheName:cacheName];
    [_fetchedResultsController setDelegate:self];
    
    return _fetchedResultsController;
}

-(void)reloadAllCategoriesPlotData
{
    self.allCategoriesPlotLinePlotCntrl = [[spnLinePlot alloc] init];
    self.allCategoriesPlotLinePlotCntrl.delegate = self;
    self.allCategoriesPlotXYValues = [[NSMutableArray alloc] init];
    self.allCategoriesPlotXLabels = [[NSMutableArray alloc] init];
    
    [self updateSourceDataForLinePlot:self.allCategoriesPlotLinePlotCntrl atIndexPath:nil withValues:self.allCategoriesPlotXYValues withLabels:self.allCategoriesPlotXLabels];
}

-(void)reloadDataForPlot:(spnLinePlot*)plot atIndexPath:(NSIndexPath*)indexPath valuesToLoad:(NSMutableArray*)values labelsToLoad:(NSMutableArray*)labels
{
    [self updateSourceDataForLinePlot:plot atIndexPath:indexPath withValues:values withLabels:labels];
}

-(void)updateSourceDataForLinePlot:(spnLinePlot*)linePlot atIndexPath:(NSIndexPath*)indexPath withValues:(NSMutableArray*)values withLabels:(NSMutableArray*)labels
{
    spnTransactionFetchOp* fetchOperation;
    spnLineChartProcessDataOp* processDataOperation;
    
    // Need to create a week reference of self to avoid retain loop when accessing self within the block.
    __unsafe_unretained typeof(self) weakSelf = self;
    processDataOperation = [[spnLineChartProcessDataOp alloc] init];
    processDataOperation.transactionIDs = nil; // set in fetchOperation's completion block
    processDataOperation.persistentStoreCoordinator = [self.managedObjectContext persistentStoreCoordinator];
    processDataOperation.dataReturnBlock = ^(NSMutableArray* linePlotXYValues, NSMutableArray* linePlotXLabels) {
        
        [values removeAllObjects];
        [labels removeAllObjects];
        [values addObjectsFromArray:[[NSMutableArray alloc] initWithArray:linePlotXYValues copyItems:YES]];
        [labels addObjectsFromArray:[[NSMutableArray alloc] initWithArray:linePlotXLabels copyItems:YES]];
    };
    processDataOperation.completionBlock = ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (linePlot == weakSelf.allCategoriesPlotLinePlotCntrl)
            {
                if (labels.count > 0)
                {
                    // Retrieve pie chart image once data processing is complete
                    weakSelf.linePlotImage = [linePlot imageWithFrame:weakSelf.imageFrame];
                }
                else
                {
                    // Nothing to show
                    weakSelf.linePlotImage = nil;
                }
                
            }
            else
            {
                // Obtain the view in which to render the plot
                UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
                UIView* plotContainerView = [cell viewWithTag:CELL_CHART_TAG_PLOT];
                
                // Render the line plot
                UIImageView* imageView = [[UIImageView alloc] initWithImage:[linePlot imageWithFrame:plotContainerView.frame]];
                [plotContainerView addSubview:imageView];
                
                // Stop/hide the activity wheel
                UIActivityIndicatorView* activityView = (UIActivityIndicatorView*)[cell viewWithTag:CELL_CHART_TAG_ACTIVITY];
                [activityView stopAnimating];
            }
        });
    };
    
    fetchOperation = [[spnTransactionFetchOp alloc] init];
    fetchOperation.startDate = self.startDate;
    fetchOperation.endDate = self.endDate;
    fetchOperation.persistentStoreCoordinator = [self.managedObjectContext persistentStoreCoordinator];
    
    if (linePlot == weakSelf.allCategoriesPlotLinePlotCntrl)
    {
        fetchOperation.excludeCategories = self.excludeCategories;
        fetchOperation.includeCategories = self.includeCategories;
        fetchOperation.includeSubCategories = self.includeSubCategories;
    }
    else
    {
        id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[indexPath.section];
        
        fetchOperation.excludeCategories = nil;
        
        // Configure filter categories based on table type
        if (self.linePlotTableType == LINE_PLOT_TABLE_TYPE_CAT)
        {
            fetchOperation.includeCategories = [NSArray arrayWithObject:sectionInfo.name];
            fetchOperation.includeSubCategories = nil;
        }
        else if (self.linePlotTableType == LINE_PLOT_TABLE_TYPE_SUBCAT)
        {
            fetchOperation.includeCategories = nil;
            fetchOperation.includeSubCategories = [NSArray arrayWithObject:sectionInfo.name];
        }
        else
        {
            fetchOperation.includeCategories = nil;
            fetchOperation.includeSubCategories = nil;
        }
    }
    
    fetchOperation.dataReturnBlock = ^(NSMutableArray* objectIDs, NSError* error) {
        
        processDataOperation.transactionIDs = objectIDs;
    };
    
    // Process data operation depends on the fetch operation
    [processDataOperation addDependency:fetchOperation];
    
    // start the operations
    [self.queue addOperation:fetchOperation];
    [self.queue addOperation:processDataOperation];
}

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Load the specified data for the specified plot
    [self reloadDataForPlot:self.categoryLinePlots[indexPath.section] atIndexPath:indexPath valuesToLoad:self.categoriesPlotXYValues[indexPath.section] labelsToLoad:self.categoriesPlotXLabels[indexPath.section]];
    
    UILabel* textLabel = (UILabel*)[cell viewWithTag:CELL_CHART_TAG_LABEL];
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[indexPath.section];
    [textLabel setText:sectionInfo.name];
    
    // start activity wheel
    UIActivityIndicatorView* activityView = (UIActivityIndicatorView*)[cell viewWithTag:CELL_CHART_TAG_ACTIVITY];
    [activityView startAnimating];
}

// <UITableViewDataSource> methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"LinePlotCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];

        // Create text label
        UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 44.0)];
        textLabel.tag = CELL_CHART_TAG_LABEL;
        
        // Plot view
        UIView* linePlotView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44.0, self.tableView.bounds.size.width, LINE_PLOT_HEIGHT)];
        linePlotView.tag = CELL_CHART_TAG_PLOT;
        
        UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView setFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, [self tableView:self.tableView heightForRowAtIndexPath:indexPath])];
        [activityView setHidesWhenStopped:YES];
        activityView.tag = CELL_CHART_TAG_ACTIVITY;
        
        [cell addSubview:textLabel];
        [cell addSubview:linePlotView];
        [cell addSubview:activityView];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    // Configure cell contents
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
//        
//    return [sectionInfo name];
//}

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

//<UITableViewDelegate> methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    return 25;
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (LINE_PLOT_HEIGHT+44);
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
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:newIndexPath];
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

//<spnLinePlotDelegate> methods>
-(NSArray*)dataArrayForLinePlot:(spnLinePlot *)linePlot
{
    if (linePlot == self.allCategoriesPlotLinePlotCntrl)
    {
        return self.allCategoriesPlotXYValues;
    }
    else
    {
        NSInteger i = 0;
        for (spnLinePlot* plot in self.categoryLinePlots)
        {
            if (linePlot == plot)
            {
                return self.categoriesPlotXYValues[i];
            }
            i++;
        }
    }
    
    return nil; // shouldn't get here
}

-(NSArray*)xLabelArrayForLinePlot:(spnLinePlot *)linePlot
{
    if (linePlot == self.allCategoriesPlotLinePlotCntrl)
    {
        return self.allCategoriesPlotXLabels;
    }
    else
    {
        NSInteger i = 0;
        for (spnLinePlot* plot in self.categoryLinePlots)
        {
            if (linePlot == plot)
            {
                return self.categoriesPlotXLabels[i];
            }
            i++;
        }
    }
    
    return nil; // shouldn't get here
}




@end
