//
//  spnTableViewController_BillReminder.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 11/16/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnSpendTracker.h"
#import "spnViewController_BillReminder.h"
#import "UIView+spnViewCtgy.h"
#import "UIViewController+addTransactionHandles.h"
#import "spnTableViewController_RecurSelect.h"
#import "NSDate+Convenience.h"

@interface spnViewController_BillReminder ()

@property UITableView* tableView;

// Managing the view reacting to the keyboard
@property UIView* activeField;
@property UIEdgeInsets edgeInsetsSaved;

@end

@implementation spnViewController_BillReminder

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SEL userDidTapSelector = sel_registerName("userDidTap");
    
    // Taps outside active text views/fields dismiss the keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:userDidTapSelector];
    
    [tap setDelegate:self];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    [self.tableView addGestureRecognizer:tap];
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    
    // Initialize frequency based on reminder
    self.frequency = self.billReminder.frequency;
    self.paidStatus = self.billReminder.paidStatus;
    self.dueDateWasUpdated = false;
    
    self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (void)userDidTap
{
    [self.view performSelector:@selector(dismissKeyboard)];
}

- (void)keyboardDidShowNotification:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.edgeInsetsSaved = self.tableView.contentInset;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    CGRect viewFrameRect = self.view.frame;
    viewFrameRect.size.height -= kbSize.height;
    CGPoint aBottomPointOfActiveField = CGPointMake(self.activeField.superview.frame.origin.x, self.activeField.superview.frame.origin.y+self.activeField.superview.frame.size.height);
    if (!CGRectContainsPoint(viewFrameRect, aBottomPointOfActiveField) )
    {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, self.tableView.contentInset.bottom+kbSize.height, self.tableView.contentInset.right);
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
        [self.tableView scrollRectToVisible:self.activeField.superview.frame animated:YES];
    }
}

- (void)keyboardWillHideNotification:(NSNotification*)notification
{
    self.tableView.contentInset = self.edgeInsetsSaved;
    self.tableView.scrollIndicatorInsets = self.edgeInsetsSaved;
}

- (void)doneButtonClicked: (id)sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        // Finish any in-progress text field edits
        UIView* firstResponder = [self.view spnFirstResponder];
        if (firstResponder)
        {
            [firstResponder resignFirstResponder];
        }
        
        // Buffer the local properties to the transaction managed object
        self.billReminder.value = self.value;
        self.billReminder.merchant = self.merchant;
        self.billReminder.dateDue = [[NSDate dateStartOfDay:self.date] offsetHour:8]; // 8 AM on date due
        self.billReminder.notes = self.notes;
        self.billReminder.frequency = self.frequency;
        
        // If the date was updated on an existing reminder, delete the pending notification
        if (!self.isNew && self.dueDateWasUpdated)
        {
            // first, mark bill as paid
            [self markBillAsPaid];
            
            // delete pending notification by ID
            [[spnSpendTracker sharedManager] deleteLocalNotificationWithUniqueID:self.billReminder.uniqueID];
        }
        
        // Create a new notification if this is a new reminder or we are updating an existing reminder
        if ((self.isNew) ||
            (!self.isNew && self.dueDateWasUpdated))
        {
            [self scheduleReminderNotification];
        }
        
        // Save and dismiss/pop
        [[spnSpendTracker sharedManager] saveContext:self.managedObjectContext];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// Only applicable when adding a reminder, button does not appear when viewing/editting an existing one.
- (void)cancelButtonClicked: (id)sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        // Just remove the transaction that was created for this add
        [self.managedObjectContext deleteObject:self.billReminder];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)scheduleReminderNotification
{
    // Set 'none' status - results in PENDING
    self.billReminder.paidStatus = PAID_STATUS_NONE;
    
    // Create the new reminder notification
    self.billReminder.uniqueID = @(arc4random());
    NSLog(@"%@: %lu", self.billReminder.merchant, self.billReminder.uniqueID.integerValue);
    
    UILocalNotification* notification = [[UILocalNotification alloc] init];
    notification.fireDate = self.billReminder.dateDue;
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.alertBody = [NSString stringWithFormat:@"%@ bill due!", self.merchant];
    notification.alertAction = nil;
    notification.applicationIconBadgeNumber = 0; // this will be computed in renumberBadgesOfPendingNotifications
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:[self.billReminder.uniqueID copy]] forKeys:[NSArray arrayWithObject:@"uniqueID"]];
    notification.repeatCalendar = [NSCalendar currentCalendar];
    notification.repeatInterval = 0; // Don't repeat
    notification.category = @"REMINDER_CATEGORY";
    
    [[spnSpendTracker sharedManager] addLocalNotification:notification];
}

- (void)markBillAsPaid
{
    [[spnSpendTracker sharedManager] billReminder:self.billReminder setPaidStatus:PAID_STATUS_PAID shouldAdjustBadge:YES];
    
    self.paidStatus = PAID_STATUS_PAID;
}

- (void)markBillAsUnpaid
{
    [[spnSpendTracker sharedManager] billReminder:self.billReminder setPaidStatus:PAID_STATUS_UNPAID shouldAdjustBadge:YES];
    
    self.paidStatus = PAID_STATUS_UNPAID;
}

#pragma mark - UITableViewDataSource

// <UITableViewDataSource> methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return REM_NUM_SECTIONS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITextField* textField;
    UITextView* textView;
    
    // Must be in the same order as SpnTransactionViewCntlSectionIndexType
    NSArray* reuseIdentifier = [NSArray arrayWithObjects:
                                @"ReminderMarkPaidCell",
                                @"ReminderAmountCell",
                                @"ReminderMerchantCell",
                                @"ReminderDateCell",
                                @"ReminderDescriptionCell",
                                @"ReminderRecurrenceCell",
                                @"ReminderDeleteCell",
                                nil];
    
    // Attempt to reuse a cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier[indexPath.section]];
    
    // If a cell wasn't defined for reuse, create one.
    if (cell == nil)
    {
        NSNumberFormatter* valueFormatter;
        NSNumber* newValue;
        CGFloat subViewWidth = tableView.frame.size.width;
        CGFloat subViewHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        
        // Configure the cell...
        switch(indexPath.section)
        {
            case REM_MARK_PAID_SECTION_INDEX:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                [cell.textLabel setText:@"Mark Paid"];
                [cell.textLabel setTextColor:[UIColor colorWithRed:0.0 green:0.39 blue:0.0 alpha:1.0]];
            }
                break;
                
            case REM_AMOUNT_SECTION_IDX:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                // Buffer the transaction's value to the text field
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth-10, subViewHeight)];
                [textField setTag:REM_AMOUNT_VIEW_TAG];
                [textField setText:[NSString stringWithFormat:@"$%.2f", [self.billReminder.value floatValue]]];
                [textField setDelegate:self];
                [textField setKeyboardType:UIKeyboardTypeDecimalPad];
                [cell addSubview:textField];
                
                // Maintain the view controller's property
                valueFormatter = [[NSNumberFormatter alloc] init];
                [valueFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [valueFormatter setCurrencyCode:@"USD"];
                newValue = [valueFormatter numberFromString:textField.text];
                newValue = ((!newValue.floatValue) ? [NSNumber numberWithFloat:0.0] : newValue);
                [self setValue:newValue];
                break;
                
            case REM_MERCHANT_SECTION_IDX:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                // Buffer the transaction's merchant to the text field
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth-10, subViewHeight)];
                [textField setTag:REM_MERCHANT_VIEW_TAG];
                [textField setText:[self.billReminder merchant]];
                [textField setDelegate:self];
                [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [cell addSubview:textField];
                
                // Maintain the view controller's property
                [self setMerchant:textField.text];
                break;
                
            case REM_DATE_SECTION_IDX:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                // Buffer the transaction's date to the text field if it is assigned to one. Otherwise assume today's date until user changes it.
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth-10, subViewHeight)];
                [textField setTag:REM_DATE_VIEW_TAG];
                
                // If the date doesn't come from the passed in transaction
                if(!self.billReminder.dateDue)
                {
                    if (!self.date)
                    {
                        // This is a new transaction and no preferred date was specified
                        [self.billReminder setDateDue:[NSDate date]];
                    }
                    else
                    {
                        // This is a new transaction and a preferred date was specified (specified by the calendar tab)
                        [self.billReminder setDateDue:self.date];
                    }
                }
                
                [textField setText:self.billReminder.sectionName];
                [textField setDelegate:self];
                [textField setInputView:[self.view datePickerView]];
                [cell addSubview:textField];
                
                // Maintain the view controller's properties
                [self setDate:self.billReminder.dateDue];
                break;
                
            case REM_DESCRIPTION_SECTION_IDX:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                // Buffer the transaction's notes to the text view
                textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, subViewWidth-10, subViewHeight)];
                [textView setTag:REM_DESCRIPTION_VIEW_TAG];
                [textView setText:[self.billReminder notes]];
                [textView setEditable:YES];
                [textView setDelegate:self];
                [cell addSubview:textView];
                
                // Maintain the view controller's property
                [self setNotes:textView.text];
                break;
                
            case REM_RECURRENCE_SECTION_IDX:
            {
                // Don't assign a reuse identifier since we want the cell to be dynamic
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                
                if (self.frequency)
                {
                    // Decompose it into a string and write to the cell label
                    NSComparisonResult comparedToOne = [[self stringFromInterval:self.frequency] compare:@"1"];
                    
                    NSString* strInterval = comparedToOne == NSOrderedSame ? @"" : [NSString stringWithFormat:@"%@ ", [self stringFromInterval:self.frequency]];
                    
                    NSString* strFrequency = comparedToOne == NSOrderedSame ? [self stringFromFrequency:self.frequency] : [NSString stringWithFormat:@"%@s", [self stringFromFrequency:self.frequency]];
                    
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"Every %@%@", strInterval, strFrequency]];
                }
                else
                {
                    // Buffer the transaction's recurrence frequency to the text field
                    [cell.detailTextLabel setText:@"None"];
                }
                
                // Add chevron button
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell setTag:REM_RECURRENCE_VIEW_TAG];
            }
                break;
                
            case REM_DELETE_SECTION_IDX:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                [cell.textLabel setText:@"Delete Reminder"];
                [cell.textLabel setTextColor:[UIColor redColor]];
            }
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case REM_MARK_PAID_SECTION_INDEX:
            // Only display paid row if the bill is UNPAID and we aren't creating a new one right now
            return ((self.paidStatus != PAID_STATUS_UNPAID) || self.isNew) ? 0 : 1;
            break;
            
        case REM_AMOUNT_SECTION_IDX:
        case REM_MERCHANT_SECTION_IDX:
        case REM_DATE_SECTION_IDX:
        case REM_DESCRIPTION_SECTION_IDX:
        case REM_RECURRENCE_SECTION_IDX:
            // One row per section
            return 1;
            break;
            
        case REM_DELETE_SECTION_IDX:
            // For the delete section, only display the row if a reminder creation isn't in progress
            return self.isNew ? 0 : 1;
            break;
            
        default:
            return 0;
            break;
    }
}

#pragma mark - UITableViewDelegate

// <UITableViewDelegate> methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width, headerView.frame.size.height)];
    
    // Must be in the same order as SpnTransactionViewCntlSectionIndexType
    NSArray* headerText = [NSArray arrayWithObjects:
                           @"", // the mark paid row doesn't need a section title
                           @"AMOUNT",
                           @"MERCHANT",
                           @"DATE DUE",
                           @"DESCRIPTION",
                           @"RECURRENCE",
                           @"", // the delete row doesn't need a section title
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
    switch (section)
    {
        case REM_MARK_PAID_SECTION_INDEX:
            return 0.001;
            break;
            
        case REM_AMOUNT_SECTION_IDX:
        case REM_MERCHANT_SECTION_IDX:
        case REM_DATE_SECTION_IDX:
        case REM_DESCRIPTION_SECTION_IDX:
        case REM_RECURRENCE_SECTION_IDX:
        case REM_DELETE_SECTION_IDX:
            return 25;
            break;
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Must be in the same order as SpnTransactionViewCntlSectionIndexType
    NSArray* rowHeight = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:44],
                          [NSNumber numberWithFloat:44],
                          [NSNumber numberWithFloat:44],
                          [NSNumber numberWithFloat:44],
                          [NSNumber numberWithFloat:84],
                          [NSNumber numberWithFloat:44],
                          [NSNumber numberWithFloat:44],
                          nil];
    
    return (CGFloat)[rowHeight[indexPath.section] floatValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case REM_MARK_PAID_SECTION_INDEX:
        {
            [self markBillAsPaid];
            
            // If there is a frequency specified, schedule the next notification
            if (self.frequency)
            {
                NSDate* newDateDue = [self.billReminder.dateDue dateByAddingComponents:self.frequency];
                self.billReminder.dateDue = newDateDue;
                
                [self scheduleReminderNotification];
            }
            
            // Save and dismiss/pop
            [[spnSpendTracker sharedManager] saveContext:self.managedObjectContext];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        case REM_RECURRENCE_SECTION_IDX:
        {
            spnTableViewController_RecurSelect* recurrenceViewCntrl = [[spnTableViewController_RecurSelect alloc] initWithStyle:UITableViewStyleGrouped];
            recurrenceViewCntrl.title = @"Recurrence";
            recurrenceViewCntrl.delegate = self;
            
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:recurrenceViewCntrl];
            
            [self presentViewController:navController animated:YES completion:nil];
        }
            break;
            
        case REM_DELETE_SECTION_IDX:
        {
            // Mark bill as paid (cleans up any badge numbers)
            [self markBillAsPaid];
            
            // Delete the notification in case it still is pending
            [[spnSpendTracker sharedManager] deleteLocalNotificationWithUniqueID:self.billReminder.uniqueID];
            
            // Remove the reminder object
            [self.managedObjectContext deleteObject:self.billReminder];
            
            // Save and dismiss/pop
            [[spnSpendTracker sharedManager] saveContext:self.managedObjectContext];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
            
        default:
            break;
    }
    
}

#pragma mark - UITextFieldDelegate

// <UITextFieldDelegate> methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // lets the view controller know that this field is active - used in keyboard/view position management
    self.activeField = textField;
    
    switch (textField.tag)
    {
        case REM_AMOUNT_VIEW_TAG:
        {
            textField.text = @"$";
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
        case REM_AMOUNT_VIEW_TAG:
        {
            NSString *text = textField.text;
            NSString *decimalSeperator = @".";
            NSCharacterSet *charSet = nil;
            NSString *numberChars = @"0123456789";
            
            
            // the number formatter will only be instantiated once ...
            static NSNumberFormatter *numberFormatterCurrency;
            if (!numberFormatterCurrency)
            {
                numberFormatterCurrency = [[NSNumberFormatter alloc] init];
                numberFormatterCurrency.numberStyle = NSNumberFormatterCurrencyStyle;
                numberFormatterCurrency.maximumFractionDigits = 2;
                numberFormatterCurrency.minimumFractionDigits = 0;
                numberFormatterCurrency.decimalSeparator = decimalSeperator;
                numberFormatterCurrency.usesGroupingSeparator = NO;
            }
            
            
            // create a character set of valid chars (numbers and optionally a decimal sign) ...
            NSRange decimalRange = [text rangeOfString:decimalSeperator];
            BOOL isDecimalNumber = (decimalRange.location != NSNotFound);
            if (isDecimalNumber)
            {
                charSet = [NSCharacterSet characterSetWithCharactersInString:numberChars];
            }
            else
            {
                numberChars = [numberChars stringByAppendingString:decimalSeperator];
                charSet = [NSCharacterSet characterSetWithCharactersInString:numberChars];
            }
            
            
            // remove any characters from the string that are not a number or decimal sign ...
            NSCharacterSet *invertedCharSet = [charSet invertedSet];
            NSString *trimmedString = [string stringByTrimmingCharactersInSet:invertedCharSet];
            text = [text stringByReplacingCharactersInRange:range withString:trimmedString];
            
            
            // whenever a decimalSeperator is entered, we'll just update the textField.
            // whenever other chars are entered, we'll calculate the new number and update the textField accordingly.
            if ([string isEqualToString:decimalSeperator] == YES)
            {
                textField.text = text;
            }
            else
            {
                NSNumber *number = [numberFormatterCurrency numberFromString:text];
                if (number == nil)
                {
                    number = [NSNumber numberWithFloat:0.00];
                }
                textField.text = isDecimalNumber ? text : [numberFormatterCurrency stringFromNumber:number];
            }
            
            // Maintain the view controller's property
            [self setValue:[numberFormatterCurrency numberFromString:text]];
            
            // we return NO because we have manually edited the textField contents.
            return NO;
        }
            break;
            
        default:
            return YES;
            break;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
    
    switch (textField.tag)
    {
        case REM_MERCHANT_VIEW_TAG:
        {
            // Maintain the view controller's property
            [self setMerchant:textField.text];
        }
            break;
            
        case REM_DATE_VIEW_TAG:
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            [dateFormatter setDateStyle: NSDateFormatterMediumStyle];
            
            // Compute date from string. Maintain the view controller's properties
            [self setDate:[dateFormatter dateFromString:textField.text]];
            [self setDueDateWasUpdated:true];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITextViewDelegate

// <UITextViewDelegate> methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // lets the view controller know that this field is active - used in keyboard/view position management
    self.activeField = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.activeField = nil;
    
    switch (textView.tag)
    {
        case REM_DESCRIPTION_VIEW_TAG:
        {
            // Maintain the view controller's property
            [self setNotes:textView.text];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - spnViewController_RecurDelegate

// <spnViewController_RecurDelegate> methods
- (NSDateComponents*)recurGetFrequency
{
    return self.frequency;
}

- (void)recurSetFrequency:(NSDateComponents*)frequency
{
    // Set the frequency
    self.frequency = frequency;
    
    // The updates to the data supporting the table are complete
    [self.tableView reloadData];
}

- (NSString*) stringFromFrequency:(NSDateComponents*)frequency
{
    NSString* strFrequency;
    
    if (frequency.day > 0)
    {
        strFrequency = @"Day";
    }
    else if (frequency.month > 0)
    {
        strFrequency = @"Month";
    }
    else if (frequency.year > 0)
    {
        strFrequency = @"Year";
    }
    else if (frequency.weekOfYear > 0)
    {
        strFrequency = @"Week";
    }
    else
    {
        // Should not be here
        strFrequency = @"Unknown";
    }
    
    return strFrequency;
}

- (NSString*) stringFromInterval:(NSDateComponents*)frequency
{
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber* basis;
    
    if (frequency.day > 0)
    {
        basis = [NSNumber numberWithInteger:frequency.day];
    }
    else if (frequency.month > 0)
    {
        basis = [NSNumber numberWithInteger:frequency.month];
    }
    else if (frequency.year > 0)
    {
        basis = [NSNumber numberWithInteger:frequency.year];
    }
    else if (frequency.weekOfYear > 0)
    {
        basis = [NSNumber numberWithInteger:frequency.weekOfYear];
    }
    else
    {
        // Should not be here
        basis = [NSNumber numberWithInteger:0];
    }
    
    return [numberFormatter stringFromNumber:basis];
}

@end
