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

    cachedImage = nil;

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
    graph.titleDisplacement        = CPTPointMake( 0.0, -80.0);
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
}

-(UIImage *)imageWithFrame:(CGRect)frame
{
    if ( cachedImage == nil )
    {
        CGRect imageFrame = frame;
        UIView *imageView = [[UIView alloc] initWithFrame:imageFrame];
        [imageView setOpaque:YES];
        [imageView setUserInteractionEnabled:NO];

        [self renderInView:imageView withTheme:nil forPreview:YES animated:NO];

        CGSize boundsSize = imageView.bounds.size;

        UIGraphicsBeginImageContextWithOptions(boundsSize, YES, 0.0);

        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetAllowsAntialiasing(context, true);

        for ( UIView *subView in imageView.subviews )
        {
            if ( [subView isKindOfClass:[CPTGraphHostingView class]] )
            {
                CPTGraphHostingView *hostingView = (CPTGraphHostingView *)subView;
                CGRect frame = hostingView.frame;

                CGContextSaveGState(context);

                CGContextTranslateCTM(context, frame.origin.x, frame.origin.y + frame.size.height);
                CGContextScaleCTM(context, 1.0, -1.0);
                [hostingView.hostedGraph layoutAndRenderInContext:context];

                CGContextRestoreGState(context);
            }
        }

        CGContextSetAllowsAntialiasing(context, false);

        cachedImage = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();

    }

    return cachedImage;
}

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

-(void)renderInView:(NSArray*)params
{
    [self renderInView:params[0] withTheme:params[1] forPreview:[params[2] boolValue] animated:[params[3] boolValue]];
}

-(void)renderInView:(UIView *)hostingView withTheme:(CPTTheme *)theme forPreview:(BOOL)forPreview animated:(BOOL)animated
{
    [self killGraph];

    defaultLayerHostingView = [(CPTGraphHostingView *)[CPTGraphHostingView alloc] initWithFrame : hostingView.bounds];

    defaultLayerHostingView.collapsesLayers = NO;
    [defaultLayerHostingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

    [defaultLayerHostingView setAutoresizesSubviews:YES];

    [hostingView addSubview:defaultLayerHostingView];
    [self generateData];
    [self renderInLayer:defaultLayerHostingView withTheme:theme forPreview:forPreview animated:animated];
}

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme forPreview:(BOOL)forPreview animated:(BOOL)animated
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
