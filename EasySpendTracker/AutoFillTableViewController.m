//
//  AutoFillTableViewController.c
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/3/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "AutoFillTableViewController.h"


@implementation AutoFillTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.searchResults = [[NSMutableArray alloc] initWithCapacity:1];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.scrollEnabled = YES;
        self.tableView.hidden = YES;
        [self.tableView setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)createTableViewWithYPosition:(NSNumber *)yPosition
{
    self.tableView = [[UITableView alloc] initWithFrame:
                      CGRectMake(0, [yPosition intValue], 320, 200) style:UITableViewStylePlain];
    
    self.tableView.hidden = YES;
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring
{
    // compare everything in lower case
    substring = [substring lowercaseString];
    NSMutableArray *searchResults = [[NSMutableArray alloc] init];
    
    for (NSString* curString in self.sourceData)
    {
        NSString* lowerCaseCur = [curString lowercaseString];
        NSRange substringRange = [lowerCaseCur rangeOfString:substring];
        
        // If thr substring was found, buffer the string from the source data into the results array
        if (substringRange.location != NSNotFound)
        {
            [searchResults addObject:curString];
        }
    }
    
    // Only process results and display the table if there were any hits
    if (searchResults.count > 0)
    {
        // don't update search results if the input string is empty
        if (![substring isEqualToString:@""])
        {
            self.searchResults = [NSMutableArray arrayWithArray:searchResults];
            
            [self.tableView reloadData];
        }
        
        self.tableView.hidden = NO;
    }
    else
    {
        self.tableView.hidden = YES;
    }
}


//<UITableViewDataSource> methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section
{
    return self.searchResults.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:AutoCompleteRowIdentifier];
    }

    cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
    
    return cell;
}


//<UITableViewDelegate> methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self.delegate performSelector:@selector(autoFillTable:selectedEntry:) withObject:self withObject:selectedCell.textLabel.text];
    
    self.textField.text = selectedCell.textLabel.text;
    
    self.tableView.hidden = YES;
}



@end
