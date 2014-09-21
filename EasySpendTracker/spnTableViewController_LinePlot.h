//
//  spnTableViewController_LinePlot.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/7/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spnLinePlot.h"

@interface spnTableViewController_LinePlot : UITableViewController <spnLinePlotDelegate, UITableViewDataSource, UITableViewDelegate>

@property spnLinePlot* linePlotCntrl;
@property NSDate* startDate;
@property NSDate* endDate;
@property NSArray* excludeCategories;

@property (nonatomic) NSManagedObjectContext* managedObjectContext;

-(void)reloadData;
-(UIImage*)linePlotImageWithFrame:(CGRect)frame;

@end
