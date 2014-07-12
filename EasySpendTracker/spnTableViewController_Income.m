//
//  spnTableViewController_Transaction.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/2/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Income.h"
#import "spnViewController_Recur.h"
#import "UIView+spnViewCtgy.h"
#import "UIViewController+addTransactionHandles.h"
#import "SpnTransaction.h"
#import "SpnTransactionCategory.h"
#import "SpnRecurrence.h"

@interface spnTableViewController_Income ()

@property NSNumber* value;
@property NSString* merchant;
@property NSString* category_string;
@property NSDate* date;
@property NSString* notes;
@property NSDateComponents* frequency;

@end

@implementation spnTableViewController_Income

#define DEFAULT_CATEGORY_TITLE @"Income"

enum
{
    AMOUNT_SECTION_IDX,
    MERCHANT_SECTION_IDX,
    DATE_SECTION_IDX,
    DESCRIPTION_SECTION_IDX,
    RECURRENCE_SECTION_IDX,
    NUM_SECTIONS
};

enum
{
    AMOUNT_VIEW_TAG = 1,
    MERCHANT_VIEW_TAG,
    DATE_VIEW_TAG,
    DESCRIPTION_VIEW_TAG,
    RECURRENCE_VIEW_TAG
};

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
    [self.view addGestureRecognizer:tap];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Assign the recurrence frequency to the property if it exists for this transaction
    if (self.transaction.recurrence)
    {
        [self setFrequency:self.transaction.recurrence.frequency];
    }
    else
    {
        [self setFrequency:nil];
    }
    
    // Category is hardcoded to "Income" for this view controller
    [self setCategory_string:DEFAULT_CATEGORY_TITLE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Only applicable when adding a transaction, button does not appear when viewing/editting an existing one.
- (void)doneButtonClicked: (id)sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        // Buffer the local properties to the transaction managed object
        self.transaction.value = self.value;
        self.transaction.merchant = self.merchant;
        self.transaction.date = self.date;
        self.transaction.notes = self.notes;
        
        // Category - for an add transaction, this will be nil and so one needs to be created
        if(!self.transaction.category)
        {
            SpnTransactionCategory* fetchedCategory = [SpnTransactionCategory fetchCategoryWithName:self.category_string inManagedObjectContext:self.managedObjectContext];
            
            // Assign transaction to the new category. This has the side effect of removing the transaction from originalCategory
            [fetchedCategory addTransactionsObject:self.transaction];
        }
        else
        {
            // If the transaction is assigned to a category, ensure it matches what was provided in this view controller. if not, fetch the new category and move the transaction to it
            if(self.transaction.category.title != self.category_string)
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
        }
        else if (self.transaction.recurrence != nil)
        {
            // display the action sheet for updating a transaction within a series
            UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"This transaction is part of a series..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                          @"Update All",
                                          @"Update Future",
                                          @"Update One",
                                          nil];
            
            [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
            [actionSheet showInView:self.view];
            // this will not return
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // One row per section
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITextField* textField;
    UITextView* textView;
    
    NSArray* reuseIdentifier = [NSArray arrayWithObjects:
                                 @"IncomeAmountCell",
                                 @"IncomeMerchantCell",
                                 @"IncomeDateCell",
                                 @"IncomeDescriptionCell",
                                 @"IncomeRecurrenceCell",
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
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth, subViewHeight)];
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
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth, subViewHeight)];
                [textField setTag:MERCHANT_VIEW_TAG];
                [textField setText:[self.transaction merchant]];
                [textField setDelegate:self];
                [cell addSubview:textField];
                
                // Maintain the view controller's property
                [self setMerchant:textField.text];
                break;
                
            case DATE_SECTION_IDX:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                // Buffer the transaction's date to the text field if it is assigned to one. Otherwise assume today's date until user changes it.
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth, subViewHeight)];
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
                textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, subViewWidth, subViewHeight)];
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
                
                // Buffer the transaction's recurrence frequency to the text field
                if(!self.frequency)
                {
                    [cell.detailTextLabel setText:@"None"];
                }
                else
                {
                    // Decompose it into a string and write to the cell label
                    NSComparisonResult comparedToOne = [[self stringFromInterval:self.frequency] compare:@"1"];
                    
                    NSString* strInterval = comparedToOne == NSOrderedSame ? @"" : [NSString stringWithFormat:@"%@ ", [self stringFromInterval:self.frequency]];
                    
                    NSString* strFrequency = comparedToOne == NSOrderedSame ? [self stringFromFrequency:self.frequency] : [NSString stringWithFormat:@"%@s", [self stringFromFrequency:self.frequency]];
                    
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"Every %@%@", strInterval, strFrequency]];
                }

                // Add chevron button
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell setTag:RECURRENCE_VIEW_TAG];
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
                                @"AMOUNT",
                                @"MERCHANT",
                                @"DATE",
                                @"DESCRIPTION",
                                @"RECURRENCE",
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
                           [NSNumber numberWithFloat:106],
                           [NSNumber numberWithFloat:44],
                           nil];

    return (CGFloat)[rowHeight[indexPath.section] floatValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == RECURRENCE_SECTION_IDX)
    {
        spnViewController_Recur* recurrenceViewCntrl = [[spnViewController_Recur alloc] initWithStyle:UITableViewStyleGrouped];
        recurrenceViewCntrl.title = @"Recurrence";
        recurrenceViewCntrl.delegate = self;
        
        //[[self navigationController] pushViewController:recurrenceViewCntrl animated:YES];
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:recurrenceViewCntrl];
        
        [self presentViewController:navController animated:YES completion:nil];
    }
}

// <UITextFieldDelegate> methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case RECURRENCE_VIEW_TAG:
        {
            if ([textField.text isEqualToString:@"None"])
            {
                textField.text = @"";
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
            
        case DATE_VIEW_TAG:
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            [dateFormatter setDateStyle: NSDateFormatterMediumStyle];
            
            // Compute date from string. Maintain the view controller's properties
            [self setDate:[dateFormatter dateFromString:textField.text]];
        }
            break;
            
        case RECURRENCE_VIEW_TAG:
        {
            if(([textField.text isEqualToString:@""]) ||
               ([textField.text isEqualToString:@"0"]))
            {
                // invalid
                [textField setText:@"None"];
            }
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

// <UIGestureRecognizerDelegate> methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UITableViewCell* recurrenceCell = [(UITableView*)self.view cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:RECURRENCE_SECTION_IDX]];
    
    if ([touch.view isDescendantOfView:recurrenceCell])
    {
        // Don't let selection of recurrence cell fire the gesture recognizer
        return NO;
    }
    
    return YES;
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
    
    switch (buttonIndex)
    {
        case UPDATE_ALL_AS_INDEX:
        {
            action = RECUR_ACTION_UPDATE_ALL;
        }
            break;
            
        case UPDATE_FUTURE_AS_INDEX:
        {
            action = RECUR_ACTION_UPDATE_FUTURE;
        }
            break;
            
        case UPDATE_ONE_AS_INDEX:
        {
            action = RECUR_ACTION_UPDATE_ONE;
        }
            break;
            
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
