//
//  spnTransactionCellView.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/29/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnTransactionCellView.h"

@implementation spnTransactionCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
        
        // Add chevron button
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    return self;
}

- (void)setValue:(float)value withMerchant:(NSString*)merchant isIncome:(BOOL)isIncome
{
    // Write cell contents
    self.textLabel.text = merchant;

    if (isIncome)
    {
        self.detailTextLabel.text = [NSString stringWithFormat:@"$%.2f", value];
        self.detailTextLabel.textColor = [UIColor blackColor];
    }
    else
    {
        self.detailTextLabel.text = [NSString stringWithFormat:@"($%.2f)", value];
        self.detailTextLabel.textColor = [UIColor redColor];
    }
}

@end
