//
//  spnCollectionContainerView.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 12/29/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spnCollectionViewCell.h"

@class spnCollectionContainerView;

@protocol spnCollectionContainerDelegate <NSObject>

@optional

- (void)collectionContainer:(spnCollectionContainerView*)collectionContainer didSelectEntryAtIndexPath:(NSIndexPath*)indexPath;
- (void)collectionContainer:(spnCollectionContainerView*)collectionContainer willDisplayEntryAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface spnCollectionContainerView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) NSMutableArray* collectionData; // Array of views (i.e. ImageViews)
@property id<spnCollectionContainerDelegate> delegate;

@end
