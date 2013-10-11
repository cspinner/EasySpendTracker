//
//  spnCategoryCellView.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/29/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnCategoryCellView.h"

@interface spnCategoryCellView()

    @property UILabel* categoryLabel;
    @property UILabel* totalMonthLabel;
    @property UILabel* budgetLabel;

@end

@implementation spnCategoryCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 120, 22)];
        self.totalMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 156, 22)];
        self.budgetLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 22, 156, 22)];
        
        // Set font colors of labels
        [self.categoryLabel setTextColor:[UIColor blueColor]];
        [self.totalMonthLabel setTextColor:[UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0]];
        [self.budgetLabel setTextColor:[UIColor blackColor]];
        
        // Set font
        [self.categoryLabel setFont:[UIFont systemFontOfSize:21.0]];
        [self.totalMonthLabel setFont:[UIFont systemFontOfSize:12.0]];
        [self.budgetLabel setFont:[UIFont systemFontOfSize:12.0]];
        
        // Adjust font size to fit width
        [self.categoryLabel setAdjustsFontSizeToFitWidth:YES];
        [self.totalMonthLabel setAdjustsFontSizeToFitWidth:YES];
        [self.budgetLabel setAdjustsFontSizeToFitWidth:YES];
        
        // Dollar amounts are right justified
        [self.totalMonthLabel setTextAlignment:NSTextAlignmentRight];
        [self.budgetLabel setTextAlignment:NSTextAlignmentRight];
        
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

- (void)setName:(NSString*)name withTotal:(float)total forMonth:(NSString*)month withBudget:(float)budget
{
    [self.categoryLabel setText:name];
    [self.totalMonthLabel setText:[NSString stringWithFormat:@"%@: $%.2f", month, total]];
    [self.budgetLabel setText:[NSString stringWithFormat:@"Budget: $%.2f", budget]];
    
    [self.contentView addSubview:self.categoryLabel];
    [self.contentView addSubview:self.totalMonthLabel];
    [self.contentView addSubview:self.budgetLabel];
}

@end
