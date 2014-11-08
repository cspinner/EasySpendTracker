//
//  PlotItem.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 8/14/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@class CPTGraph;
@class CPTTheme;

@interface PlotItem : NSObject
{
    @private
    CPTGraphHostingView *defaultLayerHostingView;

    NSMutableArray *graphs;
    NSString *title;
    UIImage *cachedImage;
}

@property (nonatomic, retain) CPTGraphHostingView *defaultLayerHostingView;
@property (nonatomic, retain) NSMutableArray *graphs;
@property (nonatomic, retain) NSString *section;
@property (nonatomic, retain) NSString *title;

-(void)renderInView:(UIView *)hostingView withTheme:(CPTTheme *)theme forPreview:(BOOL)forPreview animated:(BOOL)animated;
-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme forPreview:(BOOL)forPreview animated:(BOOL)animated;

-(UIImage *)imageWithFrame:(CGRect)frame;

-(void)setTitleDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds;

-(void)reloadData;
-(void)applyTheme:(CPTTheme *)theme toGraph:(CPTGraph *)graph withDefault:(CPTTheme *)defaultTheme;

-(void)addGraph:(CPTGraph *)graph;
-(void)addGraph:(CPTGraph *)graph toHostingView:(CPTGraphHostingView *)layerHostingView;
-(void)killGraph;

-(void)generateData;


@end
