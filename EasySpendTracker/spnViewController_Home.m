//
//  spnViewController_Home.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/21/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnViewController_Home.h"
#import "UIViewController+addTransactionHandles.h"
#import "SpnTransaction.h"
//#import "SpnMonth.h"
#import "SpnSpendCategory.h"

@interface spnViewController_Home ()
@property UITextView* textView;

@end

@implementation spnViewController_Home

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(spnAddButtonClicked:)];
}

- (void)loadView
{
    // Create the view and store it to the view property of the controller
    // frame = width: 320.000000, height: 548.000000
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Create subviews next - i.e. labels, buttons, text fields...
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 300, 548)];
    
    // Create button object, set text, display frame, and action
    [self.textView setFont:[UIFont systemFontOfSize:10.0]];
    [self.view addSubview:self.textView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSError* error;
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnSpendCategoryMO"];
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext                                                executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    NSMutableString* text = [[NSMutableString alloc] init];
    
    // First line
    [text appendFormat:@"Categories:\n"];
    
    // Add summary text for each category
    for(SpnSpendCategory* category in mutableFetchResults)
    {
        [text appendFormat:@"   %@ - $%.2f - %lu transactions:\n", category.title, category.total.floatValue, (unsigned long)category.transactions.count];
        
        for(SpnTransaction* transaction in category.transactions)
        {
            [text appendFormat:@"       %@ - %@ - $%.2f - %@\n", transaction.sectionName, transaction.merchant, transaction.value.floatValue, category.title];
        }
    }
    
    [self.textView setText:text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
