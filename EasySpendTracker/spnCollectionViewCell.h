//
//  spnCollectionViewCell.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 12/31/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

#define COLLECTION_VIEW_ACCESSORY_WIDTH 15.0

@interface spnCollectionViewCell : UICollectionViewCell

@property UIView* cellContainerView; // container view meant to hold subviews added by collection view
@property UIImageView* accessoryViewLeft;
@property UIImageView* accessoryViewRight;

@end
