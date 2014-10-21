//
//  spnLinePlot.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/7/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnLinePlot.h"

@interface spnLinePlot ()

@property NSArray *plotData;
@property NSArray *xLabelData;

@end

@implementation spnLinePlot

// call me
-(id)init
{
    if ( (self = [super init]) )
    {
  
    }
    
    return self;
}

-(id)initWithContext:(void *)context
{
    self = [self init];
    self.context = context;
    
    return self;
}

// called by self and super
-(void)generateData
{
    self.plotData = [self.delegate dataArrayForLinePlot:self];
    self.xLabelData = [self.delegate xLabelArrayForLinePlot:self];
}

// called by super
-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme forPreview:(BOOL)forPreview animated:(BOOL)animated
{
    CGRect bounds = layerHostingView.bounds;
    
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    graph.plotAreaFrame.masksToBorder = NO;
    graph.paddingBottom = 40.0; // Allows for X axis labels
    graph.paddingTop = 10.0;
    graph.paddingLeft = 70.0; // Allows for Y axis labels
    graph.paddingRight = 10.0;
    graph.plotAreaFrame.borderLineStyle = nil;
    
    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    
    // Extract Y points from the plot data
    NSMutableArray* YPoints = [[NSMutableArray alloc] init];
    for (NSArray* XYPoint in self.plotData)
    {
        [YPoints addObject:XYPoint[1]];
    }
    
    // Determine the maximum Y value for the plot
    CGFloat f32MaxY = [[YPoints valueForKeyPath:@"@max.self"] floatValue];
    CGFloat yMax = 100.0;
    BOOL maxFound = NO;
    while (!maxFound)
    {
        if ((f32MaxY - yMax) >= 0)
        {
            yMax *= 2.0;
        }
        else
        {
            maxFound = true;
        }
    }

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(self.xLabelData.count)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(yMax)];

    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    // Configure X Axis
    CPTXYAxis *x = axisSet.xAxis;
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    
    x.majorIntervalLength = CPTDecimalFromFloat(1.0);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    x.minorTicksPerInterval = 0;
    x.axisLineStyle = nil;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.majorTickLineStyle = tickLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelRotation = M_PI_4;

    NSMutableSet* axisLabels = [[NSMutableSet alloc] init];
    NSMutableSet* axisLabelLocs = [[NSMutableSet alloc] init];
    CPTMutableTextStyle* labelTextStyle = [[CPTMutableTextStyle alloc] init];
    UIFont* labelFont = [UIFont systemFontOfSize:12.0];
    labelTextStyle.fontName = labelFont.fontName;
    labelTextStyle.fontSize = labelFont.pointSize;
    NSInteger i = 0;
    for (NSString* labelText in self.xLabelData)
    {
        CGFloat location = i++;
        
        CPTAxisLabel* axisLabel = [[CPTAxisLabel alloc] initWithText:labelText textStyle:labelTextStyle];
        axisLabel.tickLocation = CPTDecimalFromCGFloat(location);
        axisLabel.offset = x.majorTickLength;
        [axisLabels addObject:axisLabel];
        [axisLabelLocs addObject:@(i)];
    }
    
    x.majorTickLocations = axisLabelLocs;
    x.axisLabels = axisLabels;

    
    
    // Configure Y Axis
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPTDecimalFromDouble(yMax/5);
    y.minorTicksPerInterval = 0;
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0.0);
    y.axisLineStyle = nil;
    y.labelTextStyle = labelTextStyle;
    y.majorTickLineStyle = tickLineStyle;
    y.majorTickLength = 4.0f;
    y.labelOffset = y.majorTickLength;//23.0f;
    y.tickDirection = CPTSignNegative;
    
    
    
    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Date Plot";

    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 2.0;
    lineStyle.lineColor = [CPTColor colorWithComponentRed:119.0/255.0 green:221.0/255.0 blue:119.0/255.0 alpha:1.0];
    
    dataSourceLinePlot.dataLineStyle = lineStyle;
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    
}


//<CPTPlotDataSource> methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.plotData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    // fieldEnum indicates either X or Y for each entry
    return self.plotData[index][fieldEnum];
}

@end
