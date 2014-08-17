//
//  SimplePieChart.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 8/14/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "PlotItem.h"

@class spnPieChart;

@protocol spnPieChartDelegate <NSObject>

@required
-(NSArray*)dataArrayForPieChart:(spnPieChart*)pieChart; // Array of NSNumbers
-(NSArray*)titleArrayForPieChart:(spnPieChart*)pieChart; // Array of NSStrings

@optional
-(void)pieChart:(spnPieChart*)pieChart entryWasSelectedAtIndex:(NSUInteger)idx;

@end

@interface spnPieChart : PlotItem <CPTPlotSpaceDelegate, CPTPieChartDelegate, CPTLegendDelegate, CPTPlotDataSource>

-(id)initWithContext:(void *)context;

@property id<spnPieChartDelegate> delegate;
@property void * context;

@end

