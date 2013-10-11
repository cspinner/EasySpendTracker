//
//  spnCategoryCellView.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/29/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spnCategoryCellView : UITableViewCell

- (void)setName:(NSString*)name withTotal:(float)total forMonth:(NSString*)month withBudget:(float)budget;

@end
