//
//  SimplePieChart.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 8/14/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnPieChart.h"

@interface spnPieChart ()

@property NSArray *plotData;
@property NSArray *titleData;

@end

const NSArray* pieSliceFills;

@implementation spnPieChart

// call me
-(id)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Simple Pie Chart";
        self.section = @"Pie Charts";
        
        pieSliceFills = [NSArray arrayWithObjects:
                         // Dark Pastel Blue
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:119.0/255.0 green:158.0/255.0 blue:203.0/255.0 alpha:1.0]],
                         // Pastel Orange
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:255.0/255.0 green:179.0/255.0 blue:71.0/255.0 alpha:1.0]],
                         // Pastel Yellow
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:253.0/255.0 green:253.0/255.0 blue:150.0/255.0 alpha:1.0]],
                         // Dark Pastel Red
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:194.0/255.0 green:59.0/255.0 blue:34.0/255.0 alpha:1.0]],
                         // Pastel Magenta
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:244.0/255.0 green:154.0/255.0 blue:194.0/255.0 alpha:1.0]],
                         // Pastel Blue
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:174.0/255.0 green:198.0/255.0 blue:207.0/255.0 alpha:1.0]],
                         // Light Pastel Purple
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:100.0/255.0 green:20.0/255.0 blue:100.0/255.0 alpha:1.0]],
                         // Dark Pastel Purple
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:150.0/255.0 green:111.0/255.0 blue:214.0/255.0 alpha:1.0]],
                         // Pastel Purple
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:179.0/255.0 green:158.0/255.0 blue:181.0/255.0 alpha:1.0]],
                         // Pastel Pink
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:222.0/255.0 green:165.0/255.0 blue:164.0/255.0 alpha:1.0]],
                         // Pastel Brown
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:130.0/255.0 green:105.0/255.0 blue:83.0/255.0 alpha:1.0]],
                         // Dark Pastel Green
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:3.0/255.0 green:192.0/255.0 blue:60.0/255.0 alpha:1.0]],
                         // Pastel Red
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:255.0/255.0 green:105.0/255.0 blue:97.0/255.0 alpha:1.0]],
                         // Pastel Green
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:119.0/255.0 green:221.0/255.0 blue:119.0/255.0 alpha:1.0]],
                         // Pastel Gray
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:207.0/255.0 green:207.0/255.0 blue:196.0/255.0 alpha:1.0]],
                         // Pastel Violet
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:203.0/255.0 green:153.0/255.0 blue:201.0/255.0 alpha:1.0]],
                         // Pastel Pink2
                         [CPTFill fillWithColor:[CPTColor colorWithComponentRed:255.0/255.0 green:209.0/255.0 blue:220.0/255.0 alpha:1.0]],
                         nil];
            
    }

    return self;
}

-(id)initWithContext:(void *)context
{
    self = [self init];
    self.context = context;
    
    return self;
}

// called by super
-(void)generateData
{
    self.plotData = [self.delegate dataArrayForPieChart:self];
    self.titleData = [self.delegate titleArrayForPieChart:self];
}

// called by super
-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    CGRect bounds = layerHostingView.bounds;
    CGFloat plotAreaHeight = bounds.size.height;
    CGFloat plotAreaWidth = bounds.size.width / 2;

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    graph.plotAreaFrame.masksToBorder = NO;
    graph.axisSet = nil;
    graph.paddingBottom = 0.0;
    graph.paddingTop = 0.0;
    graph.paddingLeft = 0.0;
    graph.paddingRight = 0.0;
    graph.plotAreaFrame.borderLineStyle = nil;

    [self setTitleDefaultsForGraph:graph withBounds:bounds];

    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius  = MIN(0.9 * plotAreaHeight / 2.0,
                             0.9 * plotAreaWidth / 2.0);
    piePlot.identifier = self.title;
    piePlot.startAngle = M_PI_4;
    piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
    piePlot.centerAnchor = CGPointMake((plotAreaWidth / bounds.size.width) / 2, 0.5);

    piePlot.delegate = self;
    [graph addPlot:piePlot];

    // Add legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    theLegend.numberOfColumns = 1;
//    theLegend.numberOfRows = 4;
    theLegend.entryPaddingBottom = 0.0;
    theLegend.entryPaddingTop = 0.0;
    theLegend.entryPaddingLeft = 0.0;
    theLegend.entryPaddingRight = 0.0;
    theLegend.delegate = self;

    graph.legend = theLegend;
    graph.legendAnchor = CPTRectAnchorLeft;
    graph.legendDisplacement = CGPointMake(plotAreaWidth, 0.0);
}

//<CPTPieChartDelegate> methods
-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(pieChart:entryWasSelectedAtIndex:)])
    {
        [self.delegate pieChart:self entryWasSelectedAtIndex:index];
    }

    [self generateData];
    [plot reloadData];
}

//<CPTLegendDelegate> methods
-(void)legend:(CPTLegend *)legend legendEntryForPlot:(CPTPlot *)plot wasSelectedAtIndex:(NSUInteger)idx;
{
    if ([self.delegate respondsToSelector:@selector(pieChart:entryWasSelectedAtIndex:)])
    {
        [self.delegate pieChart:self entryWasSelectedAtIndex:idx];
    }
    
    [self generateData];
    [plot reloadData];
}

//<CPTPlotDataSource> methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.plotData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    return [self.plotData objectAtIndex:index];
}

//<CPTPieChartDataSource>> methods
-(NSString*)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    return [self.titleData objectAtIndex:idx];
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    if (idx < pieSliceFills.count)
    {
        return pieSliceFills[idx];
    }
    else
    {
        return nil; // use a default color
    }
}

@end
