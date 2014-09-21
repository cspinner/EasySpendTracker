//
//  spnLinePlot.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/7/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "PlotItem.h"

@class spnLinePlot;

@protocol spnLinePlotDelegate <NSObject>

@required
-(NSArray*)dataArrayForLinePlot:(spnLinePlot*)linePlot; // Array of {CPTScatterPlotFieldX, CPTScatterPlotFieldY}
-(NSArray*)xLabelArrayForLinePlot:(spnLinePlot*)linePlot; // Array of NSStrings

//@optional
//-(void)pieChart:(spnPieChart*)pieChart entryWasSelectedAtIndex:(NSUInteger)idx;
//-(void)pieChart:(spnPieChart*)pieChart reloadedPlot:(CPTPieChart *)plot;

@end

@interface spnLinePlot : PlotItem <CPTPlotSpaceDelegate, CPTScatterPlotDelegate, CPTPlotDataSource>

-(id)initWithContext:(void *)context;

@property id<spnLinePlotDelegate> delegate;
@property void * context;
@property CPTScatterPlot* linePlot;

@end
