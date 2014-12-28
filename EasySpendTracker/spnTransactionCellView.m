//
//  spnTransactionCellView.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/29/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnTransactionCellView.h"
#import "spnUtils.h"

@implementation spnTransactionCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.merchantLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 11, 168, 20)];
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(194, 0, 92, 22)];
        self.valueLabelLarge = [[UILabel alloc] initWithFrame:CGRectMake(194, 11, 92, 20)];
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(194, 22, 92, 22)];
        
        // Set font colors of labels
        [self.merchantLabel setTextColor:[UIColor blackColor]];
        [self.valueLabel setTextColor:[UIColor blackColor]]; // Color could be overriden when set
        [self.valueLabelLarge setTextColor:[UIColor blackColor]]; // Color could be overriden when set
        [self.dateLabel setTextColor:[UIColor blackColor]];
        
        // Set font
        [self.merchantLabel setFont:[UIFont systemFontOfSize:13.0]];
        [self.valueLabel setFont:[UIFont systemFontOfSize:12.0]];
        [self.valueLabelLarge setFont:[UIFont systemFontOfSize:13.0]];
        [self.dateLabel setFont:[UIFont systemFontOfSize:12.0]];
        
        // Adjust font size to fit width settings
        [self.merchantLabel setAdjustsFontSizeToFitWidth:NO]; // managed by truncation
        [self.valueLabel setAdjustsFontSizeToFitWidth:YES];
        [self.valueLabelLarge setAdjustsFontSizeToFitWidth:YES];
        [self.dateLabel setAdjustsFontSizeToFitWidth:YES];
        
        // Dollar amounts and date are right justified
        [self.valueLabel setTextAlignment:NSTextAlignmentRight];
        [self.valueLabelLarge setTextAlignment:NSTextAlignmentRight];
        [self.dateLabel setTextAlignment:NSTextAlignmentRight];
        
        // Add chevron button
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    return self;
}

- (void)setValue:(float)value withMerchant:(NSString*)merchant isIncome:(BOOL)isIncome onDate:(NSDate*)date isRecurring:(BOOL)isRecurring
{
    NSString* valueString;
    UIColor* valueStringColor;
    
    if (isIncome)
    {
        valueString = [NSString stringWithFormat:@"$%.2f", value];
        valueStringColor = [UIColor blackColor];
    }
    else
    {
        valueString = [NSString stringWithFormat:@"($%.2f)", value];
        valueStringColor = [UIColor redColor];
    }
    
    // truncate merchant to 27 chars + ...
    if (merchant.length > 30)
    {
        NSString* truncatedMerchant = [merchant substringToIndex:27];
        truncatedMerchant = [truncatedMerchant stringByAppendingString:@"..."];
        merchant = truncatedMerchant;
    }
    
    [self.merchantLabel setText:merchant];
    [self.contentView addSubview:self.merchantLabel];
    
    // If a date was specified, then the date and value share the right side
    if (date != nil)
    {
        [self.dateLabel setText:[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]];
        [self.valueLabel setText:valueString];
        [self.valueLabel setTextColor:valueStringColor];
        
        [self.contentView addSubview:self.valueLabel];
        [self.contentView addSubview:self.dateLabel];
    }
    else
    {
        // no date specified - value is enlarged and is solo on the right side
        [self.valueLabelLarge setText:valueString];
        [self.valueLabelLarge setTextColor:valueStringColor];
        
        [self.contentView addSubview:self.valueLabelLarge];
    }
    
    // display recurring image if enabled
    if (isRecurring)
    {
        self.imageView.image = [[spnUtils sharedUtils] imageWithImage:[UIImage imageNamed:@"recurrence.png"] scaledToSize:CGSizeMake(20, 20)];
    }
    else
    {
        self.imageView.image = nil;
    }
}



@end
