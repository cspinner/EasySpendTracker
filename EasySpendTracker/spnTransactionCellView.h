//
//  spnTransactionCellView.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/29/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spnTransactionCellView : UITableViewCell

- (void)setValue:(float)value withMerchant:(NSString*)merchant isIncome:(BOOL)isIncome;

@end
