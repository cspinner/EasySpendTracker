//
//  spnTableViewController_LinePlot.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/7/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spnLinePlot.h"

@interface spnTableViewController_LinePlot : UITableViewController <spnLinePlotDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

typedef NS_ENUM(NSInteger, LinePlotTableType)
{
    LINE_PLOT_TABLE_TYPE_CAT,
    LINE_PLOT_TABLE_TYPE_SUBCAT
};

@property LinePlotTableType linePlotTableType;

@property spnLinePlot* allCategoriesPlotLinePlotCntrl;
@property NSDate* startDate;
@property NSDate* endDate;
@property NSArray* excludeCategories;
@property NSArray* includeCategories;
@property NSArray* includeSubCategories;

@property (nonatomic) NSManagedObjectContext* managedObjectContext;
@property NSString* entityName; // Must be "SpnCategoryMO" or "SpnSubCategoryMO"
@property NSMutableArray* frcPredicateArray; // Predicates for the table view's fetched results controller

@property CGRect imageFrame;
@property UIImage* linePlotImage;

-(NSFetchedResultsController*)fetchedResultsController;
-(void)reloadAllCategoriesPlotData;

@end
