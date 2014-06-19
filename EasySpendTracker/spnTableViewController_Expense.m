//
//  spnTableViewController_Transaction.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/2/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Expense.h"
#import "UIView+spnViewCtgy.h"
#import "UIViewController+addTransactionHandles.h"
#import "SpnTransaction.h"
#import "SpnTransactionCategory.h"
#import "spnUtils.h" 

@interface spnTableViewController_Expense ()

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
    NUM_SECTIONS
};

enum
{
    AMOUNT_VIEW_TAG,
    MERCHANT_VIEW_TAG,
    CATEGORY_VIEW_TAG,
    DATE_VIEW_TAG,
    DESCRIPTION_VIEW_TAG
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
    
    [self.view addGestureRecognizer:tap];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(spnEditButtonClicked:)];
    
    // Date is required
    if(!self.transaction.date)
    {
        [self.transaction setDate:[NSDate date]];
        [self.transaction setSectionName:[[[spnUtils sharedUtils] dateFormatterMonthDayYear] stringFromDate:[self.transaction date]]];
    }
    
    // Category is required
    if(!self.transaction.category)
    {
//        SpnMonth* month = [SpnMonth fetchMonthWithDate:self.transaction.date inManagedObjectContext:self.managedObjectContext];
        SpnTransactionCategory* newCategory = [SpnTransactionCategory fetchCategoryWithName:DEFAULT_CATEGORY_TITLE inManagedObjectContext:self.managedObjectContext];
        
        // Assign new category to transaction
//        [self.transaction setCategory:newCategory];
        [newCategory addTransactionsObject:self.transaction];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self saveContext:self.managedObjectContext];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Only applicable when adding a transaction, button does not appear when viewing/editting
//   an existing one.
- (void)doneButtonClicked: (id)sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// Only applicable when adding a transaction, button does not appear when viewing/editting
//   an existing one.
- (void)cancelButtonClicked: (id)sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        SpnTransactionCategory* category = self.transaction.category;
   
        // Remove the category if this is the only transaction
        if(category.transactions.count == 1)
        {
            [self.managedObjectContext deleteObject:category];
        }
        else
        {
            // Just remove the transaction that was created for this add
            [self.managedObjectContext deleteObject:self.transaction];
        }
        
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
            case AMOUNT_SECTION_IDX:
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth, subViewHeight)];
                [textField setTag:AMOUNT_VIEW_TAG];
                [textField setText:[NSString stringWithFormat:@"$%.2f", [self.transaction.value floatValue]]];
                [textField setDelegate:self];
                [cell addSubview:textField];
                break;
                
            case MERCHANT_SECTION_IDX:
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth, subViewHeight)];
                [textField setTag:MERCHANT_VIEW_TAG];
                [textField setText:[self.transaction merchant]];
                [textField setDelegate:self];
                [cell addSubview:textField];
                break;
                
            case CATEGORY_SECTION_IDX:
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth, subViewHeight)];
                [textField setTag:CATEGORY_VIEW_TAG];
                [textField setText:[[self.transaction category] title]];
                [textField setDelegate:self];
                [cell addSubview:textField];
                break;
                
            case DATE_SECTION_IDX:
                textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth, subViewHeight)];
                [textField setTag:DATE_VIEW_TAG];
                [textField setText:[[[spnUtils sharedUtils] dateFormatterMonthDayYear] stringFromDate:[self.transaction date]]];
                [textField setDelegate:self];
                [textField setInputView:[self.view datePickerView]];
                [cell addSubview:textField];
                break;
                
            case DESCRIPTION_SECTION_IDX:
                textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, subViewWidth, subViewHeight)];
                [textView setTag:DESCRIPTION_VIEW_TAG];
                [textView setText:[self.transaction notes]];
                [textView setEditable:YES];
                [textView setDelegate:self];
                [cell addSubview:textView];
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
                           [NSNumber numberWithFloat:150],
                           nil];

    return (CGFloat)[rowHeight[indexPath.section] floatValue];
}

// <UITextFieldDelegate> methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case AMOUNT_VIEW_TAG:
        {
            NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [formatter setCurrencyCode:@"USD"];
            NSNumber* newValue = [formatter numberFromString:textField.text];
            newValue = ((!newValue.floatValue) ? [NSNumber numberWithFloat:0.0] : newValue);

            // Assign new value to transaction
            [self.transaction setValue:newValue];
        }
            break;
            
        case MERCHANT_VIEW_TAG:
        {
            [self.transaction setMerchant:textField.text];
        }
            break;
            
        case CATEGORY_VIEW_TAG:
        {
            NSString* newCategoryName = (textField.text.length > 0) ? textField.text : DEFAULT_CATEGORY_TITLE;
            textField.text = newCategoryName;
            
            // Assign new category to transaction
//            SpnMonth* month = [SpnMonth fetchMonthWithDate:self.transaction.date inManagedObjectContext:self.managedObjectContext];
            SpnTransactionCategory* newCategory = [SpnTransactionCategory fetchCategoryWithName:newCategoryName inManagedObjectContext:self.managedObjectContext];
            
            // Move transaction to new category
            [self transaction:self.transaction moveToCategory:newCategory];
        }
            break;
            
        case DATE_VIEW_TAG:
        {
            [self.transaction setDate:[[[spnUtils sharedUtils] dateFormatterMonthDayYear] dateFromString:textField.text]];
            [self.transaction setSectionName:textField.text];
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
            [self.transaction setNotes:textView.text];
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
        // Assign new category to transaction
        //[self.transaction setCategory:category];
        [category addTransactionsObject:transaction];
        
        // Add the transaction to the new category
        //[category setTotal:[NSNumber numberWithFloat:[[category total] floatValue] + [[self.transaction value] floatValue]]];
        
        // Add to the total expenses of the month
        //[category.month setTotalExpenses:[NSNumber numberWithFloat:[[category.month totalExpenses] floatValue] + [[self.transaction value] floatValue]]];
        
        // Delete old category if it's now empty
        if(originalCategory.transactions.count == 0)
        {
            //SpnMonth* month = originalCategory.month;
            
            // Delete category object
            [self.managedObjectContext deleteObject:originalCategory];
            
            // Delete month object if this was the last category
            //if(month.categories.count == 0)
            {
            //    [self.managedObjectContext deleteObject:month];
            }
            //else
            {
                //[month setTotalExpenses:[NSNumber numberWithFloat:[[month totalExpenses] floatValue] - [[self.transaction value] floatValue]]];
            }
        }
        else
        {
            // Subtract transaction from original category
            //[originalCategory setTotal:[NSNumber numberWithFloat:[[originalCategory total] floatValue] - [[self.transaction value] floatValue]]];
            
            // Subtract transaction value from month
            //[originalCategory.month setTotalExpenses:[NSNumber numberWithFloat:[[originalCategory.month totalExpenses] floatValue] + [[self.transaction value] floatValue]]];
        }
    }
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
