//
//  spnTableViewController_BarPlot.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/21/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spnBarPlot.h"

@interface spnTableViewController_BarPlot : UITableViewController <spnBarPlotDelegate>

@property spnBarPlot* cashFlowBarPlot;

@property NSDate* startDate;
@property NSDate* endDate;

@property (nonatomic) NSManagedObjectContext* managedObjectContext;

@property CGRect imageFrame;
@property UIImage* barPlotImage;

- (void)reloadData;

@end
