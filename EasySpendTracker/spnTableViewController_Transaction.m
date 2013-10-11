//
//  spnTableViewController_Transaction.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 10/2/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_Transaction.h"
#import "UIView+spnViewCategory.h"
#import "UIViewController+addTransactionHandles.h"

@interface spnTableViewController_Transaction ()

@end

@implementation spnTableViewController_Transaction

#define MERCHANT_ROW_IDX 0
#define VALUE_ROW_IDX 1
#define DATE_ROW_IDX 2
#define DESCRIPTION_ROW_IDX 3

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(spnEditButtonClicked:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// <UITableViewDataSource> methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    [cell.detailTextLabel setTextColor:[UIColor blueColor]];
    
    // Configure the cell...
    switch (indexPath.row)
    {
        case MERCHANT_ROW_IDX:
            [cell.textLabel setText:@"Merchant"];
            [cell.detailTextLabel setText:[self.transaction merchant]];
            break;
            
        case VALUE_ROW_IDX:
            [cell.textLabel setText:@"Amount"];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"$%.2f", [self.transaction.value floatValue]]];
            break;
            
        case DATE_ROW_IDX:
            [cell.textLabel setText:@"Date"];
            [cell.detailTextLabel setText:[[self.view dateFormatterMonthDayYear] stringFromDate:[self.transaction date]]];
            break;
            
        case DESCRIPTION_ROW_IDX:
            cell = [cell initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            [cell.textLabel setText:@"Description"];
            [cell.detailTextLabel setText:[self.transaction notes]];
            [cell.detailTextLabel setNumberOfLines:15];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
            [cell.detailTextLabel setTextAlignment:NSTextAlignmentLeft];
            break;
            
        default:
            break;
    }
    
    return cell;
}

// <UITableViewDelegate> methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 //   [self.tableView cellForRowAtIndexPath:indexPath] detailTextLabel
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    
    if (indexPath.row == DESCRIPTION_ROW_IDX)
    {
        height = 250;
    }
    else
    {
        height = 44;
    }
    
    return height;
}

// <spnAddTransactionDelegate> methods
- (Transaction*)transactionForEdit
{
    return self.transaction;
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
