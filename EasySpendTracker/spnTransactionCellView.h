//
//  spnTransactionCellView.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/29/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spnTransactionCellView : UITableViewCell

@property UILabel* valueLabel;
@property UILabel* valueLabelLarge;
@property UILabel* merchantLabel;
@property UILabel* dateLabel;

- (void)setValue:(float)value withMerchant:(NSString*)merchant isIncome:(BOOL)isIncome onDate:(NSDate*)date;

@end
