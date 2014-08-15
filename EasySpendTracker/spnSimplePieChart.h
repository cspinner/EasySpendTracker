//
//  SimplePieChart.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 8/14/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "PlotItem.h"

@interface spnSimplePieChart : PlotItem<CPTPlotSpaceDelegate,
                                     CPTPieChartDelegate,
                                     CPTLegendDelegate,
                                     CPTPlotDataSource>
{
    @private
    NSArray *plotData;
}

@end
