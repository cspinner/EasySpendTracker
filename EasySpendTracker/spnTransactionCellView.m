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
        self.merchantLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 156, 26)];
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 26, 156, 18)];
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(156, 0, 120, 22)];
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(156, 22, 120, 22)];
        
        // Set font colors of labels
        [self.merchantLabel setTextColor:[UIColor blueColor]];
        [self.descriptionLabel setTextColor:[UIColor grayColor]];
        [self.valueLabel setTextColor:[UIColor blackColor]];
        [self.dateLabel setTextColor:[UIColor blackColor]];
        
        // Set font
        [self.merchantLabel setFont:[UIFont systemFontOfSize:18.0]];
        [self.descriptionLabel setFont:[UIFont systemFontOfSize:10.0]];
        [self.valueLabel setFont:[UIFont systemFontOfSize:12.0]];
        [self.dateLabel setFont:[UIFont systemFontOfSize:12.0]];
        
        // Adjust font size to fit width
        [self.merchantLabel setAdjustsFontSizeToFitWidth:YES];
        [self.descriptionLabel setAdjustsFontSizeToFitWidth:NO];
        [self.valueLabel setAdjustsFontSizeToFitWidth:YES];
        [self.dateLabel setAdjustsFontSizeToFitWidth:YES];
        
        // Dollar amounts and date are right justified
        [self.valueLabel setTextAlignment:NSTextAlignmentRight];
        [self.dateLabel setTextAlignment:NSTextAlignmentRight];
        
        // Add chevron button
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setValue:(float)value withMerchant:(NSString*)merchant onDate:(NSDate*)date withDescription:(NSString*)description
{
    [self.valueLabel setText:[NSString stringWithFormat:@"$%.2f", value]];
    [self.merchantLabel setText:merchant];
    [self.dateLabel setText:[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]];
    [self.descriptionLabel setText:description];
    
    [self.contentView addSubview:self.valueLabel];
    [self.contentView addSubview:self.merchantLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.descriptionLabel];
    
}

@end
