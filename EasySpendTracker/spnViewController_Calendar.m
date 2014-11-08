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
#import "spnTransactionCellView.h"
#import "NSDate+Convenience.h"

@interface spnViewController_Calendar ()

// the queue to run operations
@property (nonatomic, strong) NSOperationQueue* queue;
@property spnTransactionFetchOp* fetchOperation;
@property NSArray* fetchedTransactionObjectIDs;

@end

@implementation spnViewController_Calendar

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Assign self as the datasource/delegate
    [self setDelegate:self];
    [self setDataSource:self];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Today", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(showAndSelectToday)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(spnAddButtonClicked:)];
    
    // Create the operation queue that will run any operations
    self.queue = [[NSOperationQueue alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.navigationBar.barTintColor = nil;
        self.navigationController.navigationBar.tintColor = nil;
    } else {
        self.navigationController.navigationBar.tintColor = nil;
    }
    self.navigationController.navigationBar.titleTextAttributes = nil;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

// Action handler for the navigation bar's left bar button item.
- (void)showAndSelectToday
{
    [self showAndSelectDate:[[NSDate date] cc_dateByMovingToBeginningOfDay]];
}

//<KalDataSource> methods
- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
    // Need to create a week reference of self to avoid retain loop when accessing self within the block.
    __unsafe_unretained typeof(self) weakSelf = self;
    
    self.fetchOperation = [[spnTransactionFetchOp alloc] init];
    self.fetchOperation.startDate = fromDate;
    self.fetchOperation.endDate = toDate;
    self.fetchOperation.persistentStoreCoordinator = [self.managedObjectContext persistentStoreCoordinator];
    self.fetchOperation.excludeCategories = nil; // excludes none
    self.fetchOperation.includeCategories = nil; // includes all
    self.fetchOperation.includeSubCategories = nil; // includes all
    self.fetchOperation.dataReturnBlock = ^(NSMutableArray* objectIDs, NSError* error) {
        
        weakSelf.fetchedTransactionObjectIDs = [NSArray arrayWithArray:objectIDs];
    };
    self.fetchOperation.completionBlock = ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [delegate loadedDataSource:weakSelf];
        });
    };
    
    // start the operations
    [self.queue addOperation:self.fetchOperation];
}

- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    return [[NSArray alloc] initWithObjects:[[[NSDate date] offsetDay:-5] cc_dateByMovingToBeginningOfDay], nil];
}

- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
//    *        This message will be sent to your dataSource every time
//    *        that the user taps a day on the calendar. You should respond
//    *        to this message by updating the list from which you vend
//    *        UITableViewCells.
//    *
//    *        If this message is received but the application data is not yet
//    *        ready, your code should do nothing.
}

- (void)removeAllItems
{
//    *        This message will be sent before loadItemsFromDate:toDate
//    *        as well as any time that Kal wants to clear the table view
//    *        beneath the calendar (for example, when switching between months).
//    *        You should respond to this message by removing all objects
//    *        from the list from which you vend UITableViewCells.
}

//<UITableViewDelegate> methods

//<UITableViewDataSource> methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (void)configureCell:(spnTransactionCellView*)cell withObject:(id)object
{
//    SpnTransaction* transaction = (NSManagedObjectID*)object;
    
    // Write cell contents
//    [cell setValue:transaction.value.floatValue withMerchant:[transaction merchant] onDate:[transaction date] withDescription:[transaction notes]];
    [cell setValue:5.0 withMerchant:@"Wegmans" onDate:[self selectedDate] withDescription:@"meh"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"CalendarEventCell";
    
    // Acquire reuse cell object from the table view
    spnTransactionCellView* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        // Create cell if reuse cell doesn't exist.
        cell = [[spnTransactionCellView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell withObject:nil];
    
    return cell;
}




@end
