//
//  spnTableViewController_BarPlot.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/21/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_BarPlot.h"
#import "UIViewController+addTransactionHandles.h"
#import "spnTransactionFetchOp.h"
#import "spnBarPlotProcessDataOp.h"
#import "iAd/iAd.h"
#import "spnInAppPurchaseManager.h"

@interface spnTableViewController_BarPlot ()

// the queue to run operations
@property (nonatomic, strong) NSOperationQueue* queue;
@property spnTransactionFetchOp* fetchOperation;
@property spnBarPlotProcessDataOp* processDataOperation;

@property NSArray* barPlotValues;
@property NSArray* barPlotMonths;

@end

@implementation spnTableViewController_BarPlot

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

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setCanDisplayBannerAds:![[spnInAppPurchaseManager sharedManager] productPurchased:spnInAppProduct_AdFreeUpgrade]];
}

- (void)reloadData
{
    self.cashFlowBarPlot = [[spnBarPlot alloc] init];
    self.cashFlowBarPlot.delegate = self;
    
    [self updateSourceDataForBarPlot:self.cashFlowBarPlot];
}

- (void)updateSourceDataForBarPlot:(spnBarPlot*)barPlot
{
    // Need to create a week reference of self to avoid retain loop when accessing self within the block.
    __unsafe_unretained typeof(self) weakSelf = self;
    self.processDataOperation = [[spnBarPlotProcessDataOp alloc] init];
    self.processDataOperation.transactionIDs = nil; // set in fetchOperation's completion block
    self.processDataOperation.persistentStoreCoordinator = [self.managedObjectContext persistentStoreCoordinator];
    self.processDataOperation.dataReturnBlock = ^(NSMutableArray* barPlotValues, NSMutableArray* barPlotMonths) {
        
        weakSelf.barPlotValues = [[NSMutableArray alloc] initWithArray:barPlotValues copyItems:YES];
        weakSelf.barPlotMonths = [[NSMutableArray alloc] initWithArray:barPlotMonths copyItems:YES];
    };
    self.processDataOperation.completionBlock = ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakSelf.barPlotMonths.count > 0)
            {
                // Retrieve pie chart image once data processing is complete
                weakSelf.barPlotImage = [barPlot imageWithFrame:weakSelf.imageFrame];
            }
            else
            {
                // Nothing to show
                weakSelf.barPlotImage = nil;
            }
        });
    };
    
    self.fetchOperation = [[spnTransactionFetchOp alloc] init];
    self.fetchOperation.startDate = self.startDate;
    self.fetchOperation.endDate = self.endDate;
    self.fetchOperation.persistentStoreCoordinator = [self.managedObjectContext persistentStoreCoordinator];
    self.fetchOperation.excludeCategories = nil; // excludes none
    self.fetchOperation.includeCategories = nil; // includes all
    self.fetchOperation.includeSubCategories = nil; // includes all
    self.fetchOperation.dataReturnBlock = ^(NSMutableArray* objectIDs, NSError* error) {
        
        weakSelf.processDataOperation.transactionIDs = objectIDs;
    };

    // Process data operation depends on the fetch operation
    [self.processDataOperation addDependency:self.fetchOperation];
    
    // start the operations
    [self.queue addOperation:self.fetchOperation];
    [self.queue addOperation:self.processDataOperation];
//    self.barPlotImage = [barPlot imageWithFrame:self.imageFrame];
}

//<spnBarPlotDelegate> methods
-(NSArray*)dataArrayForBarPlot:(spnBarPlot*)barPlot
{
    return self.barPlotValues;
}

-(NSArray*)xLabelArrayForLinePlot:(spnBarPlot*)barPlot
{
    return self.barPlotMonths;
}

@end
