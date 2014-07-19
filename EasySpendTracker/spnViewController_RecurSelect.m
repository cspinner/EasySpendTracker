//
//  spnViewController_Recur.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/2/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnViewController_RecurSelect.h"
#import "UIView+spnViewCtgy.h"

@interface spnViewController_RecurSelect ()

@property NSDateComponents* frequency;

@property NSNumber* basis;
@property NSString* strFrequency;
@property BOOL seriesDoesExist;

@end

@implementation spnViewController_RecurSelect

// table sections
enum
{
    BASIS_SECTION_IDX,
    FREQ_SECTION_IDX,
    NUM_SECTIONS
};

// text field tags
enum
{
    BASIS_VIEW_TAG = 1,
    FREQ_VIEW_TAG
};

// picker row indexes
enum
{
    BLANK_PICKER_ROW,
    DAYS_PICKER_ROW,
    WEEKS_PICKER_ROW,
    MONTHS_PICKER_ROW,
    YEARS_PICKER_ROW,
    NUM_PICKER_ROWS
};

NSArray* strFreqArray;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Taps outside active text views/fields dismiss the keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self.view
                                   action:@selector(dismissKeyboard)];
    
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Add done and cancel buttons
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];
    
    // Set frequency picker rows
    strFreqArray = [NSArray arrayWithObjects:
                     @"",
                     @"Days",
                     @"Weeks",
                     @"Months",
                     @"Years",
                     nil];

    // Retrieve frequency from the delegate
    if ([self.delegate respondsToSelector:@selector(recurGetFrequency)])
    {
        self.frequency = [self.delegate recurGetFrequency];
        
        // Derive local properties from the fetched frequency
        if (self.frequency)
        {
            [self parseFrequency];
            self.seriesDoesExist = YES;
        }
        else
        {
            // none retrieved, set defaults and allocate frequency object
            self.seriesDoesExist = NO;
            self.basis = [NSNumber numberWithInteger:1];
            self.strFrequency = @"Weeks";
            
            self.frequency = [[NSDateComponents alloc] init];
        }
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)parseFrequency
{
    if (self.frequency.day > 0)
    {
        self.basis = [NSNumber numberWithInteger:self.frequency.day];
        self.strFrequency = strFreqArray[DAYS_PICKER_ROW];
    }
    else if (self.frequency.week > 0)
    {
        self.basis = [NSNumber numberWithInteger:self.frequency.week];
        self.strFrequency = strFreqArray[WEEKS_PICKER_ROW];
    }
    else if (self.frequency.month > 0)
    {
        self.basis = [NSNumber numberWithInteger:self.frequency.month];
        self.strFrequency = strFreqArray[MONTHS_PICKER_ROW];
    }
    else if (self.frequency.year > 0)
    {
        self.basis = [NSNumber numberWithInteger:self.frequency.year];
        self.strFrequency = strFreqArray[YEARS_PICKER_ROW];
    }
    else
    {
        // Default to 1 / week
        self.basis = [NSNumber numberWithInteger:1];
        self.strFrequency = strFreqArray[WEEKS_PICKER_ROW];
    }
}

- (void)updateFrequency
{
    // First reinitialize the frequence structure
    //[self.frequency setEra:0];
    [self.frequency setYear:0];
    [self.frequency setMonth:0];
    [self.frequency setDay:0];
    [self.frequency setHour:0];
    [self.frequency setMinute:0];
    [self.frequency setSecond:0];
    [self.frequency setWeek:0];
    //[self.frequency setWeekday:0];
    //[self.frequency setWeekdayOrdinal:0];
    //[self.frequency setQuarter:0];
    //[self.frequency setCalendar:0];
    //[self.frequency setTimeZone:0];
    //[self.frequency setWeekOfMonth:0];
    //[self.frequency setWeekOfYear:0];
    //[self.frequency setYearForWeekOfYear:0];
    //[self.frequency setLeapMonth:0];

    if ([self.strFrequency isEqualToString:strFreqArray[DAYS_PICKER_ROW]])
    {
        [self.frequency setDay:self.basis.integerValue];
    }
    else if ([self.strFrequency isEqualToString:strFreqArray[WEEKS_PICKER_ROW]])
    {
        [self.frequency setWeek:self.basis.integerValue];
    }
    else if ([self.strFrequency isEqualToString:strFreqArray[MONTHS_PICKER_ROW]])
    {
        [self.frequency setMonth:self.basis.integerValue];
    }
    else if ([self.strFrequency isEqualToString:strFreqArray[YEARS_PICKER_ROW]])
    {
        [self.frequency setYear:self.basis.integerValue];
    }
}

- (void)doneButtonClicked: (id)sender
{
    // Transfer frequency to the delegate
    if ([self.delegate respondsToSelector:@selector(recurSetFrequency:)])
    {
        [self updateFrequency];
        [self.delegate recurSetFrequency:self.frequency];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelButtonClicked: (id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// <UITableViewDataSource> methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // One row per section
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel* textLabel;
    UITextField* textField;
    
    NSArray* reuseIdentifier = [NSArray arrayWithObjects:
                                @"RecurBasisCell",
                                @"RecurFrequencyCell",
                                nil];
    
    // Attempt to reuse a cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier[indexPath.section]];
    
    // If a cell wasn't defined for reuse, create one.
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier[indexPath.section]];

        CGFloat subViewWidth = tableView.frame.size.width;
        CGFloat subViewHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        
        // Configure the cell...
        switch(indexPath.section)
        {
                
            case BASIS_SECTION_IDX:
            {
                NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                
                // Add the label
                textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, subViewWidth*0.25, subViewHeight)];
                [textLabel setText:@"Every: "];
                [cell addSubview:textLabel];
                
                // Buffer the transaction's merchant to the text field
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10+textLabel.frame.size.width, 0, subViewWidth*0.75, subViewHeight)];
                [textField setTag:BASIS_VIEW_TAG];
                [textField setDelegate:self];
                [textField setKeyboardType:UIKeyboardTypeNumberPad];
                [textField setText:[numberFormatter stringFromNumber:self.basis]];
                [cell addSubview:textField];
            }
                break;
                
            case FREQ_SECTION_IDX:
            {
                UIPickerView* freqPicker = [[UIPickerView alloc] init];
                freqPicker.delegate = self;
                freqPicker.dataSource = self;
                
                // Buffer the transaction's value to the text field
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth, subViewHeight)];
                [textField setTag:FREQ_VIEW_TAG];
                [textField setText:self.strFrequency];
                [textField setDelegate:self];
				[textField setInputView:freqPicker];
                [cell addSubview:textField];
            }
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

// <UITableViewDelegate> methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width, headerView.frame.size.height)];
    
    NSArray* headerText = [NSArray arrayWithObjects:
                           @"BASIS",
                           @"FREQUENCY",
                           nil];
    
    // Set text based on section index
    [headerLabel setText:headerText[section]];
    [headerLabel setFont:[UIFont systemFontOfSize:12]];
    [headerLabel setTextColor:[UIColor grayColor]];
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

// <UIPickerViewDelegate> methods
// returns the # of rows in each component..
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return strFreqArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UIView* firstResponder = [self.view spnFirstResponder];
    
    if([firstResponder isKindOfClass:[UITextField class]])
    {
        UITextField* textField = (UITextField*)firstResponder;
        
        // Set the text field based on the row title
        [textField setText:[self pickerView:pickerView titleForRow:row forComponent:component]];
        
        // Maintain the view controller's property
        [self setStrFrequency:textField.text];
    }
}

// <UIPickerViewDataSource> methods
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return NUM_PICKER_ROWS;
}

// <UITextFieldDelegate> methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case BASIS_VIEW_TAG:
        {
            textField.text = @"";
        }
            break;
            
        default:
            break;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case BASIS_VIEW_TAG:
        {
            // Minimum basis is 1
            if ([textField.text isEqualToString:@"0"] ||
                [textField.text isEqualToString:@""])
            {
                textField.text = @"1";
            }
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    switch (textField.tag)
    {
        case BASIS_VIEW_TAG:
        {
            NSString *text = textField.text;
            NSCharacterSet *charSet = nil;
            NSString *numberChars = @"0123456789";
            
            // the number formatter will only be instantiated once ...
            static NSNumberFormatter *numberFormatterBasis;
            if (!numberFormatterBasis)
            {
                numberFormatterBasis = [[NSNumberFormatter alloc] init];
                numberFormatterBasis.numberStyle = NSNumberFormatterDecimalStyle;
                numberFormatterBasis.maximumFractionDigits = 0;
                numberFormatterBasis.usesGroupingSeparator = NO;
            }
            
            // create the valid set of characters
            charSet = [NSCharacterSet characterSetWithCharactersInString:numberChars];
            
            // remove any characters from the string that are not a number
            NSCharacterSet *invertedCharSet = [charSet invertedSet];
            NSString *trimmedString = [string stringByTrimmingCharactersInSet:invertedCharSet];
            text = [text stringByReplacingCharactersInRange:range withString:trimmedString];
            
            // whenever chars are entered, we'll calculate the new number and update the textField accordingly.
            NSNumber *number = [numberFormatterBasis numberFromString:text];
            if (number == nil)
            {
                number = [NSNumber numberWithInt:0];
            }
            
            textField.text = [numberFormatterBasis stringFromNumber:number];
            
            // Maintain the view controller's property
            [self setBasis:number];
            
            // we return NO because we have manually edited the textField contents.
            return NO;
        }
            break;
            
        default:
            return YES;
            break;
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
