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
@property UILabel* merchantLabel;
@property UILabel* dateLabel;
@property UILabel* descriptionLabel;

- (void)setValue:(float)value withMerchant:(NSString*)merchant onDate:(NSDate*)date withDescription:(NSString*)description;

@end
