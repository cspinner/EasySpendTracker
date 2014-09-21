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
@property NSArray *titleData;

@end

BOOL isPreview;

@implementation spnLinePlot

// call me
-(id)init
{
    if ( (self = [super init]) )
    {
        isPreview = false;
        
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
//    self.titleData = [self.delegate titleArrayForPieChart:self];
    
//    if ( !self.plotData ) {
//        const NSTimeInterval oneDay = 24 * 60 * 60;
//        
//        // Add some data
//        NSMutableArray *newData = [NSMutableArray array];
//        
//        for ( NSUInteger i = 0; i < 5; i++ ) {
//            NSTimeInterval x = oneDay * i;
//            NSNumber *y      = @(1.2 * rand() / (double)RAND_MAX + 1.2);
//            
//            [newData addObject:
//             @{ @(CPTScatterPlotFieldX): @(x),
//                @(CPTScatterPlotFieldY): y }
//             ];
//            
//            self.plotData = newData;
//        }
//    }
}

// called by super
-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme forPreview:(BOOL)forPreview animated:(BOOL)animated
{
    isPreview = forPreview;
    
//    // If you make sure your dates are calculated at noon, you shouldn't have to
//    // worry about daylight savings. If you use midnight, you will have to adjust
//    // for daylight savings time.
//    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//    
//    [dateComponents setMonth:10];
//    [dateComponents setDay:29];
//    [dateComponents setYear:2009];
//    [dateComponents setHour:12];
//    [dateComponents setMinute:0];
//    [dateComponents setSecond:0];
//    
//    NSCalendar *gregorian = [[NSCalendar alloc]
//                             initWithCalendarIdentifier:NSGregorianCalendar];
//    
//    NSDate *refDate = [gregorian dateFromComponents:dateComponents];
//    
//    NSTimeInterval oneDay = 24 * 60 * 60;
    
    CGRect bounds = layerHostingView.bounds;
    
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    graph.plotAreaFrame.masksToBorder = NO;
    graph.paddingBottom = 0.0;
    graph.paddingTop = 0.0;
    graph.paddingLeft = 0.0;
    graph.paddingRight = 0.0;
    graph.plotAreaFrame.borderLineStyle = nil;
    
    [self setTitleDefaultsForGraph:graph withBounds:bounds];

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(30.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(40000.0)];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPTDecimalFromFloat(1.0);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    x.minorTicksPerInterval = 0;
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
//    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
//    timeFormatter.referenceDate = refDate;
//    x.labelFormatter            = timeFormatter;
    x.labelRotation = M_PI_4;
    
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPTDecimalFromDouble(10000.0);
    y.minorTicksPerInterval = 0;
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(10.0);
    
    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Date Plot";

    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 3.0;
    lineStyle.lineColor = [CPTColor blueColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    
}

//<CPTScatterPlotDelegate> methods


//<CPTPlotDataSource> methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.plotData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    // fieldEnum indicates either X or Y for each entry
    return self.plotData[index][@(fieldEnum)];
}

@end
