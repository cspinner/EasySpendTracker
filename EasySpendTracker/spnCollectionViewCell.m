//
//  spnCollectionViewCell.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 12/31/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnCollectionViewCell.h"
#import "spnUtils.h"

#define COLLECTION_VIEW_ACCESSORY_IMAGE_WIDTH 9.5
#define COLLECTION_VIEW_ACCESSORY_IMAGE_HEIGHT 12.0

@implementation spnCollectionViewCell

- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    
    if (self)
    {
        // Set up left accessory
        UIView* accessoryViewLeftContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, COLLECTION_VIEW_ACCESSORY_WIDTH, aRect.size.height)];
        accessoryViewLeftContainer.backgroundColor = [UIColor whiteColor];
        
        self.accessoryViewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(COLLECTION_VIEW_ACCESSORY_WIDTH/2, aRect.size.height/2-COLLECTION_VIEW_ACCESSORY_IMAGE_HEIGHT/2, COLLECTION_VIEW_ACCESSORY_IMAGE_WIDTH, COLLECTION_VIEW_ACCESSORY_IMAGE_HEIGHT)];
        self.accessoryViewLeft.image = [UIImage imageNamed:@"Kal.bundle/kal_left_arrow.png"];
        [accessoryViewLeftContainer addSubview:self.accessoryViewLeft];
        
        // Set up right accessory
        UIView* accessoryViewRightContainer = [[UIView alloc] initWithFrame:CGRectMake(aRect.size.width-COLLECTION_VIEW_ACCESSORY_WIDTH, 0, COLLECTION_VIEW_ACCESSORY_WIDTH, aRect.size.height)];
        
        self.accessoryViewRight = [[UIImageView alloc] initWithFrame:CGRectMake(COLLECTION_VIEW_ACCESSORY_WIDTH/2-COLLECTION_VIEW_ACCESSORY_IMAGE_WIDTH, aRect.size.height/2-COLLECTION_VIEW_ACCESSORY_IMAGE_HEIGHT/2, COLLECTION_VIEW_ACCESSORY_IMAGE_WIDTH, COLLECTION_VIEW_ACCESSORY_IMAGE_HEIGHT)];
        self.accessoryViewRight.image = [UIImage imageNamed:@"Kal.bundle/kal_right_arrow.png"];
        [accessoryViewRightContainer addSubview:self.accessoryViewRight];
        accessoryViewRightContainer.backgroundColor = [UIColor whiteColor];
        
        self.cellContainerView = [[UIView alloc] initWithFrame:CGRectMake(COLLECTION_VIEW_ACCESSORY_WIDTH, 0, aRect.size.width-COLLECTION_VIEW_ACCESSORY_WIDTH*2, aRect.size.height)];
//        NSLog(@"%@", self.cellContainerView);
        
        // Add container views to the cell
        [self addSubview:self.cellContainerView];
        [self addSubview:accessoryViewLeftContainer];
        [self addSubview:accessoryViewRightContainer];
    }
    
    return self;
}

- (void)prepareForReuse
{
    // Cleanup any subviews that were added so the cell can be reused
    [self.cellContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
