//
//  spnTableViewController_PieChart.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 8/17/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spnPieChart.h"

@interface spnTableViewController_PieChart : UITableViewController <spnPieChartDelegate, UITableViewDataSource, UITableViewDelegate>

#define LEGEND_AREA_HEIGHT(X) ((X/2)*24.0)

enum
{
    PIECHART_TABLE_TEXT_ROW,
    PIECHART_TABLE_PLOT_ROW,
    PIECHART_TABLE_ROW_COUNT
};


@property spnPieChart* pieChartCntrl;
@property NSDate* startDate;
@property NSDate* endDate;
@property NSArray* excludeCategories;

// These two are sorted together
@property NSArray* pieChartValues;
@property NSArray* pieChartNames;

@property (nonatomic) NSManagedObjectContext* managedObjectContext;

@property CGRect imageFrame;
@property UIImage* pieChartImage;

-(void)reloadData;


@end
