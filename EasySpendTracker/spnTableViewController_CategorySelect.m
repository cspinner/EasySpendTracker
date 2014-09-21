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
    CREATE_SECTION_IDX,
    EXISTING_SECTION_IDX,
    NUM_SECTIONS
};

// Texfield/view tags
enum
{
    MANUAL_INPUT_VIEW_TAG = 1
};

@property NSString* categoryTitleManualInput;
@property NSDictionary* headerText;
@property NSDictionary* cellReuseIdentifier;

// For search
@property (nonatomic, strong) UISearchDisplayController* mySearchDisplayController;
@property UISearchBar* searchBar;
@property NSMutableArray* searchResults;

@end

#define CELL_HEIGHT 44.0

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
    
    // search bar init
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, CELL_HEIGHT)];
    [self.searchBar setDelegate:self];
    [self.searchBar setPlaceholder:@"Search for category"];
    
    // search display controller
    self.mySearchDisplayController = [[UISearchDisplayController alloc]
                                      initWithSearchBar:self.searchBar contentsController:self];
    [self.mySearchDisplayController setDelegate:self];
    [self.mySearchDisplayController setSearchResultsDataSource:self];
    [self.mySearchDisplayController setSearchResultsDelegate:self];
    
    // initialize empty search results array
    self.searchResults = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Initialize properties
    self.categoryTitleManualInput = @"";
    
    self.headerText = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                           @"CREATE NEW",@"CHOOSE EXISTING",nil]
        forKeys:[NSArray arrayWithObjects:
        [NSString stringWithFormat:@"%d", CREATE_SECTION_IDX],
        [NSString stringWithFormat:@"%d", EXISTING_SECTION_IDX], nil]];
    
    self.cellReuseIdentifier = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                           @"CatCreateCell",@"CatTitleCell",nil]
        forKeys:[NSArray arrayWithObjects:
        [NSString stringWithFormat:@"%d", CREATE_SECTION_IDX],
        [NSString stringWithFormat:@"%d", EXISTING_SECTION_IDX], nil]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Display the search bar
    [self.tableView setTableHeaderView:self.searchBar];
    
    [self.tableView reloadData];
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
    if (self.tableView == tableView)
    {
        return NUM_SECTIONS;
    }
    else // self.searchDisplayController.searchResultsTableView
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    if (self.tableView == tableView)
    {
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
    }
    else // self.searchDisplayController.searchResultsTableView
    {
        count = self.searchResults.count;
    }
    
    return count;
}

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case EXISTING_SECTION_IDX:
        {
            [cell.textLabel setText:[[self.categoryTitleDictionaryArray objectAtIndex:indexPath.row] objectForKey:@"title"]];
        }
            break;
            
        case CREATE_SECTION_IDX:
        {
            UITextField* textField = (UITextField*)[cell viewWithTag:MANUAL_INPUT_VIEW_TAG];
            [textField setText:self.categoryTitleManualInput];
        }
            break;
            
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView == tableView)
    {
        // Attempt to reuse a cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self.cellReuseIdentifier valueForKey:[NSString stringWithFormat:@"%ld", indexPath.section]]];
        
        if (!cell)
        {
            switch (indexPath.section)
            {
                case EXISTING_SECTION_IDX:
                {
                    // Create cell if reuse cell doesn't exist.
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self.cellReuseIdentifier valueForKey:[NSString stringWithFormat:@"%ld", indexPath.section]]];
                }
                    break;
                    
                case CREATE_SECTION_IDX:
                {
                    // Create cell - don't use the reuse identifier since this should be dynamic
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    
                    CGFloat subViewWidth = tableView.frame.size.width;
                    CGFloat subViewHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
                    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, subViewWidth-10, subViewHeight)];
                    
                    [textField setTag:MANUAL_INPUT_VIEW_TAG];
                    [textField setInputView:UIKeyboardTypeDefault];
                    [textField setReturnKeyType:UIReturnKeyDone];
                    [textField setDelegate:self];

                    [cell addSubview:textField];
                }
                    break;
                    
                default:
                    break;
            }
        }
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    }
    else // self.searchDisplayController.searchResultsTableView
    {
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        [cell.textLabel setText:[[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"title"]];
        
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

// <UITableViewDelegate> methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.tableView == tableView)
    {
        UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
        UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width, headerView.frame.size.height)];
        
        // Set text based on section index
        [headerLabel setText:[self.headerText valueForKey:[NSString stringWithFormat:@"%ld", (long)section]]];
        [headerLabel setFont:[UIFont systemFontOfSize:12]];
        [headerLabel setTextColor:[UIColor grayColor]];
        
        [headerView addSubview:headerLabel];
        
        return headerView;
    }
    else // self.searchDisplayController.searchResultsTableView
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.tableView == tableView)
    {
        return 25;
    }
    else // self.searchDisplayController.searchResultsTableView
    {
        return 0.001;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(categorySetName:context:)])
    {
        if (self.tableView == tableView)
        {
            [self.delegate categorySetName:[[self.categoryTitleDictionaryArray objectAtIndex:indexPath.row] objectForKey:@"title"] context:self.context];
        }
        else // self.searchDisplayController.searchResultsTableView
        {
            [self.delegate categorySetName:[[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"title"] context:self.context];
        }
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

//<UISearchDisplayDelegate> methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scopeButtonIndex:[self.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scopeButtonIndex:searchOption];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scopeButtonIndex:(NSInteger)scopeButtonIndex
{
    // Remove all objects from the filtered search array
    [self.searchResults removeAllObjects];
    
    NSArray* fetchedObjects = self.categoryTitleDictionaryArray;
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchText];
    
    self.searchResults = [NSMutableArray arrayWithArray:[fetchedObjects filteredArrayUsingPredicate:predicate]];
}


@end
