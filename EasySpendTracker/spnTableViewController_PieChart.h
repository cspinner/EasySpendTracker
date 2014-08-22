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

@property spnPieChart* pieChartCntrl;
@property NSDate* startDate;
@property NSDate* endDate;
@property NSArray* excludeCategories;

@property (nonatomic) NSManagedObjectContext* managedObjectContext;

-(UIImage*)pieChartImage;

@end
