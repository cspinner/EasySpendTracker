//
//  SimplePieChart.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 8/14/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnPieChart.h"
#import "math.h"

@interface spnPieChart ()

@property NSArray *plotData;
@property NSArray *titleData;

@end

#define DegreesToRadians(DEG) (DEG*((M_PI)/180))

const NSArray* pieSliceFills;
BOOL isPreview;

@implementation spnPieChart

// call me
-(id)init
{
    if ( (self = [super init]) )
    {
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
    self.plotData = [self.delegate dataArrayForPieChart:self];
    self.titleData = [self.delegate titleArrayForPieChart:self];
}

// called by super
-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme forPreview:(BOOL)forPreview animated:(BOOL)animated
{
    isPreview = forPreview;
    
    CGRect bounds = layerHostingView.bounds;
    CGFloat plotAreaHeight = bounds.size.height;
    CGFloat plotAreaWidth = bounds.size.width;

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
    self.pieChart = [[CPTPieChart alloc] init];
    self.pieChart.dataSource = self;
    self.pieChart.pieRadius  = MIN(0.9 * plotAreaHeight / 2.0,
                                   0.9 * plotAreaWidth / 2.0);
    self.pieChart.identifier = self.title;
    self.pieChart.startAngle = 0.0;
    self.pieChart.sliceDirection = CPTPieDirectionCounterClockwise;
    
    if (forPreview == YES)
    {
        self.pieChart.centerAnchor = CGPointMake((1-0.97*(plotAreaWidth - self.pieChart.pieRadius)/plotAreaWidth), 0.97*(plotAreaHeight - self.pieChart.pieRadius)/plotAreaHeight);
    }
    else
    {
        self.pieChart.centerAnchor = CGPointMake(0.5, 0.97*(plotAreaHeight - self.pieChart.pieRadius)/plotAreaHeight);

        CABasicAnimation *animScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [animScale setDuration:0.5f];
        
        animScale.toValue = [NSNumber numberWithFloat:1.0f];
        animScale.fromValue = [NSNumber numberWithFloat:0.0f];
        animScale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animScale.removedOnCompletion = NO;
        animScale.fillMode = kCAFillModeForwards;
        
//        CABasicAnimation *animRotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        CABasicAnimation *animRotate = [CABasicAnimation animationWithKeyPath:@"startAngle"];
        [animRotate setDuration:1.0f];
        
        animRotate.toValue = [NSNumber numberWithFloat:0.0f];
        animRotate.fromValue = [NSNumber numberWithFloat:DegreesToRadians(360)];
        animRotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animRotate.removedOnCompletion = NO;
        animRotate.fillMode = kCAFillModeForwards;
        
        [self.pieChart addAnimation:animScale forKey:@"grow"];
        [self.pieChart addAnimation:animRotate forKey:@"rotate"];

    }
    
    self.pieChart.delegate = self;
    [graph addPlot:self.pieChart];

    // Add legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    
    if (forPreview == YES)
    {
        theLegend.numberOfColumns = 1;
        theLegend.entryPaddingBottom = 0.0;
        theLegend.entryPaddingTop = 0.0;
        theLegend.entryPaddingLeft = 0.0;
        theLegend.entryPaddingRight = 50.0;
        graph.legendAnchor = CPTRectAnchorRight;
    }
    else
    {
        theLegend.numberOfColumns = 2;
        theLegend.entryPaddingBottom = 0.0;
        theLegend.entryPaddingTop = 0.0;
        theLegend.entryPaddingLeft = 10.0;
        theLegend.entryPaddingRight = 0.0;
        graph.legendAnchor = CPTRectAnchorBottomLeft;
    }
    
    theLegend.delegate = self;

    graph.legend = theLegend;
    graph.legendDisplacement = CGPointMake(0.0, 0.0);
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
    
    if ([self.delegate respondsToSelector:@selector(pieChart:reloadedPlot:)])
    {
        [self.delegate pieChart:self reloadedPlot:plot];
    }
}

//<CPTLegendDelegate> methods
-(void)legend:(CPTLegend *)legend legendEntryForPlot:(CPTPieChart *)plot wasSelectedAtIndex:(NSUInteger)idx;
{
    if ([self.delegate respondsToSelector:@selector(pieChart:entryWasSelectedAtIndex:)])
    {
        [self.delegate pieChart:self entryWasSelectedAtIndex:idx];
    }
    
    [self generateData];
    [plot reloadData];
    
    if ([self.delegate respondsToSelector:@selector(pieChart:reloadedPlot:)])
    {
        [self.delegate pieChart:self reloadedPlot:plot];
    }
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
    // restrict so too many categories won't become unmanageable in a preview
    if (((idx < 4) && isPreview) || !isPreview)
    {
        NSString* title = [self.titleData objectAtIndex:idx];
        
        //truncate to 17 chars + ...
        if (title.length > 20)
        {
            NSString* truncatedTitle = [[self.titleData objectAtIndex:idx] substringToIndex:17];
            truncatedTitle = [truncatedTitle stringByAppendingString:@"..."];
            return truncatedTitle;
        }
        else
        {
            return title;
        }
    }
    else
    {
        return nil;
    }
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
