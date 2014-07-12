//
//  spnTableViewController_Transaction.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/2/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Expense.h"
#import "spnViewController_Recur.h"
#import "UIView+spnViewCtgy.h"
#import "UIViewController+addTransactionHandles.h"
#import "SpnTransaction.h"
#import "SpnTransactionCategory.h"
#import "SpnRecurrence.h"

@interface spnTableViewController_Expense ()

@property NSNumber* value;
@property NSString* merchant;
@property NSString* category_string;
@property NSDate* date;
@property NSString* notes;
@property NSDateComponents* frequency;

// Only used when this view controller is used to add a transaction
@property BOOL abort;

@end

@implementation spnTableViewController_Expense

#define DEFAULT_CATEGORY_TITLE @"Uncategorized"

enum
{
    AMOUNT_SECTION_IDX,
    MERCHANT_SECTION_IDX,
    CATEGORY_SECTION_IDX,
    DATE_SECTION_IDX,
    DESCRIPTION_SECTION_IDX,
    RECURRENCE_SECTION_IDX,
    NUM_SECTIONS
};

enum
{
    AMOUNT_VIEW_TAG = 1,
    MERCHANT_VIEW_TAG,
    CATEGORY_VIEW_TAG,
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
    
    // Assume the add transaction operation won't be aborted
    [self setAbort:FALSE];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // If the add transaction operation was not aborted
    //  (should always be false for view/edit transaction)
    if(!self.abort)
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
            
            // Move the transaction into the fetched category
            [self transaction:self.transaction moveToCategory:fetchedCategory];
        }
        else
        {
            // If the transaction is assigned to a category, ensure it matches what was provided in this view controller. if not, fetch the new category and move the transaction to it
            if(self.transaction.category.title != self.category_string)
            {
                SpnTransactionCategory* newCategory = [SpnTransactionCategory fetchCategoryWithName:self.category_string inManagedObjectContext:self.managedObjectContext];
                
                // Move the transaction into the fetched category
                [self transaction:self.transaction moveToCategory:newCategory];
            }
        }
        
        // Is there a recurrence defined for this transaction
        if(self.frequency != nil)
        {
            // Create recurrence if one doesn't exist for this transaction, otherwise update  existing one.
            if(!self.transaction.recurrence)
            {
                SpnRecurrence* recurrence = [[SpnRecurrence alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnRecurrenceMO" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];

                //[recurrence setRecurrenceForTransaction:self.transaction withFrequency:   self.frequency];
                //[recurrence setRecurrenceForTransaction:self.transaction];
            }
            else
            {
                [self.transaction.recurrence setFrequency:self.frequency];
            }
        }
    }

    [self saveContext:self.managedObjectContext];
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
        [self setAbort:FALSE];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// Only applicable when adding a transaction, button does not appear when viewing/editting an existing one.
- (void)cancelButtonClicked: (id)sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        // Just remove the transaction that was created for this add
        [self setAbort:TRUE];
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
                                 @"ExpenseAmountCell",
                                 @"ExpenseMerchantCell",
                                 @"ExpenseCategoryCell",
                                 @"ExpenseDateCell",
                                 @"ExpenseDescriptionCell",
								 @"ExpenseRecurrenceCell",
                                 nil];
    
    // Attempt to reuse a cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier[indexPath.section]];
    
    // If a cell wasn't defined for reuse, create one.
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier[indexPath.section]];
        
        NSNumberFormatter* valueFormatter;
        NSNumber* newValue;
        CGFloat subViewWidth = tableView.frame.size.width;
        CGFloat subViewHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        
        // Configure the cell...
        switch(indexPath.section)
        {
            case AMOUNT_SECTION_IDX:
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
                // Buffer the transaction's merchant to the text field
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth, subViewHeight)];
                [textField setTag:MERCHANT_VIEW_TAG];
                [textField setText:[self.transaction merchant]];
                [textField setDelegate:self];
                [cell addSubview:textField];
                
                // Maintain the view controller's property
                [self setMerchant:textField.text];
                break;
                
            case CATEGORY_SECTION_IDX:
                // Buffer the transaction's category title to the text field if it is assigned to one. Otherwise assume default category until user changes it.
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth, subViewHeight)];
                [textField setTag:CATEGORY_VIEW_TAG];
                
                if(self.transaction.category)
                {
                    [textField setText:[[self.transaction category] title]];
                }
                else
                {
                    [textField setText:DEFAULT_CATEGORY_TITLE];
                }
                
                [textField setDelegate:self];
                [cell addSubview:textField];
                
                // Maintain the view controller's property
                [self setCategory_string:textField.text];
                break;
                
            case DATE_SECTION_IDX:
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
                // Buffer the transaction's recurrence frequency to the text field
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth, subViewHeight)];
                //[textField setTag:RECURRENCE_VIEW_TAG];
                
                if(!self.transaction.recurrence)
                {
                    [textField setText:@"None"];
                    
                    // Maintain the view controller's property
                    [self setFrequency:nil];
                }
                else
                {
                    //[textField setText:[NSString stringWithFormat:@"%ld",(long)[self.transaction.recurrence.frequency integerValue]]];
                    
                    // Maintain the view controller's property
                    [self setFrequency:self.transaction.recurrence.frequency];
                }
                
                [textField setDelegate:self];
                [textField setKeyboardType:UIKeyboardTypeNumberPad];
                //[cell addSubview:textField];
                
                // Add chevron button
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell setTag:RECURRENCE_VIEW_TAG];
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
                                @"CATEGORY",
                                @"DATE",
                                @"DESCRIPTION",
                                @"RECURRENCE (DAYS)",
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
                           [NSNumber numberWithFloat:106],
                           [NSNumber numberWithFloat:44],
                           nil];

    return (CGFloat)[rowHeight[indexPath.section] floatValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == RECURRENCE_SECTION_IDX)
    {
        spnViewController_Recur* recurrenceViewCntrl = [[spnViewController_Recur alloc] init];
        recurrenceViewCntrl.title = @"Recurrence";
        recurrenceViewCntrl.delegate = self;
        [[self navigationController] pushViewController:recurrenceViewCntrl animated:YES];

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
            
        case RECURRENCE_VIEW_TAG:
        {
            NSString *text = textField.text;
            NSCharacterSet *charSet = nil;
            NSString *numberChars = @"0123456789";
            
            // the number formatter will only be instantiated once ...
            static NSNumberFormatter *numberFormatterRecurrence;
            if (!numberFormatterRecurrence)
            {
                numberFormatterRecurrence = [[NSNumberFormatter alloc] init];
                numberFormatterRecurrence.numberStyle = NSNumberFormatterDecimalStyle;
                numberFormatterRecurrence.maximumFractionDigits = 0;
                numberFormatterRecurrence.usesGroupingSeparator = NO;
            }
            
            // create the valid set of characters
            charSet = [NSCharacterSet characterSetWithCharactersInString:numberChars];

            // remove any characters from the string that are not a number
            NSCharacterSet *invertedCharSet = [charSet invertedSet];
            NSString *trimmedString = [string stringByTrimmingCharactersInSet:invertedCharSet];
            text = [text stringByReplacingCharactersInRange:range withString:trimmedString];
            
            // whenever chars are entered, we'll calculate the new number and update the textField accordingly.
            NSNumber *number = [numberFormatterRecurrence numberFromString:text];
            if (number == nil)
            {
                number = [NSNumber numberWithInt:0];
            }
            else
            {
                if(number.integerValue == 0)
                {
                    text = @"0";
                }
            }
            textField.text = text;
            
            // Maintain the view controller's property
            [self setFrequency:number];
            
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
            NSString* newCategoryName = (textField.text.length > 0) ? textField.text : DEFAULT_CATEGORY_TITLE;
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

- (void)transaction:(SpnTransaction*)transaction moveToCategory:(SpnTransactionCategory*)category
{
    SpnTransactionCategory* originalCategory = (SpnTransactionCategory*)transaction.category;
    
    // If the original category is different from the specified category
    if(category != originalCategory)
    {
        // Assign transaction to the specified category. This has the side effect of removing the transaction from originalCategory
        [category addTransactionsObject:transaction];
        
        // Delete original category if it's now empty
        if(originalCategory != nil)
        {
            // Delete original category if it's now empty
            if(originalCategory.transactions.count == 0)
            {
                // Delete category object
                [self.managedObjectContext deleteObject:originalCategory];
            }
        }
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
    self.frequency = frequency;
    
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
