//
//  spnTableViewController_Transaction.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/15/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Transaction.h"
#import "UIView+spnViewCtgy.h"
#import "UIViewController+addTransactionHandles.h"
#import "SpnRecurrence.h"
#import "SpnTransactionCategory.h"
#import "spnViewController_RecurSelect.h"
#import "spnViewController_CategorySelect.h"

@interface spnTableViewController_Transaction ()

@end

@implementation spnTableViewController_Transaction

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Taps outside active text views/fields dismiss the keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self.view
                                   action:@selector(dismissKeyboard)];
    
    [tap setDelegate:self];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
    // Initialize frequency based on recurrence
    if (self.transaction.recurrence)
    {
        [self setFrequency:self.transaction.recurrence.frequency];
    }
    
    self.frequencyWasUpdated = false;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        self.transaction.value = self.value;
        self.transaction.merchant = self.merchant;
        self.transaction.date = self.date;
        self.transaction.notes = self.notes;
        
        // Category - for a new transaction, fetch a category and assign the transaction to it
        if(!self.transaction.category)
        {
            SpnTransactionCategory* fetchedCategory = [SpnTransactionCategory fetchCategoryWithName:self.category_string inManagedObjectContext:self.managedObjectContext];
            
            // Assign transaction to the new category. This has the side effect of removing the transaction from originalCategory
            [fetchedCategory addTransactionsObject:self.transaction];
        }
        else
        {
            // If the transaction is assigned to a category, ensure it matches what was provided in this view controller. if not, fetch the new category and move the transaction to it
            if(![self.transaction.category.title isEqualToString:self.category_string])
            {
                SpnTransactionCategory* newCategory = [SpnTransactionCategory fetchCategoryWithName:self.category_string inManagedObjectContext:self.managedObjectContext];
                
                // Assign transaction to the new category. This has the side effect of removing the transaction from originalCategory
                [newCategory addTransactionsObject:self.transaction];
            }
        }
        
        // Process any NEW recurrence
        if ((self.transaction.recurrence == nil) && (self.frequency != nil))
        {
            // Create recurrence
            SpnRecurrence* recurrence = [[SpnRecurrence alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnRecurrenceMO" inManagedObjectContext:self.managedObjectContext]insertIntoManagedObjectContext:self.managedObjectContext];
            
            [recurrence setRecurrenceForTransaction:self.transaction withFrequency:self.frequency withAction:RECUR_ACTION_CREATE];
            
            // Save and dismiss/pop
            [self saveContext:self.managedObjectContext];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (self.transaction.recurrence != nil)
        {
            // If the frequency was updated, then the user will need to decide whether to apply the new interval to future transactions (deleting previously created future transactions) or cancel.
            if (self.frequencyWasUpdated)
            {
                // display the action sheet for updating a transaction within a series
                UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Recurrence interval was updated. This will replace all future transactions in the series." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                              @"Update Future",
                                              nil];
                
                [actionSheet setTag:UPDATE_RECUR_INTERVAL_AS_TAG];
                [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
                [actionSheet showInView:self.view];
                // this will not return (unless cancelled)
            }
            else // If the user is updating the transaction data (other than the recurrence info), the user can apply the update to all transactions in the series, future transactions, or just this one transaction.
            {
                // display the action sheet for updating a transaction within a series
                UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"This transaction is part of a series..." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:
                                              @"Update All",
                                              @"Update Future",
                                              @"Update One",
                                              nil];
                
                [actionSheet setTag:UPDATE_RECUR_AS_TAG];
                [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
                [actionSheet showInView:self.view];
                // this will not return
            }
        }
        else
        {
            // Save and dismiss/pop
            [self saveContext:self.managedObjectContext];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

// Only applicable when adding a transaction, button does not appear when viewing/editting an existing one.
- (void)cancelButtonClicked: (id)sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        // Just remove the transaction that was created for this add
        [self.managedObjectContext deleteObject:self.transaction];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// <UITableViewDataSource> methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return NUM_SECTIONS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITextField* textField;
    UITextView* textView;
    
    NSArray* reuseIdentifier = [NSArray arrayWithObjects:
                                @"TrnsAmountCell",
                                @"TrnsMerchantCell",
                                @"TrnsCategoryCell",
                                @"TrnsDateCell",
                                @"TrnsDescriptionCell",
                                @"TrnsRecurrenceCell",
                                @"TrnsDeleteCell",
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
            case AMOUNT_SECTION_IDX:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                // Buffer the transaction's value to the text field
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth-10, subViewHeight)];
                [textField setTag:AMOUNT_VIEW_TAG];
                [textField setText:[NSString stringWithFormat:@"$%.2f", [self.transaction.value floatValue]]];
                [textField setDelegate:self];
				[textField setKeyboardType:UIKeyboardTypeNumberPad];
                [cell addSubview:textField];
                
                // Maintain the view controller's property
                valueFormatter = [[NSNumberFormatter alloc] init];
                [valueFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [valueFormatter setCurrencyCode:@"USD"];
                newValue = [valueFormatter numberFromString:textField.text];
                newValue = ((!newValue.floatValue) ? [NSNumber numberWithFloat:0.0] : newValue);
                [self setValue:newValue];
                break;
                
            case MERCHANT_SECTION_IDX:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                // Buffer the transaction's merchant to the text field
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth-10, subViewHeight)];
                [textField setTag:MERCHANT_VIEW_TAG];
                [textField setText:[self.transaction merchant]];
                [textField setDelegate:self];
                [cell addSubview:textField];
                
                // Maintain the view controller's property
                [self setMerchant:textField.text];
                break;
                
            case CATEGORY_SECTION_IDX:
                // Don't assign a reuse identifier since we want the cell to be dynamic
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                
                [cell.textLabel setText:self.category_string];
                
                // Add chevron button
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell setTag:CATEGORY_VIEW_TAG];
                break;
                
            case DATE_SECTION_IDX:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                // Buffer the transaction's date to the text field if it is assigned to one. Otherwise assume today's date until user changes it.
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth-10, subViewHeight)];
                [textField setTag:DATE_VIEW_TAG];
                
                if(!self.transaction.date)
                {
                    [self.transaction setDate:[NSDate date]];
                }
                
                [textField setText:self.transaction.sectionName];
                [textField setDelegate:self];
                [textField setInputView:[self.view datePickerView]];
                [cell addSubview:textField];
                
                // Maintain the view controller's properties
                [self setDate:self.transaction.date];
                break;
                
            case DESCRIPTION_SECTION_IDX:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                // Buffer the transaction's notes to the text view
                textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, subViewWidth-10, subViewHeight)];
                [textView setTag:DESCRIPTION_VIEW_TAG];
                [textView setText:[self.transaction notes]];
                [textView setEditable:YES];
                [textView setDelegate:self];
                [cell addSubview:textView];
                
                // Maintain the view controller's property
                [self setNotes:textView.text];
                break;
                
            case RECURRENCE_SECTION_IDX:
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
                [cell setTag:RECURRENCE_VIEW_TAG];
            }
                break;
                
            case DELETE_SECTION_IDX:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                [cell.textLabel setText:@"Delete Transaction"];
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
        case AMOUNT_SECTION_IDX:
        case MERCHANT_SECTION_IDX:
        case CATEGORY_SECTION_IDX:
        case DATE_SECTION_IDX:
        case DESCRIPTION_SECTION_IDX:
        case RECURRENCE_SECTION_IDX:
            // One row per section
            return 1;
            break;
            
        case DELETE_SECTION_IDX:
            // For the delete section, only display the row if a transaction creation isn't in progress
            return self.isNew ? 0 : 1;
            break;
            
        default:
            return 0;
            break;
    }
}


// <UITableViewDelegate> methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width, headerView.frame.size.height)];
    
    NSArray* headerText = [NSArray arrayWithObjects:
                           @"AMOUNT",
                           @"MERCHANT",
                           @"CATEGORY",
                           @"DATE",
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
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        case CATEGORY_SECTION_IDX:
        {
            spnViewController_CategorySelect* categorySelectViewCntrl = [[spnViewController_CategorySelect alloc] initWithStyle:UITableViewStyleGrouped];
            categorySelectViewCntrl.title = @"Select Category";
            categorySelectViewCntrl.delegate = self;
            categorySelectViewCntrl.managedObjectContext = self.managedObjectContext;
            
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:categorySelectViewCntrl];
            
            [self presentViewController:navController animated:YES completion:nil];
        }
            break;
            
        case RECURRENCE_SECTION_IDX:
        {
            spnViewController_RecurSelect* recurrenceViewCntrl = [[spnViewController_RecurSelect alloc] initWithStyle:UITableViewStyleGrouped];
            recurrenceViewCntrl.title = @"Recurrence";
            recurrenceViewCntrl.delegate = self;
            
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:recurrenceViewCntrl];
            
            [self presentViewController:navController animated:YES completion:nil];
        }
            break;
            
        case DELETE_SECTION_IDX:
        {
            // If this is not a recurring transansaction
            if (!self.transaction.recurrence)
            {
                // Display the action sheet for deleting a transaction
                UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
                
                [actionSheet setTag:DELETE_ONE_AS_TAG];
                [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
                [actionSheet showInView:self.view];
                // this will not return unless cancel is pressed
            }
            else // this is a recurring transaction
            {
                // display the action sheet for deleting a transaction within a series
                UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"This transaction is part of a series..." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:
                                              @"Delete All",
                                              @"Delete Future",
                                              @"Delete One",
                                              nil];
                
                [actionSheet setTag:DELETE_RECUR_AS_TAG];
                [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
                [actionSheet showInView:self.view];
            }
        }
            break;
            
        default:
            break;
    }
    
}

// <UITextFieldDelegate> methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case AMOUNT_VIEW_TAG:
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
        case AMOUNT_VIEW_TAG:
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
    switch (textField.tag)
    {
        case MERCHANT_VIEW_TAG:
        {
            // Maintain the view controller's property
            [self setMerchant:textField.text];
        }
            break;
            
        case CATEGORY_VIEW_TAG:
        {
            // Protect against empty string - keep existing category string if this is the case
            NSString* newCategoryName = (textField.text.length > 0) ? textField.text : self.category_string;
            textField.text = newCategoryName;
            
            // Maintain the view controller's property
            [self setCategory_string:newCategoryName];
        }
            break;
            
        case DATE_VIEW_TAG:
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            [dateFormatter setDateStyle: NSDateFormatterMediumStyle];
            
            // Compute date from string. Maintain the view controller's properties
            [self setDate:[dateFormatter dateFromString:textField.text]];
        }
            break;
            
        default:
            break;
    }
}

// <UITextViewDelegate> methods
- (void)textViewDidEndEditing:(UITextView *)textView
{
    switch (textView.tag)
    {
        case DESCRIPTION_VIEW_TAG:
        {
            // Maintain the view controller's property
            [self setNotes:textView.text];
        }
            break;
            
        default:
            break;
    }
}

// <spnViewController_RecurDelegate> methods
- (NSDateComponents*)recurGetFrequency
{
    return self.frequency;
}

- (void)recurSetFrequency:(NSDateComponents*)frequency
{
    // Set the frequency
    self.frequency = frequency;
    self.frequencyWasUpdated = true;
    
    // The udpates to the data supporting the table are complete
    [self.tableView reloadData];
}

- (NSString*) stringFromFrequency:(NSDateComponents*)frequency
{
    NSString* strFrequency;
    
    if (frequency.day > 0)
    {
        strFrequency = @"Day";
    }
    else if (frequency.week > 0)
    {
        strFrequency = @"Week";
    }
    else if (frequency.month > 0)
    {
        strFrequency = @"Month";
    }
    else if (frequency.year > 0)
    {
        strFrequency = @"Year";
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
    else if (frequency.week > 0)
    {
        basis = [NSNumber numberWithInteger:frequency.week];
    }
    else if (frequency.month > 0)
    {
        basis = [NSNumber numberWithInteger:frequency.month];
    }
    else if (frequency.year > 0)
    {
        basis = [NSNumber numberWithInteger:frequency.year];
    }
    else
    {
        // Should not be here
        basis = [NSNumber numberWithInteger:0];
    }
    
    return [numberFormatter stringFromNumber:basis];
}

// <UIActionSheetDelegate> methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    SpnRecurrenceActionType action;
    
    switch (actionSheet.tag)
    {
        // Update transaction in a series
        case UPDATE_RECUR_AS_TAG:
        {
            switch (buttonIndex)
            {
                    // All transactions in a series
                case UPDATE_ALL_AS_INDEX:
                {
                    action = RECUR_ACTION_UPDATE_ALL;
                }
                    break;
                    
                    // This and future transactions
                case UPDATE_FUTURE_AS_INDEX:
                {
                    action = RECUR_ACTION_UPDATE_FUTURE;
                }
                    break;
                    
                    // This transaction only
                case UPDATE_ONE_AS_INDEX:
                {
                    action = RECUR_ACTION_UPDATE_ONE;
                }
                    break;
                    
                    // Do nothing
                default:
                    action = RECUR_ACTION_NONE;
                    break;
            }
            
            // Pass action along to the recurrence
            [self.transaction.recurrence setRecurrenceForTransaction:self.transaction withFrequency:self.transaction.recurrence.frequency withAction:action];
            
            // Save and pop
            [self saveContext:self.managedObjectContext];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        // Update transaction recurrence interval in a series
        case UPDATE_RECUR_INTERVAL_AS_TAG:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    // Make a copy of this transaction
                    SpnTransaction* copiedTransaction = [self.transaction clone];
                    
                    // The interval is about to be updated. First it needs to delete all future transactions (this one will be included)
                    [self.transaction.recurrence setRecurrenceForTransaction:self.transaction withFrequency:self.transaction.recurrence.frequency withAction:RECUR_ACTION_DELETE_FUTURE];
                    
                    // Then create a new series starting with the copied transaction
                    SpnRecurrence* recurrence = [[SpnRecurrence alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnRecurrenceMO" inManagedObjectContext:self.managedObjectContext]insertIntoManagedObjectContext:self.managedObjectContext];
                    
                    [recurrence setRecurrenceForTransaction:self.transaction withFrequency:self.frequency withAction:RECUR_ACTION_CREATE];
                    
                    // Save and pop
                    [self saveContext:self.managedObjectContext];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                    break;
            
                // Cancel (default cancel)
                case 1:
                {
                    // Just deselect the cell
                    [(UITableView*)self.view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:DELETE_SECTION_IDX] animated:YES];
                }
                    break;
            }
        }
            break;
            
        case DELETE_RECUR_AS_TAG:
        {
            switch (buttonIndex)
            {
                    // All transactions in a series
                case DELETE_ALL_AS_INDEX:
                {
                    action = RECUR_ACTION_DELETE_ALL;
                }
                    break;
                    
                    // This and future transactions
                case DELETE_FUTURE_AS_INDEX:
                {
                    action = RECUR_ACTION_DELETE_FUTURE;
                }
                    break;
                    
                    // This transaction only
                case DELETE_ONE_AS_INDEX:
                {
                    action = RECUR_ACTION_DELETE_ONE;
                }
                    break;
                    
                    // Do nothing
                default:
                    action = RECUR_ACTION_NONE;
                    break;
            }
            
            // Pass action along to the recurrence
            [self.transaction.recurrence setRecurrenceForTransaction:self.transaction withFrequency:self.transaction.recurrence.frequency withAction:action];
            
            // Save and pop
            [self saveContext:self.managedObjectContext];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        case DELETE_ONE_AS_TAG:
        {
            switch (buttonIndex)
            {
                    // Delete (default destructive)
                case 0:
                {
                    // Just remove the transaction that was created for this add
                    [self.managedObjectContext deleteObject:self.transaction];
                    
                    // Save and dismiss/pop
                    [self saveContext:self.managedObjectContext];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                    break;
                    
                    // Cancel (default cancel)
                case 1:
                {
                    // Just deselect the cell
                    [(UITableView*)self.view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:DELETE_SECTION_IDX] animated:YES];
                }
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

//<spnViewController_CategorySelectDelegate> methods
- (void)categorySetName:(NSString*)category_str
{
    // Set the frequency
    self.category_string = category_str;
    
    // The udpates to the data supporting the table are complete
    [self.tableView reloadData];
}

@end
