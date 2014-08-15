//
//  SimplePieChart.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 8/14/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnSimplePieChart.h"

@implementation spnSimplePieChart

// call me
-(id)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Simple Pie Chart";
        self.section = @"Pie Charts";
    }

    return self;
}

// called by super
-(void)generateData
{
    if ( plotData == nil )
    {
        plotData = [[NSMutableArray alloc] initWithObjects:
                    [NSNumber numberWithDouble:20.0],
                    [NSNumber numberWithDouble:30.0],
                    [NSNumber numberWithDouble:60.0],
                    nil];
    }
}

// called by super
-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    CGRect bounds = layerHostingView.bounds;

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];

    graph.plotAreaFrame.masksToBorder = NO;
    graph.axisSet                     = nil;

    // Overlay gradient for pie chart
    CPTGradient *overlayGradient = [[CPTGradient alloc] init];
    overlayGradient.gradientType = CPTGradientTypeRadial;
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.0];
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.3] atPosition:0.9];
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.7] atPosition:1.0];

    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius  = MIN(0.7 * (layerHostingView.frame.size.height - 2 * graph.paddingLeft) / 2.0,
                             0.7 * (layerHostingView.frame.size.width - 2 * graph.paddingTop) / 2.0);
    piePlot.identifier     = self.title;
    piePlot.startAngle     = M_PI_4;
    piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
    piePlot.overlayFill    = [CPTFill fillWithGradient:overlayGradient];

    piePlot.labelRotationRelativeToRadius = YES;
    piePlot.labelRotation                 = -M_PI_2;
    piePlot.labelOffset                   = -50.0;

    piePlot.delegate = self;
    [graph addPlot:piePlot];

    // Add legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    theLegend.numberOfColumns = 1;
    theLegend.fill            = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegend.borderLineStyle = [CPTLineStyle lineStyle];

    theLegend.entryFill            = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
    theLegend.entryBorderLineStyle = [CPTLineStyle lineStyle];
    theLegend.entryCornerRadius    = CPTFloat(3.0);
    theLegend.entryPaddingLeft     = CPTFloat(3.0);
    theLegend.entryPaddingTop      = CPTFloat(3.0);
    theLegend.entryPaddingRight    = CPTFloat(3.0);
    theLegend.entryPaddingBottom   = CPTFloat(3.0);

    theLegend.cornerRadius = 5.0;
    theLegend.delegate     = self;

    graph.legend = theLegend;

    graph.legendAnchor       = CPTRectAnchorRight;
    graph.legendDisplacement = CGPointMake(-graph.paddingRight - 10.0, 0.0);
}

//<CPTPieChartDelegate> methods
-(void)plot:(CPTPlot *)plot dataLabelWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Data label for '%@' was selected at index %d.", plot.identifier, (int)index);
}

-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Slice was selected at index %d. Value = %f", (int)index, [[plotData objectAtIndex:index] floatValue]);

    NSMutableArray *newData = [[NSMutableArray alloc] init];
    NSUInteger dataCount    = ceil(10.0 * rand() / (double)RAND_MAX) + 1;
    for ( NSUInteger i = 1; i < dataCount; i++ )
    {
        [newData addObject:[NSNumber numberWithDouble:100.0 * rand() / (double)RAND_MAX]];
    }
    NSLog(@"newData: %@", newData);

    plotData = newData;

    [plot reloadData];
}

//<CPTLegendDelegate> methods
-(void)legend:(CPTLegend *)legend legendEntryForPlot:(CPTPlot *)plot wasSelectedAtIndex:(NSUInteger)idx;
{
    NSLog(@"Legend entry for '%@' was selected at index %lu.", plot.identifier, (unsigned long)idx);
}

//<CPTPlotDataSource> methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [plotData count];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTMutableTextStyle *whiteText = nil;
    
    if ( !whiteText )
    {
        whiteText       = [[CPTMutableTextStyle alloc] init];
        whiteText.color = [CPTColor whiteColor];
    }
    
    CPTTextLayer *newLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%1.0f", [[plotData objectAtIndex:index] floatValue]]
                                                          style:whiteText];
    return newLayer;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num;

    if ( fieldEnum == CPTPieChartFieldSliceWidth )
    {
        num = [plotData objectAtIndex:index];
    }
    else
    {
        return [NSNumber numberWithUnsignedInteger:index];
    }

    return num;
}

//<CPTPieChartDataSource>> methods
-(NSAttributedString *)attributedLegendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    UIColor *sliceColor = [CPTPieChart defaultPieSliceColorForIndex:index].uiColor;

    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Pie Slice %lu", (unsigned long)index]];
    if ( &NSForegroundColorAttributeName != NULL )
    {
        [title addAttribute:NSForegroundColorAttributeName
                      value:sliceColor
                      range:NSMakeRange(4, 5)];
    }

    return title;
}

@end
