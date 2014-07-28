//
//  spnViewController_CategorySelect.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/19/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_CategorySelect.h"
#import "UIView+spnViewCtgy.h"

@interface spnTableViewController_CategorySelect ()

// Section enums
enum
{
    EXISTING_SECTION_IDX,
    CREATE_SECTION_IDX,
    NUM_SECTIONS
};

// Texfield/view tags
enum
{
    MANUAL_INPUT_VIEW_TAG = 1
};

@property NSString* categoryTitleManualInput;

@end

@implementation spnTableViewController_CategorySelect

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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Add cancel button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];
    
    self.categoryTitleManualInput = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonClicked: (id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// <UITableViewDataSource> methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    switch (section)
    {
        case EXISTING_SECTION_IDX:
        {
            // size of the title array
            count = [self.categoryTitleDictionaryArray count];
        }
            break;
            
        case CREATE_SECTION_IDX:
        {
            // just 1 row
            count = 1;
        }
            break;
            
        default:
            return count;
            break;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* reuseIdentifier = [NSArray arrayWithObjects:
                                @"CatTitleCell",
                                @"CatCreateCell",
                                nil];
    
    // Attempt to reuse a cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier[indexPath.section]];
    
    if (!cell)
    {
        switch (indexPath.section)
        {
            case EXISTING_SECTION_IDX:
            {
                // Create cell if reuse cell doesn't exist.
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier[indexPath.section]];
                
                [cell.textLabel setText:[[self.categoryTitleDictionaryArray objectAtIndex:indexPath.row] objectForKey:@"title"]];
            }
                break;
                
            case CREATE_SECTION_IDX:
            {
                // Create cell - don't use th reuse identifier since this should be dynamic
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                
                CGFloat subViewWidth = tableView.frame.size.width;
                CGFloat subViewHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
                UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth-10, subViewHeight)];
                
                [textField setTag:MANUAL_INPUT_VIEW_TAG];
                [textField setInputView:UIKeyboardTypeDefault];
                [textField setReturnKeyType:UIReturnKeyDone];
                [textField setDelegate:self];
                [textField setText:self.categoryTitleManualInput];
                
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
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width, headerView.frame.size.height)];
    
    NSArray* headerText = [NSArray arrayWithObjects:
                           @"CHOOSE EXISTING",
                           @"CREATE NEW",
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(categorySetName:context:)])
    {
        [self.delegate categorySetName:[[self.categoryTitleDictionaryArray objectAtIndex:indexPath.row] objectForKey:@"title"] context:self.context];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// <UITextFieldDelegate> methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(categorySetName:context:)])
    {
        [self.delegate categorySetName:self.categoryTitleManualInput context:self.context];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    // will not return
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case MANUAL_INPUT_VIEW_TAG:
        {
            // Maintain the view controller's property
            [self setCategoryTitleManualInput:textField.text];
        }
            break;
        
        default:
            break;
    }
}


@end
