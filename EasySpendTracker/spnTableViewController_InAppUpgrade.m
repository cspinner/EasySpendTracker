//
//  spnTableViewController_InAppUpgrade.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 1/14/15.
//  Copyright (c) 2015 Christopher Spinner. All rights reserved.
//

#import "spnTableViewController_InAppUpgrade.h"
#import "spnInAppPurchaseManager.h"
#import "StoreKit/StoreKit.h"

@interface spnTableViewController_InAppUpgrade ()

@property NSArray* iapProducts;

@property NSNumberFormatter* priceFormatter;

@end

@implementation spnTableViewController_InAppUpgrade

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.title = @"In App Purchases";
    
    // Add navigation button used to restore product that was purchased on another device
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStylePlain target:self action:@selector(restoreButtonTapped:)];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // initialize the price formatter
    self.priceFormatter = [[NSNumberFormatter alloc] init];
    self.priceFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    self.priceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:spnInAppProductPurchasedNotification object:nil];
    
    // Reloading indicator
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadPurchases) forControlEvents:UIControlEventValueChanged];
    [self reloadPurchases];
    [self.refreshControl beginRefreshing];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification
{
    NSString * productIdentifier = notification.object;
    
    [self.iapProducts enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier])
        {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
}

- (void)reloadPurchases
{
    self.iapProducts = nil;
    [self.tableView reloadData];
    
    // Commence products request
    [[spnInAppPurchaseManager sharedManager] requestProductsWithCompletionHandler:^(BOOL success, NSArray * products){
        if (success)
        {
            self.iapProducts = products;
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)buyButtonTapped:(id)sender
{
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = self.iapProducts[buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[spnInAppPurchaseManager sharedManager] buyProduct:product];
}

- (void)restoreButtonTapped:(id)sender
{
    [[spnInAppPurchaseManager sharedManager] restoreCompletedTransactions];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.iapProducts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"IAPCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell)
    {
        // Create the cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    
    // Configure the cell...
    SKProduct * product = (SKProduct *) self.iapProducts[indexPath.row];
    self.priceFormatter.locale = product.priceLocale;
    
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = [self.priceFormatter stringFromNumber:product.price];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // If the product was purchased, display checkmark
    if ([[spnInAppPurchaseManager sharedManager] productPurchased:product.productIdentifier])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    }
    else // otherwise, display button used to purchase it
    {
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buyButton.frame = CGRectMake(0, 0, 72, 37);
        [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
        buyButton.tag = indexPath.row;
        [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}



@end
