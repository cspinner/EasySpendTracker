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
        self.textLabel.font = [UIFont systemFontOfSize:14.0f];
        self.detailTextLabel.textColor = [UIColor blackColor];
        
        // Add chevron button
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    return self;
}

- (void)setValue:(float)value withMerchant:(NSString*)merchant isIncome:(BOOL)isIncome
{
    // Write cell contents
    self.detailTextLabel.text = merchant;

    if (isIncome)
    {
        self.textLabel.text = [NSString stringWithFormat:@"$%.2f", value];
        self.textLabel.textColor = [UIColor blackColor];
    }
    else
    {
        self.textLabel.text = [NSString stringWithFormat:@"($%.2f)", value];
        self.textLabel.textColor = [UIColor redColor];
    }
}

@end
