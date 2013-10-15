//
//  spnViewController_Home.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/21/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnViewController_Home.h"
#import "spnViewController_Add.h"
#import "UIViewController+addTransactionHandles.h"
#import "SpnTransaction.h"
#import "spnSpendTracker.h"

@interface spnViewController_Home ()
@property UILabel* label;

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(spnAddButtonClicked:)];
}

- (void)loadView
{
    // Create the view and store it to the view property of the controller
    // frame = width: 320.000000, height: 548.000000
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Create subviews next - i.e. labels, buttons, text fields...
    
    // Create button object, set text, display frame, and action
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(200, 300, 75, 44)];
    [button setTitle:@"Press" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(200, 364, 75, 44)];
    [self.label setText:@"None"];
    
    [self.view addSubview:button];
    [self.view addSubview:self.label];
    
}

- (void)buttonPressed:(id)sender
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SpnTransaction"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SpnTransaction"
                                              inManagedObjectContext:[[spnSpendTracker sharedManager] managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[[[spnSpendTracker sharedManager] managedObjectContext]
                                            executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if (mutableFetchResults == nil)
    {
        
    }
    else
    {
        if(mutableFetchResults.count == 0)
        {
            SpnTransaction* transaction = (SpnTransaction*)[NSEntityDescription
                                                      insertNewObjectForEntityForName:@"SpnTransaction"
                                                      inManagedObjectContext:[[spnSpendTracker sharedManager] managedObjectContext]];
            transaction.merchant = @"Wegmans";
            
            if (![[[spnSpendTracker sharedManager] managedObjectContext] save:&error]) {
                // Handle the error.
            }
        }
        else
        {
            [self.label setText:[((SpnTransaction*)[mutableFetchResults objectAtIndex:0]) merchant]];
        }
    }
    
    
    
    
    
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
