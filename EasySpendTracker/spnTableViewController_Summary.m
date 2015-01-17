//
//  spnTableViewController_Summary.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 8/22/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Summary.h"
#import "UIViewController+addTransactionHandles.h"
#import "SpnTransaction.h"
#import "SpnCategory.h"
#import "SpnSubCategory.h"
#import "spnTableViewController_PieChart_Cat.h"
#import "spnTableViewController_LinePlot_Cat.h"
#import "spnTableViewController_PieChart_Mer.h"
#import "spnTableViewController_BarPlot.h"
#import "spnCollectionContainerView.h"
#import "spnTableViewController_InAppUpgrade.h"
#import "NSDate+Convenience.h"
#import "iAd/iAd.h"
#import "spnInAppPurchaseManager.h"

@interface spnTableViewController_Summary ()

@property spnTableViewController_BarPlot* barPlotCashFlowByMonth;
@property spnTableViewController_PieChart_Cat* pieChartTableThisMonthExpenses;
@property spnTableViewController_PieChart_Cat* pieChartTableThisMonthIncome;
@property spnTableViewController_PieChart_Cat* pieChartTableAllTimeExpenses;
@property spnTableViewController_PieChart_Cat* pieChartTableAllTimeIncome;
@property spnTableViewController_PieChart_Mer* pieChartTableThisMonthExpMerchants;
@property spnTableViewController_PieChart_Mer* pieChartTableThisMonthIncMerchants;
@property spnTableViewController_PieChart_Mer* pieChartTableAllTimeExpMerchants;
@property spnTableViewController_PieChart_Mer* pieChartTableAllTimeIncMerchants;
@property spnTableViewController_LinePlot_Cat* linePlotAllExpenses;
@property spnTableViewController_LinePlot_Cat* linePlotAllIncome;

@property spnCollectionContainerView* containerViewThisMonthPies;
@property spnCollectionContainerView* containerViewAllTimePies;
@property spnCollectionContainerView* containerViewAllTimeLines;

@property NSArray* chartImageDefaults;
@property NSMutableArray* chartImageCache;

@end

#define BAR_PLOT_HEIGHT (self.tableView.bounds.size.width * 0.625)
#define PIE_CHART_HEIGHT (self.tableView.bounds.size.width * 0.3125)
#define LINE_PLOT_HEIGHT (self.tableView.bounds.size.width * 0.625)

#define CASH_FLOW_IMAGE_FRAME CGRectMake(0, 0, self.tableView.bounds.size.width, BAR_PLOT_HEIGHT)
#define PIE_CHART_IMAGE_FRAME CGRectMake(0, 0, self.tableView.bounds.size.width-COLLECTION_VIEW_ACCESSORY_WIDTH*2, PIE_CHART_HEIGHT)
#define LINE_PLOT_IMAGE_FRAME CGRectMake(0, 0, self.tableView.bounds.size.width-COLLECTION_VIEW_ACCESSORY_WIDTH*2, LINE_PLOT_HEIGHT)

enum
{
    ROW_CASH_FLOW,
    ROW_THIS_MONTH_COLLECTON,
    ROW_ALL_TIME_COLLECTION,
    ROW_LINE_COLLECTION,
    ROW_COUNT
};

enum
{
    CELL_CHART_TAG_LABEL = 1,
    CELL_CHART_TAG_CONTENT_CACHED,
    CELL_CHART_TAG_CONTENT,
    CELL_CHART_TAG_ACTIVITY
};

enum
{
    COLL_VIEW_IDX_PIE_EXPENSE,
    COLL_VIEW_IDX_PIE_EXP_MERCHANT,
    COLL_VIEW_IDX_PIE_INCOME,
    COLL_VIEW_IDX_PIE_INC_MERCHANT,
    COLL_VIEW_IDX_PIE_COUNT
};

enum
{
    COLL_VIEW_IDX_LINE_EXPENSE,
    COLL_VIEW_IDX_LINE_INCOME,
    COLL_VIEW_IDX_LINE_COUNT
};

int observeChartPreviewContext;

@implementation spnTableViewController_Summary

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
    
    self.chartImageDefaults = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"Empty_Bar_Plot"], [UIImage imageNamed:@"Empty_Pie_Chart"], [UIImage imageNamed:@"Empty_Pie_Chart"], [UIImage imageNamed:@"Empty_Line_Plot"], nil];
    self.chartImageCache = [[NSMutableArray alloc] initWithArray:self.chartImageDefaults copyItems:YES];
    
    [self initCharts];
}

- (void)removeAdsClicked
{
    spnTableViewController_InAppUpgrade* inAppUpgradeViewController = [[spnTableViewController_InAppUpgrade alloc] initWithStyle:UITableViewStyleGrouped];
    

    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style:self.navigationItem.backBarButtonItem.style
                                    target:nil
                                    action:nil];
    
    // Present the view
    [[self navigationController] pushViewController:inAppUpgradeViewController animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[spnInAppPurchaseManager sharedManager] productPurchased:spnInAppProduct_AdFreeUpgrade])
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"remove_ads"] style:UIBarButtonItemStylePlain target:self action:@selector(removeAdsClicked)];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setCanDisplayBannerAds:![[spnInAppPurchaseManager sharedManager] productPurchased:spnInAppProduct_AdFreeUpgrade]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initCharts
{
    NSDate* firstDayOfNextMonth = [[NSDate dateStartOfMonth:[NSDate date]] offsetMonth:1];
    
    NSError* error;
    NSFetchRequest* nonIncomeCategoryFetch = [[NSFetchRequest alloc] initWithEntityName:@"SpnCategoryMO"];
    nonIncomeCategoryFetch.predicate = [NSPredicate predicateWithFormat:@"NOT(title MATCHES[cd] %@)", @"Income"];
    NSArray* nonIncomeCategories = [self.managedObjectContext executeFetchRequest:nonIncomeCategoryFetch error:&error];
    NSArray* nonIncomeCategoryTitles = [nonIncomeCategories valueForKeyPath:@"@distinctUnionOfObjects.title"];
    
    // Last 4 month's cash flow
    self.barPlotCashFlowByMonth = [[spnTableViewController_BarPlot alloc] initWithStyle:UITableViewStyleGrouped];
    self.barPlotCashFlowByMonth.title = @"Cash Flow";
    self.barPlotCashFlowByMonth.startDate = [[NSDate dateStartOfMonth:[NSDate date]] offsetMonth:-3];
    self.barPlotCashFlowByMonth.endDate = firstDayOfNextMonth;
    self.barPlotCashFlowByMonth.managedObjectContext = self.managedObjectContext;
    [self.barPlotCashFlowByMonth addObserver:self forKeyPath:@"barPlotImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // This Month - Expenses
    self.pieChartTableThisMonthExpenses = [[spnTableViewController_PieChart_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableThisMonthExpenses.title = @"This Month's Expenses";
    self.pieChartTableThisMonthExpenses.startDate = [NSDate dateStartOfMonth:[NSDate date]];
    self.pieChartTableThisMonthExpenses.endDate = firstDayOfNextMonth;
    self.pieChartTableThisMonthExpenses.excludeCategories = @[@"Income"];
    self.pieChartTableThisMonthExpenses.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableThisMonthExpenses addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // This Month - Expense Merchants
    self.pieChartTableThisMonthExpMerchants = [[spnTableViewController_PieChart_Mer alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableThisMonthExpMerchants.title = @"This Month's Merchants";
    self.pieChartTableThisMonthExpMerchants.startDate = [NSDate dateStartOfMonth:[NSDate date]];
    self.pieChartTableThisMonthExpMerchants.endDate = firstDayOfNextMonth;
    self.pieChartTableThisMonthExpMerchants.excludeCategories = @[@"Income"];
    self.pieChartTableThisMonthExpMerchants.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableThisMonthExpMerchants addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // This Month - Income
    self.pieChartTableThisMonthIncome = [[spnTableViewController_PieChart_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableThisMonthIncome.title = @"This Month's Income";
    self.pieChartTableThisMonthIncome.startDate = [NSDate dateStartOfMonth:[NSDate date]];
    self.pieChartTableThisMonthIncome.endDate = firstDayOfNextMonth;
    self.pieChartTableThisMonthIncome.excludeCategories = nonIncomeCategoryTitles;
    self.pieChartTableThisMonthIncome.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableThisMonthIncome addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // This Month - Income Sources
    self.pieChartTableThisMonthIncMerchants = [[spnTableViewController_PieChart_Mer alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableThisMonthIncMerchants.title = @"This Month's Income";
    self.pieChartTableThisMonthIncMerchants.startDate = [NSDate dateStartOfMonth:[NSDate date]];
    self.pieChartTableThisMonthIncMerchants.endDate = firstDayOfNextMonth;
    self.pieChartTableThisMonthIncMerchants.excludeCategories = nonIncomeCategoryTitles;
    self.pieChartTableThisMonthIncMerchants.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableThisMonthIncMerchants addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    
    
    // All Time - Expenses
    self.pieChartTableAllTimeExpenses = [[spnTableViewController_PieChart_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableAllTimeExpenses.title = @"All Time Expenses";
    self.pieChartTableAllTimeExpenses.startDate = nil;
    self.pieChartTableAllTimeExpenses.endDate = firstDayOfNextMonth;
    self.pieChartTableAllTimeExpenses.excludeCategories = @[@"Income"];
    self.pieChartTableAllTimeExpenses.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableAllTimeExpenses addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // All Time - Expense Merchants
    self.pieChartTableAllTimeExpMerchants = [[spnTableViewController_PieChart_Mer alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableAllTimeExpMerchants.title = @"All Time Merchants";
    self.pieChartTableAllTimeExpMerchants.startDate = nil;
    self.pieChartTableAllTimeExpMerchants.endDate = firstDayOfNextMonth;
    self.pieChartTableAllTimeExpMerchants.excludeCategories = @[@"Income"];
    self.pieChartTableAllTimeExpMerchants.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableAllTimeExpMerchants addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // All Time - Income
    self.pieChartTableAllTimeIncome = [[spnTableViewController_PieChart_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableAllTimeIncome.title = @"All Time Income";
    self.pieChartTableAllTimeIncome.startDate = nil;
    self.pieChartTableAllTimeIncome.endDate = firstDayOfNextMonth;
    self.pieChartTableAllTimeIncome.excludeCategories = nonIncomeCategoryTitles;
    self.pieChartTableAllTimeIncome.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableAllTimeIncome addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // All Time - Income Sources
    self.pieChartTableAllTimeIncMerchants = [[spnTableViewController_PieChart_Mer alloc] initWithStyle:UITableViewStyleGrouped];
    self.pieChartTableAllTimeIncMerchants.title = @"All Time Income";
    self.pieChartTableAllTimeIncMerchants.startDate = nil;
    self.pieChartTableAllTimeIncMerchants.endDate = firstDayOfNextMonth;
    self.pieChartTableAllTimeIncMerchants.excludeCategories = nonIncomeCategoryTitles;
    self.pieChartTableAllTimeIncMerchants.managedObjectContext = self.managedObjectContext;
    [self.pieChartTableAllTimeIncMerchants addObserver:self forKeyPath:@"pieChartImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // Line Plot - Expense
    self.linePlotAllExpenses = [[spnTableViewController_LinePlot_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.linePlotAllExpenses.title = @"Spending - Last 12 Months";
    self.linePlotAllExpenses.startDate = [[NSDate dateStartOfMonth:[NSDate date]] offsetYear:-1];
    self.linePlotAllExpenses.endDate = firstDayOfNextMonth;
    self.linePlotAllExpenses.excludeCategories = @[@"Income"];
    self.linePlotAllExpenses.includeCategories = nil;
    self.linePlotAllExpenses.managedObjectContext = self.managedObjectContext;
    self.linePlotAllExpenses.entityName = @"SpnCategoryMO";
    [self.linePlotAllExpenses addObserver:self forKeyPath:@"linePlotImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
    
    // Line Plot - Income
    self.linePlotAllIncome = [[spnTableViewController_LinePlot_Cat alloc] initWithStyle:UITableViewStyleGrouped];
    self.linePlotAllIncome.title = @"Income - Last 12 Months";
    self.linePlotAllIncome.startDate = [[NSDate dateStartOfMonth:[NSDate date]] offsetYear:-1];
    self.linePlotAllIncome.endDate = firstDayOfNextMonth;
    self.linePlotAllIncome.excludeCategories = nonIncomeCategoryTitles;
    self.linePlotAllIncome.includeCategories = nil;
    self.linePlotAllIncome.managedObjectContext = self.managedObjectContext;
    self.linePlotAllIncome.entityName = @"SpnCategoryMO";
    [self.linePlotAllIncome addObserver:self forKeyPath:@"linePlotImage" options:(NSKeyValueObservingOptionNew) context:&observeChartPreviewContext];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &observeChartPreviewContext)
    {
        UITableViewCell* cell;
        UIImage* previewImage;
        NSInteger row = 0;
        NSInteger collectionViewCellIndex = 0;
        
        if (object == self.barPlotCashFlowByMonth)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_CASH_FLOW inSection:0]];
                    previewImage = self.barPlotCashFlowByMonth.barPlotImage;
                    row = ROW_CASH_FLOW;
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.pieChartTableThisMonthExpenses)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_THIS_MONTH_COLLECTON inSection:0]];
                    previewImage = self.pieChartTableThisMonthExpenses.pieChartImage;
                    row = ROW_THIS_MONTH_COLLECTON;
                    collectionViewCellIndex = COLL_VIEW_IDX_PIE_EXPENSE;
//                    NSLog(@"Observe pieChartTableThisMonthExpenses, %lu",  collectionViewCellIndex);
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.pieChartTableThisMonthExpMerchants)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_THIS_MONTH_COLLECTON inSection:0]];
                    previewImage = self.pieChartTableThisMonthExpMerchants.pieChartImage;
                    row = ROW_THIS_MONTH_COLLECTON;
                    collectionViewCellIndex = COLL_VIEW_IDX_PIE_EXP_MERCHANT;
//                    NSLog(@"Observe pieChartTableThisMonthExpMerchants, %lu",  collectionViewCellIndex);
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.pieChartTableThisMonthIncome)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_THIS_MONTH_COLLECTON inSection:0]];
                    previewImage = self.pieChartTableThisMonthIncome.pieChartImage;
                    row = ROW_THIS_MONTH_COLLECTON;
                    collectionViewCellIndex = COLL_VIEW_IDX_PIE_INCOME;
//                    NSLog(@"Observe pieChartTableThisMonthIncome, %lu",  collectionViewCellIndex);
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.pieChartTableThisMonthIncMerchants)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_THIS_MONTH_COLLECTON inSection:0]];
                    previewImage = self.pieChartTableThisMonthIncMerchants.pieChartImage;
                    row = ROW_THIS_MONTH_COLLECTON;
                    collectionViewCellIndex = COLL_VIEW_IDX_PIE_INC_MERCHANT;
//                    NSLog(@"Observe pieChartTableThisMonthIncMerchants, %lu",  collectionViewCellIndex);
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.pieChartTableAllTimeExpenses)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_ALL_TIME_COLLECTION inSection:0]];
                    previewImage = self.pieChartTableAllTimeExpenses.pieChartImage;
                    row = ROW_ALL_TIME_COLLECTION;
                    collectionViewCellIndex = COLL_VIEW_IDX_PIE_EXPENSE;
//                    NSLog(@"Observe pieChartTableAllTimeExpenses, %lu",  collectionViewCellIndex);
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.pieChartTableAllTimeExpMerchants)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_ALL_TIME_COLLECTION inSection:0]];
                    previewImage = self.pieChartTableAllTimeExpMerchants.pieChartImage;
                    row = ROW_ALL_TIME_COLLECTION;
                    collectionViewCellIndex = COLL_VIEW_IDX_PIE_EXP_MERCHANT;
//                    NSLog(@"Observe pieChartTableAllTimeExpMerchants, %lu",  collectionViewCellIndex);
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.pieChartTableAllTimeIncome)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_ALL_TIME_COLLECTION inSection:0]];
                    previewImage = self.pieChartTableAllTimeIncome.pieChartImage;
                    row = ROW_ALL_TIME_COLLECTION;
                    collectionViewCellIndex = COLL_VIEW_IDX_PIE_INCOME;
//                    NSLog(@"Observe pieChartTableAllTimeIncome, %lu",  collectionViewCellIndex);
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.pieChartTableAllTimeIncMerchants)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_ALL_TIME_COLLECTION inSection:0]];
                    previewImage = self.pieChartTableAllTimeIncMerchants.pieChartImage;
                    row = ROW_ALL_TIME_COLLECTION;
                    collectionViewCellIndex = COLL_VIEW_IDX_PIE_INC_MERCHANT;
//                    NSLog(@"Observe pieChartTableAllTimeIncMerchants, %lu",  collectionViewCellIndex);
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.linePlotAllExpenses)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_LINE_COLLECTION inSection:0]];
                    previewImage = self.linePlotAllExpenses.linePlotImage;
                    row = ROW_LINE_COLLECTION;
                    collectionViewCellIndex = COLL_VIEW_IDX_LINE_EXPENSE;
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        else if (object == self.linePlotAllIncome)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                case NSKeyValueChangeSetting:
                {
                    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_LINE_COLLECTION inSection:0]];
                    previewImage = self.linePlotAllIncome.linePlotImage;
                    row = ROW_LINE_COLLECTION;
                    collectionViewCellIndex = COLL_VIEW_IDX_LINE_INCOME;
                }
                    break;
                    
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                    break;
            }
        }
        
        if ([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeSetting)
        {
            UIView* mainView;
            
            // If the preview image wasn't updated
            if (previewImage == nil)
            {
                // The preview image would be nil if there are no transactions to draw an image. For this case, just use the canned image.
                previewImage = self.chartImageDefaults[row];
                self.chartImageCache[row] = previewImage;
            }
            
            // get imageContainerView => cachedImageView
            UIImageView* cachedImageView = (UIImageView*)[cell viewWithTag:CELL_CHART_TAG_CONTENT_CACHED];
            cachedImageView.alpha = 1.0;
            
            if (row == ROW_CASH_FLOW)
            {
                // get imageContainerView => imageView
                UIImageView* imageView = (UIImageView*)[cell viewWithTag:CELL_CHART_TAG_CONTENT];
                imageView.image = previewImage;
                imageView.alpha = 0.0;
                mainView = imageView;
            }
            else
            {
                spnCollectionContainerView* containerView = (spnCollectionContainerView*)[cell viewWithTag:CELL_CHART_TAG_CONTENT];
                UIImageView* imageView = containerView.collectionData[collectionViewCellIndex];
                imageView.image = previewImage;
                mainView = containerView;
            }
            
            // fancy image fade in with cached image fade out
            [UIView animateWithDuration:0.5 animations:^(void){
                // Fade in the new image
                mainView.alpha = 1.0;
                
            } completion:^(BOOL finished){
                // Next fade out the old image
                if (finished)
                {
                    [UIView animateWithDuration:0.5 animations:^(void){
                        
                        cachedImageView.alpha = 0.0;
                    }];
                }
            }];
            
            // Stop spinning wheel animation now that image is loaded
            UIActivityIndicatorView* activityView = (UIActivityIndicatorView*)[cell viewWithTag:CELL_CHART_TAG_ACTIVITY];
            [activityView stopAnimating];
            
            // save the image to the cache
            self.chartImageCache[row] = previewImage;
        }
    }
    
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Depending on the row, we might need to load a chart:
    
    // Assign cached image first:
    switch (indexPath.row)
    {
        case ROW_CASH_FLOW:
        {
            // get imageContainerView => imageView
            UIImageView* cachedImageView = (UIImageView*)[cell viewWithTag:CELL_CHART_TAG_CONTENT_CACHED];
            
            // assign the previously obtained chart preview to the cell
            cachedImageView.image = self.chartImageCache[indexPath.row];
            cachedImageView.alpha = 1.0;
            
            UIActivityIndicatorView* activityView = (UIActivityIndicatorView*)[cell viewWithTag:CELL_CHART_TAG_ACTIVITY];
            [activityView startAnimating];
        }
            break;
            
        case ROW_THIS_MONTH_COLLECTON:
        case ROW_ALL_TIME_COLLECTION:
        {
            // get collection container view
            spnCollectionContainerView* containerView = (spnCollectionContainerView*)[cell viewWithTag:CELL_CHART_TAG_CONTENT];
            containerView.delegate = self;
            
            if (containerView.collectionData == nil)
            {
//                NSLog(@"Configure. New collection. row: %ld", (long)indexPath.row);
                containerView.collectionData = [[NSMutableArray alloc] init];
                
                for (NSInteger i = 0; i < COLL_VIEW_IDX_PIE_COUNT; i++)
                {
                    UIImageView* imageView = [[UIImageView alloc] initWithFrame:PIE_CHART_IMAGE_FRAME];
                    imageView.image = self.chartImageCache[indexPath.row];
                    imageView.alpha = 1.0;
                    
//                    NSLog(@"Add containerView.collectionData addObject[%ld]", i);
                    [containerView.collectionData addObject:imageView];
                }
            }
            
            // get imageContainerView => imageView
            UIImageView* cachedImageView = (UIImageView*)[cell viewWithTag:CELL_CHART_TAG_CONTENT_CACHED];
            
            // assign the previously obtained chart preview to the cell
            cachedImageView.image = self.chartImageCache[indexPath.row];
            cachedImageView.alpha = 1.0;
            
            UIActivityIndicatorView* activityView = (UIActivityIndicatorView*)[cell viewWithTag:CELL_CHART_TAG_ACTIVITY];
            [activityView startAnimating];
        }
            break;
            
        case ROW_LINE_COLLECTION:
        {
            // get collection container view
            spnCollectionContainerView* containerView = (spnCollectionContainerView*)[cell viewWithTag:CELL_CHART_TAG_CONTENT];
            containerView.delegate = self;
            
            if (containerView.collectionData == nil)
            {
                //                NSLog(@"Configure. New collection. row: %ld", (long)indexPath.row);
                containerView.collectionData = [[NSMutableArray alloc] init];
                
                for (NSInteger i = 0; i < COLL_VIEW_IDX_LINE_COUNT; i++)
                {
                    UIImageView* imageView = [[UIImageView alloc] initWithFrame:LINE_PLOT_IMAGE_FRAME];
                    imageView.image = self.chartImageCache[indexPath.row];
                    imageView.alpha = 1.0;
                    
                    //                    NSLog(@"Add containerView.collectionData addObject[%ld]", i);
                    [containerView.collectionData addObject:imageView];
                }
            }
            
            // get imageContainerView => imageView
            UIImageView* cachedImageView = (UIImageView*)[cell viewWithTag:CELL_CHART_TAG_CONTENT_CACHED];
            
            // assign the previously obtained chart preview to the cell
            cachedImageView.image = self.chartImageCache[indexPath.row];
            cachedImageView.alpha = 1.0;
            
            UIActivityIndicatorView* activityView = (UIActivityIndicatorView*)[cell viewWithTag:CELL_CHART_TAG_ACTIVITY];
            [activityView startAnimating];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* reuseIdentifier = [NSArray arrayWithObjects:@"barPlotCell", @"pieChartCell", @"pieChartCell", @"linePlotCell", nil];
    
    // Must be in the same order as row enum
    NSArray* headerText = @[@"CASH FLOW",
                            @"THIS MONTH",
                            @"ALL TIME",
                            @"LAST 12 MONTHS"];
    
    UITableViewCell* cell = (UITableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier[indexPath.row]];
    
    if (cell == nil)
    {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.row]];
        
        switch (indexPath.row)
        {
            case ROW_CASH_FLOW:
            {
                // Create text label
                UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 25.0)];
                textLabel.tag = CELL_CHART_TAG_LABEL;
                
                // Gather chart preview container
                UIImageView* cachedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, BAR_PLOT_HEIGHT)];
                cachedImageView.tag = CELL_CHART_TAG_CONTENT_CACHED;
                
                UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, BAR_PLOT_HEIGHT)];
                imageView.tag = CELL_CHART_TAG_CONTENT;
                
                UIView* imageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 25.0, self.tableView.bounds.size.width, imageView.frame.size.height)];
                [imageContainerView addSubview:cachedImageView];
                [imageContainerView addSubview:imageView];
                
                UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [activityView setFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, [self tableView:self.tableView heightForRowAtIndexPath:indexPath])];
                [activityView setHidesWhenStopped:YES];
                activityView.tag = CELL_CHART_TAG_ACTIVITY;
                
                [cell addSubview:textLabel];
                [cell addSubview:imageContainerView];
                [cell addSubview:activityView];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
                break;

            case ROW_THIS_MONTH_COLLECTON:
            case ROW_ALL_TIME_COLLECTION:
            {
                // Create text label
                UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 25.0)];
                textLabel.tag = CELL_CHART_TAG_LABEL;
                
                // Gather chart preview container
                UIImageView* cachedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width-COLLECTION_VIEW_ACCESSORY_WIDTH*2, PIE_CHART_HEIGHT)];
                cachedImageView.tag = CELL_CHART_TAG_CONTENT_CACHED;

                spnCollectionContainerView* collectionContainerView = [[spnCollectionContainerView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, PIE_CHART_HEIGHT)];
                collectionContainerView.tag = CELL_CHART_TAG_CONTENT;
                
                if (indexPath.row == ROW_THIS_MONTH_COLLECTON)
                {
                    self.containerViewThisMonthPies = collectionContainerView;
                }
                else
                {
                    self.containerViewAllTimePies = collectionContainerView;
                }
                
                UIView* imageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 25.0, self.tableView.bounds.size.width, PIE_CHART_HEIGHT)];
                [imageContainerView addSubview:cachedImageView];
                [imageContainerView addSubview:collectionContainerView];
                
                UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [activityView setFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, [self tableView:self.tableView heightForRowAtIndexPath:indexPath])];
                [activityView setHidesWhenStopped:YES];
                activityView.tag = CELL_CHART_TAG_ACTIVITY;
                
                [cell addSubview:textLabel];
                [cell addSubview:imageContainerView];
                [cell addSubview:activityView];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
                break;
                
            case ROW_LINE_COLLECTION:
            {
                // Create text label
                UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width, 25.0)];
                textLabel.tag = CELL_CHART_TAG_LABEL;
                
                // Gather chart preview container
                UIImageView* cachedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, LINE_PLOT_HEIGHT)];
                cachedImageView.tag = CELL_CHART_TAG_CONTENT_CACHED;
                
                spnCollectionContainerView* collectionContainerView = [[spnCollectionContainerView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, LINE_PLOT_HEIGHT)];
                collectionContainerView.tag = CELL_CHART_TAG_CONTENT;
                
                self.containerViewAllTimeLines = collectionContainerView;
                
                UIView* imageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 25.0, self.tableView.bounds.size.width, LINE_PLOT_HEIGHT)];
                [imageContainerView addSubview:cachedImageView];
                [imageContainerView addSubview:collectionContainerView];
                
                UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [activityView setFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, [self tableView:self.tableView heightForRowAtIndexPath:indexPath])];
                [activityView setHidesWhenStopped:YES];
                activityView.tag = CELL_CHART_TAG_ACTIVITY;
                
                [cell addSubview:textLabel];
                [cell addSubview:imageContainerView];
                [cell addSubview:activityView];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
                break;


                
            default:
                break;
        }
        
        // Set text label based on section index
        UILabel* headerLabel = (UILabel*)[cell viewWithTag:CELL_CHART_TAG_LABEL];
        [headerLabel setText:headerText[indexPath.row]];
        [headerLabel setFont:[UIFont systemFontOfSize:12]];
        [headerLabel setTextColor:[UIColor grayColor]];
    }
    
    // Configure cell contents
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ROW_COUNT;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now's the time to command the chart view to generate the preview image.
    // The delay is allow the cell to become visible before the the image preview observer is triggered
    #define PERFORM_RELOAD_DELAY 0.001
    
    switch (indexPath.row)
    {
        case ROW_CASH_FLOW:
        {
            self.barPlotCashFlowByMonth.imageFrame = CASH_FLOW_IMAGE_FRAME;
            [self.barPlotCashFlowByMonth performSelector:@selector(reloadData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
        }
            break;
            
        case ROW_THIS_MONTH_COLLECTON:
        {
            self.pieChartTableThisMonthExpenses.imageFrame = PIE_CHART_IMAGE_FRAME;
            [self.pieChartTableThisMonthExpenses performSelector:@selector(reloadData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
            
            self.pieChartTableThisMonthExpMerchants.imageFrame = PIE_CHART_IMAGE_FRAME;
            [self.pieChartTableThisMonthExpMerchants performSelector:@selector(reloadData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
            
            self.pieChartTableThisMonthIncome.imageFrame = PIE_CHART_IMAGE_FRAME;
            [self.pieChartTableThisMonthIncome performSelector:@selector(reloadData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
            
            self.pieChartTableThisMonthIncMerchants.imageFrame = PIE_CHART_IMAGE_FRAME;
            [self.pieChartTableThisMonthIncMerchants performSelector:@selector(reloadData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
            
//            NSLog(@"ROW_THIS_MONTH_COLLECTON - reloadData");
        }
            break;
            
        case ROW_ALL_TIME_COLLECTION:
        {
            self.pieChartTableAllTimeExpenses.imageFrame = PIE_CHART_IMAGE_FRAME;
            [self.pieChartTableAllTimeExpenses performSelector:@selector(reloadData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
            
            self.pieChartTableAllTimeExpMerchants.imageFrame = PIE_CHART_IMAGE_FRAME;
            [self.pieChartTableAllTimeExpMerchants performSelector:@selector(reloadData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
            
            self.pieChartTableAllTimeIncome.imageFrame = PIE_CHART_IMAGE_FRAME;
            [self.pieChartTableAllTimeIncome performSelector:@selector(reloadData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
            
            self.pieChartTableAllTimeIncMerchants.imageFrame = PIE_CHART_IMAGE_FRAME;
            [self.pieChartTableAllTimeIncMerchants performSelector:@selector(reloadData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
            
//            NSLog(@"ROW_ALL_TIME_COLLECTION - reloadData");

        }
            break;

        case ROW_LINE_COLLECTION:
        {
            self.linePlotAllExpenses.imageFrame = LINE_PLOT_IMAGE_FRAME;
            [self.linePlotAllExpenses performSelector:@selector(reloadAllCategoriesPlotData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
            
            self.linePlotAllIncome.imageFrame = LINE_PLOT_IMAGE_FRAME;
            [self.linePlotAllIncome performSelector:@selector(reloadAllCategoriesPlotData) withObject:nil afterDelay:PERFORM_RELOAD_DELAY];
        }
            break;

        default:
            break;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Must be in the same order as row enums
    NSArray* rowHeight = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:BAR_PLOT_HEIGHT+25],
                          [NSNumber numberWithFloat:PIE_CHART_HEIGHT+25],
                          [NSNumber numberWithFloat:PIE_CHART_HEIGHT+25],
                          [NSNumber numberWithFloat:LINE_PLOT_HEIGHT+25],
                          nil];
    
    return (CGFloat)[rowHeight[indexPath.row] floatValue];
}

#pragma mark - spnCollectionContainerDelegate methods

- (void)collectionContainer:(spnCollectionContainerView *)collectionContainer willDisplayEntryAtIndexPath:(NSIndexPath *)indexPath
{
    // These sust be in the same order as row enums for the collection
    NSArray* thisMonthPieHeaderText = @[@"THIS MONTH - EXPENSES",
                                        @"THIS MONTH - MERCHANTS",
                                        @"THIS MONTH - INCOME",
                                        @"THIS MONTH - INCOME SOURCES"];
    
    NSArray* allTimePieHeaderText = @[@"ALL TIME - EXPENSES",
                                      @"ALL TIME - EXPENSE MERCHANTS",
                                      @"ALL TIME - INCOME",
                                      @"ALL TIME - INCOME SOURCES"];
    
    NSArray* twelveMonthLineHeaderText = @[@"LAST 12 MONTHS - EXPENSES",
                                           @"LAST 12 MONTHS - INCOME"];

    // This month pie charts
    if (collectionContainer == self.containerViewThisMonthPies)
    {
        UILabel* headerLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_THIS_MONTH_COLLECTON inSection:0]] viewWithTag:CELL_CHART_TAG_LABEL];
        headerLabel.text = thisMonthPieHeaderText[indexPath.row];
//        headerLabel.backgroundColor = [ UIColor grayColor];
    }
    
    // All time pie charts
    if (collectionContainer == self.containerViewAllTimePies)
    {
        UILabel* headerLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_ALL_TIME_COLLECTION inSection:0]] viewWithTag:CELL_CHART_TAG_LABEL];
        headerLabel.text = allTimePieHeaderText[indexPath.row];
//        headerLabel.backgroundColor = [ UIColor grayColor];
    }
    
    // Line plots
    if (collectionContainer == self.containerViewAllTimeLines)
    {
        UILabel* headerLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_LINE_COLLECTION inSection:0]] viewWithTag:CELL_CHART_TAG_LABEL];
        headerLabel.text = twelveMonthLineHeaderText[indexPath.row];
//        headerLabel.backgroundColor = [ UIColor grayColor];
    }
}

- (void)collectionContainer:(spnCollectionContainerView*)collectionContainer didSelectEntryAtIndexPath:(NSIndexPath*)indexPath
{
//    NSLog(@"view: %@, sec: %ld, row: %ld", collectionContainer, indexPath.section, indexPath.row);
    
    // This month pie charts
    if (collectionContainer == self.containerViewThisMonthPies)
    {
        switch (indexPath.row)
        {
            case COLL_VIEW_IDX_PIE_EXPENSE:
                [[self navigationController] pushViewController:self.pieChartTableThisMonthExpenses animated:YES];
                break;
                
            case COLL_VIEW_IDX_PIE_EXP_MERCHANT:
                [[self navigationController] pushViewController:self.pieChartTableThisMonthExpMerchants animated:YES];
                break;
                
            case COLL_VIEW_IDX_PIE_INCOME:
                [[self navigationController] pushViewController:self.pieChartTableThisMonthIncome animated:YES];
                break;
                
            case COLL_VIEW_IDX_PIE_INC_MERCHANT:
                [[self navigationController] pushViewController:self.pieChartTableThisMonthIncMerchants animated:YES];
                break;
 
            default:
                break;
        }
    }
    
    // All time pie charts
    if (collectionContainer == self.containerViewAllTimePies)
    {
        switch (indexPath.row)
        {
            case COLL_VIEW_IDX_PIE_EXPENSE:
                [[self navigationController] pushViewController:self.pieChartTableAllTimeExpenses animated:YES];
                break;
                
            case COLL_VIEW_IDX_PIE_EXP_MERCHANT:
                [[self navigationController] pushViewController:self.pieChartTableAllTimeExpMerchants animated:YES];
                break;
                
            case COLL_VIEW_IDX_PIE_INCOME:
                [[self navigationController] pushViewController:self.pieChartTableAllTimeIncome animated:YES];
                break;
                
            case COLL_VIEW_IDX_PIE_INC_MERCHANT:
                [[self navigationController] pushViewController:self.pieChartTableAllTimeIncMerchants animated:YES];
                break;
                
            default:
                break;
        }
    }
    
    // Line plots
    if (collectionContainer == self.containerViewAllTimeLines)
    {
        switch (indexPath.row)
        {
            case COLL_VIEW_IDX_LINE_EXPENSE:
                [[self navigationController] pushViewController:self.linePlotAllExpenses animated:YES];
                break;
                
            case COLL_VIEW_IDX_LINE_INCOME:
                [[self navigationController] pushViewController:self.linePlotAllIncome animated:YES];
                break;
                
            default:
                break;
        }
    }

}



@end
