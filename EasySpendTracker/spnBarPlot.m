//
//  spnBarChart.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/21/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnBarPlot.h"

@interface spnBarPlot ()

@property NSArray *plotData;
@property NSArray *xLabelData;

@end

@implementation spnBarPlot

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
    if ( self.plotData == nil )
    {
        self.plotData = [self.delegate dataArrayForBarPlot:self];
    }
    
    if ( self.xLabelData == nil )
    {
        self.xLabelData = [self.delegate xLabelArrayForLinePlot:self];
    }
}

// called by super
-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme forPreview:(BOOL)forPreview animated:(BOOL)animated
{
    CGRect bounds = layerHostingView.bounds;
    
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    
    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    graph.plotAreaFrame.paddingLeft   = 0.0;
    graph.plotAreaFrame.paddingTop    = 0.0;
    graph.plotAreaFrame.paddingRight  = 0.0;
    graph.plotAreaFrame.paddingBottom = 40.0;
    graph.plotAreaFrame.masksToBorder  = NO;
    graph.plotAreaFrame.borderLineStyle = nil;
    
    // Create grid line styles
    CPTMutableLineStyle *majorTickLineStyle = [CPTMutableLineStyle lineStyle];
    majorTickLineStyle.lineWidth = 1.0;
    majorTickLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.75];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 1.0;
    minorGridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.0];
    
    // Create axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    {
        CPTMutableTextStyle* labelTextStyle = [[CPTMutableTextStyle alloc] init];
        UIFont* labelFont = [UIFont systemFontOfSize:12.0];
        labelTextStyle.fontName = labelFont.fontName;
        labelTextStyle.fontSize = labelFont.pointSize;
        labelTextStyle.textAlignment = CPTTextAlignmentCenter;
        
        NSMutableArray* customLabels = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i < self.plotData.count; i++)
        {
            NSString* labelText = [NSString stringWithFormat:@"%@\n$%.2f", self.xLabelData[i], [self.plotData[i] floatValue]];
            CPTAxisLabel* label = [[CPTAxisLabel alloc] initWithText:labelText textStyle:labelTextStyle];
            label.tickLocation = CPTDecimalFromDouble(i);
            label.offset = 20;
            [customLabels addObject:label];
        }
        
        x.axisLabels                  = [NSSet setWithArray:customLabels];
        x.majorIntervalLength         = CPTDecimalFromInteger(1);
        x.minorTicksPerInterval       = 0;
        x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(MIN([[self.plotData valueForKeyPath:@"@min.self"] integerValue], 0));
        x.axisLineStyle               = nil;
        x.majorTickLineStyle          = nil;
        x.minorTickLineStyle          = nil;
        x.labelFormatter              = nil;
        x.labelingPolicy              = CPTAxisLabelingPolicyNone;
    }
    
    CPTXYAxis *y = axisSet.yAxis;
    {
        y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
        y.preferredNumberOfMajorTicks = 8;
        y.majorGridLineStyle          = nil;
        y.minorGridLineStyle          = nil;
        y.axisLineStyle               = nil;
        y.majorTickLineStyle          = majorTickLineStyle;
        y.minorTickLineStyle          = nil;
        y.labelOffset                 = 10.0;
        y.labelRotation               = M_PI_2;
        y.labelingPolicy              = CPTAxisLabelingPolicyNone;
        y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0.0);
    }
    
    // Create a bar line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineWidth = 1.0;
    barLineStyle.lineColor = [CPTColor whiteColor];
    
    // Create bar plot
    CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
    barPlot.lineStyle         = barLineStyle;
    barPlot.barWidth          = CPTDecimalFromFloat(0.75f); // bar is 75% of the available space
    barPlot.barCornerRadius   = 14.0;
    barPlot.barsAreHorizontal = NO;
    barPlot.dataSource        = self;
    barPlot.identifier        = @"Bar Plot 1";
    
    [graph addPlot:barPlot];
    
    // Plot space
    CPTMutablePlotRange *barRange = [[barPlot plotRangeEnclosingBars] mutableCopy];
    [barRange expandRangeByFactor:CPTDecimalFromDouble(1.00)];
    
    // Determine y-axis min and max
    CGFloat dataMin = [[self.plotData valueForKeyPath:@"@min.self"] floatValue];
    CGFloat dataMax = [[self.plotData valueForKeyPath:@"@max.self"] floatValue];
    NSDecimal yMin;
    NSDecimal yLength;
    
    if (dataMin < 0.0)
    {
        yMin = CPTDecimalFromFloat(dataMin);
    }
    else
    {
        yMin = CPTDecimalFromFloat(0.0);
    }

    yLength = CPTDecimalFromFloat(fmaxf(dataMax, 0.0) + fabsf(fminf(dataMin, 0.0)));
    
    CPTXYPlotSpace *barPlotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    barPlotSpace.xRange = barRange;
    barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:yMin length:yLength];
}

//<CPTPlotDataSource> methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.plotData count];
}

-(NSArray *)numbersForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
{
    NSArray *nums = nil;
    
    switch ( fieldEnum )
    {
        case CPTBarPlotFieldBarLocation:
            nums = [NSMutableArray arrayWithCapacity:indexRange.length];
            for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ )
            {
                [(NSMutableArray *)nums addObject : @(i)];
            }
            break;
            
        case CPTBarPlotFieldBarTip:
            nums = [self.plotData objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
            break;
            
        default:
            break;
    }
    
    return nums;
}

-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index
{
    CPTColor *color = nil;

    if ([self.plotData[index] floatValue] >= 0.0)
    {
        // Pastel Green
        color = [CPTColor colorWithComponentRed:3.0/255.0 green:192.0/255.0 blue:60.0/255.0 alpha:1.0];
    }
    else
    {
        // Pastel Red
        color = [CPTColor colorWithComponentRed:255.0/255.0 green:105.0/255.0 blue:97.0/255.0 alpha:1.0];
    }
    
    return [CPTFill fillWithColor:color];
}

-(NSString *)legendTitleForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index
{
    return [NSString stringWithFormat:@"Bar %lu", (unsigned long)(index + 1)];
}

@end
