//
//  spnCollectionContainerView.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 12/29/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnCollectionContainerView.h"
#import "spnCollectionViewCell.h"

@interface spnCollectionContainerView()

@property (nonatomic) UICollectionView* collectionView;

@end

static NSString* CellIdentifier = @"collectionViewCell";

int observeCollectionDataContext;

@implementation spnCollectionContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    // additional custom init goes here
//    self.backgroundColor = [UIColor greenColor];
    
    // initialize the collection view
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = frame.size;
    flowLayout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;

    // must tell the collection view how to create the corresponding view if one does not already exist.
    [self.collectionView registerClass:[spnCollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
    
    [self addSubview:self.collectionView];
    
    // get notifications whenever collectionData is changed
    [self addObserver:self forKeyPath:@"collectionData" options:(NSKeyValueObservingOptionNew) context:&observeCollectionDataContext];
    
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // collection data was modified
    if (context == &observeCollectionDataContext)
    {
        if (object == self.collectionData)
        {
            switch([(NSNumber*)[change objectForKey:NSKeyValueChangeKindKey] intValue])
            {
                // always reload the table
                case NSKeyValueChangeSetting:
                case NSKeyValueChangeReplacement:
                case NSKeyValueChangeInsertion:
                case NSKeyValueChangeRemoval:
                default:
                {
                    [self.collectionView setContentOffset:CGPointZero animated:NO];
                    [self.collectionView reloadData];
                }
                    break;
            }
        }
    }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionData.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    spnCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIView* aView = self.collectionData[indexPath.row];
    
    [cell.cellContainerView addSubview:aView];
//    NSLog(@"Indexpath: %@, data: %@", indexPath, self.collectionData[indexPath.row]);
    
    // Determine whether to show the LEFT accessory arrow
    if ((indexPath.section == 0) &&
        (indexPath.row == 0))
    {
        cell.accessoryViewLeft.alpha = 0.0;
    }
    else
    {
        cell.accessoryViewLeft.alpha = 1.0;
    }
    
    // Determine whether to show the RIGHT accessory arrow
    if ((indexPath.section == ([self numberOfSectionsInCollectionView:collectionView] - 1)) &&
        (indexPath.row == ([collectionView numberOfItemsInSection:indexPath.section] - 1)))
    {
        cell.accessoryViewRight.alpha = 0.0;
    }
    else
    {
        cell.accessoryViewRight.alpha = 1.0;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(collectionContainer:willDisplayEntryAtIndexPath:)])
    {
        [self.delegate collectionContainer:self willDisplayEntryAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(collectionContainer:didSelectEntryAtIndexPath:)])
    {
        [self.delegate collectionContainer:self didSelectEntryAtIndexPath:indexPath];
    }
}

// Methods for notification of selection/deselection and highlight/unhighlight events.
// The sequence of calls leading to selection from a user touch is:
//
// (when the touch begins)
// 1. -collectionView:shouldHighlightItemAtIndexPath:
// 2. -collectionView:didHighlightItemAtIndexPath:
//
// (when the touch lifts)
// 3. -collectionView:shouldSelectItemAtIndexPath: or -collectionView:shouldDeselectItemAtIndexPath:
// 4. -collectionView:didSelectItemAtIndexPath: or -collectionView:didDeselectItemAtIndexPath:
// 5. -collectionView:didUnhighlightItemAtIndexPath:
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath; // called when the user taps on an already-selected item in multi-select mode
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
//
//- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0);
//- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0);
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
//
//// These methods provide support for copy/paste actions on cells.
//// All three should be implemented if any are.
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;
//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;
//
//// support for custom transition layout
//- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout;

@end
