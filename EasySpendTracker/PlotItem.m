//
//  PlotItem.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 8/14/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "PlotItem.h"

@implementation PlotItem

@synthesize defaultLayerHostingView;
@synthesize graphs;
@synthesize section;
@synthesize title;

-(id)init
{
    if ( (self = [super init]) )
    {
        defaultLayerHostingView = nil;
        graphs                  = [[NSMutableArray alloc] init];
        section                 = nil;
        title                   = nil;
    }

    return self;
}

-(void)addGraph:(CPTGraph *)graph toHostingView:(CPTGraphHostingView *)layerHostingView
{
    [graphs addObject:graph];

    if ( layerHostingView )
    {
        layerHostingView.hostedGraph = graph;
    }
}

-(void)addGraph:(CPTGraph *)graph
{
    [self addGraph:graph toHostingView:nil];
}

-(void)killGraph
{
    [[CPTAnimation sharedInstance] removeAllAnimationOperations];

    // Remove the CPTLayerHostingView
    if ( defaultLayerHostingView )
    {
        [defaultLayerHostingView removeFromSuperview];

        defaultLayerHostingView.hostedGraph = nil;
        defaultLayerHostingView = nil;
    }

    //cachedImage = nil;

    [graphs removeAllObjects];
}

-(void)dealloc
{
    [self killGraph];
}

// override to generate data for the plot if needed
-(void)generateData
{
}

-(void)setTitleDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds
{
    graph.title = self.title;
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color                = [CPTColor grayColor];
    textStyle.fontName             = @"Helvetica-Bold";
    textStyle.fontSize             = round( bounds.size.height / CPTFloat(20.0) );
    graph.titleTextStyle           = textStyle;
    graph.titleDisplacement        = CPTPointMake( 0.0, textStyle.fontSize * CPTFloat(1.5) );
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
}

-(void)setPaddingDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds
{
    CGFloat boundsPadding = round( bounds.size.width / CPTFloat(20.0) ); // Ensure that padding falls on an integral pixel

    graph.paddingLeft = boundsPadding;

    if ( graph.titleDisplacement.y > 0.0 ) {
        graph.paddingTop = graph.titleTextStyle.fontSize * 2.0;
    }
    else {
        graph.paddingTop = boundsPadding;
    }

    graph.paddingRight  = boundsPadding;
    graph.paddingBottom = boundsPadding;
}

//-(UIImage *)image
//{
//    if ( cachedImage == nil )
//    {
//        CGRect imageFrame = CGRectMake(0, 0, 400, 300);
//        UIView *imageView = [[UIView alloc] initWithFrame:imageFrame];
//        [imageView setOpaque:YES];
//        [imageView setUserInteractionEnabled:NO];
//
//        [self renderInView:imageView withTheme:nil animated:NO];
//
//        CGSize boundsSize = imageView.bounds.size;
//
//        UIGraphicsBeginImageContextWithOptions(boundsSize, YES, 0.0);
//
//        CGContextRef context = UIGraphicsGetCurrentContext();
//
//        CGContextSetAllowsAntialiasing(context, true);
//
//        for ( UIView *subView in imageView.subviews )
//        {
//            if ( [subView isKindOfClass:[CPTGraphHostingView class]] )
//            {
//                CPTGraphHostingView *hostingView = (CPTGraphHostingView *)subView;
//                CGRect frame                     = hostingView.frame;
//
//                CGContextSaveGState(context);
//
//                CGContextTranslateCTM(context, frame.origin.x, frame.origin.y + frame.size.height);
//                CGContextScaleCTM(context, 1.0, -1.0);
//                [hostingView.hostedGraph layoutAndRenderInContext:context];
//
//                CGContextRestoreGState(context);
//            }
//        }
//
//        CGContextSetAllowsAntialiasing(context, false);
//
//        cachedImage = UIGraphicsGetImageFromCurrentImageContext();
//
//        UIGraphicsEndImageContext();
//
//    }
//
//    return cachedImage;
//}

-(void)applyTheme:(CPTTheme *)theme toGraph:(CPTGraph *)graph withDefault:(CPTTheme *)defaultTheme
{
    if ( theme == nil )
    {
        [graph applyTheme:defaultTheme];
    }
    else if ( ![theme isKindOfClass:[NSNull class]] )
    {
        [graph applyTheme:theme];
    }
}

-(void)renderInView:(UIView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    [self killGraph];

    defaultLayerHostingView = [(CPTGraphHostingView *)[CPTGraphHostingView alloc] initWithFrame : hostingView.bounds];

    defaultLayerHostingView.collapsesLayers = NO;
    [defaultLayerHostingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

    [defaultLayerHostingView setAutoresizesSubviews:YES];

    [hostingView addSubview:defaultLayerHostingView];
    [self generateData];
    [self renderInLayer:defaultLayerHostingView withTheme:theme animated:animated];
}

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    NSLog(@"PlotItem:renderInLayer: Override me");
}

-(void)reloadData
{
    for ( CPTGraph *g in graphs )
    {
        [g reloadData];
    }
}


@end
