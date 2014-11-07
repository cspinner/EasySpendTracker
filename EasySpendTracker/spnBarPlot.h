//
//  spnBarChart.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/21/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "PlotItem.h"

@class spnBarPlot;

@protocol spnBarPlotDelegate <NSObject>

@required
-(NSArray*)dataArrayForBarPlot:(spnBarPlot*)barPlot;
-(NSArray*)xLabelArrayForLinePlot:(spnBarPlot*)barPlot; // Array of NSStrings

@end


@interface spnBarPlot : PlotItem<CPTPlotSpaceDelegate, CPTPlotDataSource, CPTBarPlotDelegate>

-(id)initWithContext:(void *)context;

@property id<spnBarPlotDelegate> delegate;
@property void * context;

@end
