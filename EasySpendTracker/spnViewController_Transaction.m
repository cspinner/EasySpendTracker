//
//  spnTableViewController_Transaction.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/15/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnSpendTracker.h"
#import "spnViewController_Transaction.h"
#import "UIView+spnViewCtgy.h"
#import "UIViewController+addTransactionHandles.h"
#import "SpnRecurrence.h"
#import "SpnCategory.h"
#import "SpnSubCategory.h"
#import "spnTableViewController_RecurSelect.h"
#import "spnTableViewController_MainCategorySelect.h"
#import "spnTableViewController_SubCategorySelect.h"
#import "AutoFillTableViewController.h"
#import "NSDate+Convenience.h"

@interface spnViewController_Transaction ()

@property AutoFillTableViewController *autoFillTableViewController;
@property UITableView* tableView;

// Managing the view reacting to the keyboard
@property UIView* activeField;
@property UIEdgeInsets edgeInsetsSaved;
@property BOOL isKeyboardOpen;

@end

@implementation spnViewController_Transaction

static int mainCategorySetContext;
static int subCategorySetContext;

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
    
    self.isKeyboardOpen = NO;
    
    // Initialize frequency based on recurrence
    if (self.transaction.recurrence)
    {
        [self setFrequency:self.transaction.recurrence.frequency];
    }
    
    self.frequencyWasUpdated = false;
    
    self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Fetch merchants from the past 3 months
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SpnTransactionMO"];
    
    NSMutableArray* merchantArray;
    NSError* error;
    
    // This day 1 year ago
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"date >= %@", [[NSDate date] offsetYear:-1]];
    fetchRequest.predicate = predicate;
    merchantArray = [NSMutableArray arrayWithArray: [self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    merchantArray = [merchantArray valueForKeyPath:@"@distinctUnionOfObjects.merchant"];
    
    self.autoFillTableViewController = [[AutoFillTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.autoFillTableViewController createTableViewWithYPosition:@200];
    [self addChildViewController:self.autoFillTableViewController];
    self.autoFillTableViewController.sourceData = merchantArray;
    self.autoFillTableViewController.delegate = self;
  
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.autoFillTableViewController.tableView];
    [self.view bringSubviewToFront:self.autoFillTableViewController.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.autoFillTableViewController.tableView.hidden == NO)
    {
        // Don't allow the gesture recognizer to consume the touch to the autocomplete table
        CGPoint touchPoint = [touch locationInView:self.autoFillTableViewController.tableView];
        
        UIView* receiverDescendantView = [self.autoFillTableViewController.tableView hitTest:touchPoint withEvent:nil];
        
        // Returns no if we tapped a row in the Auto fill table view
        return (receiverDescendantView == nil);
    }
    else
    {
        return YES;
    }
}

- (void)userDidTap
{
    [self.view performSelector:@selector(dismissKeyboard)];
    
    self.autoFillTableViewController.tableView.hidden = YES;
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
    
    self.isKeyboardOpen = YES;
}

- (void)keyboardWillHideNotification:(NSNotification*)notification
{
    if (self.isKeyboardOpen == YES)
    {
        self.tableView.contentInset = self.edgeInsetsSaved;
        self.tableView.scrollIndicatorInsets = self.edgeInsetsSaved;
    }
    
    self.isKeyboardOpen = NO;
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
        
        // Category - for a new transaction, fetch a category and sub-category and assign the transaction to it
        if(!self.transaction.subCategory)
        {
            // get main category
            SpnCategory* fetchedCategory = [SpnCategory fetchCategoryWithName:self.category_string inManagedObjectContext:self.managedObjectContext];
            
            // ..and sub-category
            SpnSubCategory* fetchedSubCategory = [fetchedCategory fetchSubCategoryWithName:self.subCategory_string inManagedObjectContext:self.managedObjectContext];
            
            // Assign transaction to the new category. This has the side effect of removing the transaction from originalCategory
            [fetchedSubCategory addTransactionsObject:self.transaction];
        }
        else
        {
            // If the transaction is assigned to a category/sub-category, ensure it matches what was provided in this view controller. if not, fetch the new category and sub-category, and move the transaction to it
            if(![self.transaction.subCategory.category.title isEqualToString:self.category_string] ||
               ![self.transaction.subCategory.title isEqualToString:self.subCategory_string])
            {
                SpnCategory* newCategory = [SpnCategory fetchCategoryWithName:self.category_string inManagedObjectContext:self.managedObjectContext];
                
                SpnSubCategory* newSubCategory = [newCategory fetchSubCategoryWithName:self.subCategory_string inManagedObjectContext:self.managedObjectContext];
                
                // Assign transaction to the new sub-category. This has the side effect of removing the transaction from original category/sub-category
                [newSubCategory addTransactionsObject:self.transaction];
            }
        }
        
        // Process any NEW recurrence
        if ((self.transaction.recurrence == nil) && (self.frequency != nil))
        {
            // Create recurrence
            SpnRecurrence* recurrence = [[SpnRecurrence alloc] initWithEntity:[NSEntityDescription entityForName:@"SpnRecurrenceMO" inManagedObjectContext:self.managedObjectContext]insertIntoManagedObjectContext:self.managedObjectContext];
            
            [recurrence setRecurrenceForTransaction:self.transaction withFrequency:self.frequency withAction:RECUR_ACTION_CREATE];
            
            // Save and dismiss/pop
            [[spnSpendTracker sharedManager] saveContext:self.managedObjectContext];
            
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
            [[spnSpendTracker sharedManager] saveContext:self.managedObjectContext];
            
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

#pragma mark - UITableViewDataSource

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
    
    // Must be in the same order as SpnTransactionViewCntlSectionIndexType
    NSArray* reuseIdentifier = [NSArray arrayWithObjects:
                                @"TrnsAmountCell",
                                @"TrnsMerchantCell",
                                @"TrnsCategoryCell",
                                @"TrnsSubCategoryCell",
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
                
            case MERCHANT_SECTION_IDX:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                // Buffer the transaction's merchant to the text field
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth-10, subViewHeight)];
                [textField setTag:MERCHANT_VIEW_TAG];
                [textField setText:[self.transaction merchant]];
                [textField setDelegate:self];
                [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [cell addSubview:textField];
                
                // Allow the autofiller to update this text field.
                self.autoFillTableViewController.textField = textField;
                
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
                
            case SUB_CATEGORY_SECTION_IDX:
                // Don't assign a reuse identifier since we want the cell to be dynamic
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                
                [cell.textLabel setText:self.subCategory_string];
                
                // Add chevron button
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell setTag:SUB_CATEGORY_VIEW_TAG];
                break;
                
            case DATE_SECTION_IDX:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                // Buffer the transaction's date to the text field if it is assigned to one. Otherwise assume today's date until user changes it.
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth-10, subViewHeight)];
                [textField setTag:DATE_VIEW_TAG];
                
                // If the date doesn't come from the passed in transaction
                if(!self.transaction.date)
                {
                    if (!self.date)
                    {
                        // This is a new transaction and no preferred date was specified
                        [self.transaction setDate:[NSDate date]];
                    }
                    else
                    {
                        // This is a new transaction and a preferred date was specified (specified by the calendar tab)
                        [self.transaction setDate:self.date];
                    }
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
        case SUB_CATEGORY_SECTION_IDX:
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
                           @"AMOUNT",
                           @"MERCHANT",
                           @"CATEGORY",
                           @"SUB-CATEGORY",
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
    // Must be in the same order as SpnTransactionViewCntlSectionIndexType
    NSArray* rowHeight = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:44],
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
            spnTableViewController_MainCategorySelect* categorySelectViewCntrl = [[spnTableViewController_MainCategorySelect alloc] initWithStyle:UITableViewStyleGrouped];
            categorySelectViewCntrl.title = @"Select Category";
            categorySelectViewCntrl.delegate = self;
            categorySelectViewCntrl.managedObjectContext = self.managedObjectContext;
            categorySelectViewCntrl.context = &mainCategorySetContext;
            
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:categorySelectViewCntrl];
            
            [self presentViewController:navController animated:YES completion:nil];
        }
            break;
            
        case SUB_CATEGORY_SECTION_IDX:
        {
            spnTableViewController_SubCategorySelect* categorySelectViewCntrl = [[spnTableViewController_SubCategorySelect alloc] initWithStyle:UITableViewStyleGrouped];
            categorySelectViewCntrl.title = @"Select Sub-Category";
            categorySelectViewCntrl.delegate = self;
            categorySelectViewCntrl.managedObjectContext = self.managedObjectContext;
            categorySelectViewCntrl.mainCategoryTitle = self.category_string;
            categorySelectViewCntrl.context = &subCategorySetContext;
            
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:categorySelectViewCntrl];
            
            [self presentViewController:navController animated:YES completion:nil];
        }
            break;
            
        case RECURRENCE_SECTION_IDX:
        {
            spnTableViewController_RecurSelect* recurrenceViewCntrl = [[spnTableViewController_RecurSelect alloc] initWithStyle:UITableViewStyleGrouped];
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

#pragma mark - UITextFieldDelegate

// <UITextFieldDelegate> methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSString *decimalSeperator = @".";
    NSString *text = textField.text;
    
    // lets the view controller know that this field is active - used in keyboard/view position management
    self.activeField = textField;
    
    switch (textField.tag)
    {
        case AMOUNT_VIEW_TAG:
        {

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
                numberFormatterCurrency.usesSignificantDigits = YES;
                numberFormatterCurrency.maximumSignificantDigits = 2;
            }
            
            // If the number is invalid, or it's zero, then clear the field
            NSNumber *number = [numberFormatterCurrency numberFromString:text];
            if ((number == nil) || (number.floatValue < 0.001))
            {
                textField.text = @"$";
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
                numberFormatterCurrency.usesSignificantDigits = YES;
                numberFormatterCurrency.maximumSignificantDigits = 2;
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
            
        case MERCHANT_VIEW_TAG:
        {
            NSString *substring = [NSString stringWithString:textField.text];
            substring = [substring stringByReplacingCharactersInRange:range withString:string];

            [self.autoFillTableViewController searchAutocompleteEntriesWithSubstring:substring];
            
            return YES;
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
        case MERCHANT_VIEW_TAG:
        {
            // Maintain the view controller's property
            [self setMerchant:textField.text];
            self.autoFillTableViewController.tableView.hidden = YES;
            
            // For newly created expenses only..
            if((self.transaction.type.integerValue == EXPENSE_TRANSACTION_TYPE) && self.isNew)
            {
                // Now attempt to set category and sub-category based on the merchant, if it was used before.
                // If merchant was used before, fills in the category and sub-category of most recent use:
                
                // Fetch transactions...
                NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SpnTransactionMO"];
                
                NSMutableArray* transactionArray;
                NSError* error;
                
                // ...with this merchant...
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(merchant MATCHES[cd] %@)", self.merchant];
                fetchRequest.predicate = predicate;
                
                // ...sorted by date, newest first.
                NSSortDescriptor *sortTransactionsByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
                [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortTransactionsByDate, nil]];
                
                // now execute the fetch
                transactionArray = [NSMutableArray arrayWithArray: [self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
                
                // If there were any transactions with this merchant name...
                if(transactionArray.count > 0)
                {
                    // Set category and sub-category based on first transaction in the list:
                    SpnTransaction* firstTransaction = transactionArray[0];
                    
                    [self setCategory_string:firstTransaction.subCategory.category.title];
                    [self setSubCategory_string:firstTransaction.subCategory.title];
                    
                    // The updates to the data supporting the table are complete
                    [self.tableView reloadData];
                }
            }
            
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
    self.frequencyWasUpdated = true;
    
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
            [[spnSpendTracker sharedManager] saveContext:self.managedObjectContext];
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
                    
                    [recurrence setRecurrenceForTransaction:copiedTransaction withFrequency:self.frequency withAction:RECUR_ACTION_CREATE];
                    
                    // Save and pop
                    [[spnSpendTracker sharedManager] saveContext:self.managedObjectContext];
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
            [[spnSpendTracker sharedManager] saveContext:self.managedObjectContext];
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
                    [[spnSpendTracker sharedManager] saveContext:self.managedObjectContext];
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
- (void)categorySetName:(NSString*)category_str context:(void *)context
{
    // Set the title string depending on the context
    if (context == &mainCategorySetContext)
    {
        self.category_string = category_str;
    }
    else if (context == &subCategorySetContext)
    {
        self.subCategory_string = category_str;
    }
    
    // The updates to the data supporting the table are complete
    [self.tableView reloadData];
}

//<AutoFillDelegate> methods
- (void)autoFillTable:(AutoFillTableViewController*)autoFillTable selectedEntry:(NSString*)entry
{
    if (autoFillTable == self.autoFillTableViewController)
    {
        self.merchant = entry;
    }
}

@end
