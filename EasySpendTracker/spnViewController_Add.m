//
//  spnViewController_Add.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/22/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "spnViewController_Add.h"
#import "UIViewController+addTransactionHandles.h"
#import "UIView+spnViewCategory.h"
#import "SpnTransaction.h"
#import "SpnSpendCategory.h"
#import "spnSpendTracker.h"

@interface spnViewController_Add ()

@property SpnTransaction* fillTransaction;
@property UITextField* valueField;
@property UITextField* categoryField;
@property UITextField* merchantField;
@property UIDatePicker* datePicker;
@property UITextField* dateField;
@property NSDate* date;
@property UITextView* descriptionView;

@end

@implementation spnViewController_Add

#define DEFAULT_CATEGORY_TITLE @"Uncategorized"

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)loadView
{
    // Create the view and store it to the view property of the controller
    // frame = width: 320.000000, height: 548.000000
    CGRect navCtrlFrame = self.navigationController.navigationBar.frame;
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];

    self.view = [[UIView alloc] initWithFrame:CGRectMake(appFrame.origin.x, navCtrlFrame.origin.y + navCtrlFrame.size.height, appFrame.size.width, appFrame.size.height)];
    [self.view setBackgroundColor:[UIColor cyanColor]];
    
    // Add done and cancel buttons
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = cancelButton;

    // Create subviews next - i.e. labels, buttons, text fields...
    UILabel* valueLabel = [[UILabel alloc] init];
    UILabel* categoryLabel = [[UILabel alloc] init];
    UILabel* descriptionLabel = [[UILabel alloc] init];
    UILabel* targetAccountLabel = [[UILabel alloc] init];
    UILabel* dateLabel = [[UILabel alloc] init];
    UILabel* merchantLabel = [[UILabel alloc] init];
   
    [valueLabel setText:@"Amount"];
    [valueLabel setFont:[UIFont systemFontOfSize:10]];
    [valueLabel sizeToFit];
    valueLabel.frame = CGRectMake(self.view.frame.origin.x+10, self.view.frame.origin.y, valueLabel.frame.size.width, valueLabel.frame.size.height);
    self.valueField = [[UITextField alloc] initWithFrame:CGRectMake(valueLabel.frame.origin.x, valueLabel.frame.origin.y + valueLabel.frame.size.height, 150, 21)];
    self.valueField.backgroundColor = [UIColor whiteColor];
    self.valueField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"$0.00"];
    self.valueField.borderStyle = UITextBorderStyleRoundedRect;
    self.valueField.delegate = self;
    
    [merchantLabel setText:@"Merchant"];
    [merchantLabel setFont:[UIFont systemFontOfSize:10]];
    [merchantLabel sizeToFit];
    merchantLabel.frame = CGRectMake(self.view.frame.origin.x+10, self.valueField.frame.origin.y + self.valueField.frame.size.height + 15, merchantLabel.frame.size.width, merchantLabel.frame.size.height);
    self.merchantField = [[UITextField alloc] initWithFrame:CGRectMake(merchantLabel.frame.origin.x, merchantLabel.frame.origin.y + merchantLabel.frame.size.height, 150, 21)];
    self.merchantField.backgroundColor = [UIColor whiteColor];
    self.merchantField.borderStyle = UITextBorderStyleRoundedRect;
    self.merchantField.delegate = self;

    [categoryLabel setText:@"Category"];
    [categoryLabel setFont:[UIFont systemFontOfSize:10]];
    [categoryLabel sizeToFit];
    categoryLabel.frame = CGRectMake(self.view.frame.origin.x+10, self.merchantField.frame.origin.y + self.merchantField.frame.size.height + 15, categoryLabel.frame.size.width, categoryLabel.frame.size.height);
    self.categoryField = [[UITextField alloc] initWithFrame:CGRectMake(categoryLabel.frame.origin.x, categoryLabel.frame.origin.y + categoryLabel.frame.size.height, 150, 21)];
    self.categoryField.backgroundColor = [UIColor whiteColor];
    self.categoryField.borderStyle = UITextBorderStyleRoundedRect;
    self.categoryField.delegate = self;
    
    [dateLabel setText:@"Date of Transaction"];
    [dateLabel setFont:[UIFont systemFontOfSize:10]];
    [dateLabel sizeToFit];
    dateLabel.frame = CGRectMake(self.view.frame.origin.x+10, self.categoryField.frame.origin.y + self.categoryField.frame.size.height + 15, dateLabel.frame.size.width, dateLabel.frame.size.height);
    UIView* datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 288, 320, 260)];
    UIToolbar *datePickerViewToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem* dateToolbarCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dateCancelButtonClicked:)];
    UIBarButtonItem* dateToolbarSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* dateToolbarDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dateDoneButtonClicked:)];
    [datePickerViewToolbar setItems:[NSArray arrayWithObjects:dateToolbarCancelButton, dateToolbarSpacer, dateToolbarDoneButton, nil]];
    self.date = [NSDate date];
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 320, 216)];
	[self.datePicker setDatePickerMode:UIDatePickerModeDate];
	[self.datePicker setDate:self.date];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    [datePickerView addSubview:datePickerViewToolbar];
    [datePickerView addSubview:self.datePicker];

    self.dateField = [[UITextField alloc] initWithFrame:CGRectMake(dateLabel.frame.origin.x, dateLabel.frame.origin.y + dateLabel.frame.size.height, 150, 21)];
    self.dateField.backgroundColor = [UIColor whiteColor];
    self.dateField.delegate = self;
    self.dateField.inputView = datePickerView;
    self.dateField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[[spnSpendTracker sharedManager] dateFormatterMonthDayYear] stringFromDate:[NSDate date]]];

    [descriptionLabel setText:@"Description"];
    [descriptionLabel setFont:[UIFont systemFontOfSize:10]];
    [descriptionLabel sizeToFit];
    descriptionLabel.frame = CGRectMake(self.view.frame.origin.x+10, self.dateField.frame.origin.y + self.dateField.frame.size.height + 15, descriptionLabel.frame.size.width, descriptionLabel.frame.size.height);
    self.descriptionView = [[UITextView alloc] initWithFrame:CGRectMake(descriptionLabel.frame.origin.x, descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height, 300, 200)];
    self.descriptionView.backgroundColor = [UIColor whiteColor];
    self.descriptionView.delegate = self;
    
    [targetAccountLabel setText:@"Target Account"];
    [targetAccountLabel sizeToFit];

    
    // Add the subviews to the view
    [self.view addSubview:valueLabel];
    [self.view addSubview:self.valueField];
    [self.view addSubview:merchantLabel];
    [self.view addSubview:self.merchantField];
    [self.view addSubview:categoryLabel];
    [self.view addSubview:self.categoryField];
    [self.view addSubview:dateLabel];
    [self.view addSubview:self.dateField];
    [self.view addSubview:descriptionLabel];
    [self.view addSubview:self.descriptionView];
    //[self.view addSubview:targetAccountLabel];
    
}

- (void)doneButtonClicked: (id)sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        // Collect data and provide to delegate
        SpnTransaction* transaction = (SpnTransaction*)[NSEntityDescription                                                  insertNewObjectForEntityForName:@"SpnTransaction"                                                  inManagedObjectContext:[[spnSpendTracker sharedManager] managedObjectContext]];
        
        NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber* value = [formatter numberFromString:self.valueField.text];
        value = ((!value.floatValue) ? [NSNumber numberWithFloat:0.0] : value);
        
        transaction.uniqueId = [NSNumber numberWithLong:arc4random()];
        transaction.value = value;
        transaction.merchant = self.merchantField.text;
        transaction.notes = self.descriptionView.text;
        //transaction.targetAccount = nil;
        transaction.date = self.date;
        transaction.sectionName = [[[spnSpendTracker sharedManager] dateFormatterMonthDayYear] stringFromDate:self.date];
        NSString* category = (self.categoryField.text.length > 0) ? self.categoryField.text : DEFAULT_CATEGORY_TITLE;
 
        [self.delegate spnAddViewControllerDidFinish:self withNewEntry:transaction fromOldEntry:self.fillTransaction withCategory:category fromOldCategory:[self.fillTransaction.category title]];
    }
}

- (void)cancelButtonClicked: (id)sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        [self.delegate spnAddViewControllerDidFinish:self withNewEntry:nil fromOldEntry:nil withCategory:nil fromOldCategory:nil];
    }
}

- (void)dateDoneButtonClicked:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]])
    {
        self.date = [self.datePicker date];
        [self.dateField setText:[[[spnSpendTracker sharedManager] dateFormatterMonthDayYear] stringFromDate:self.date]];
        [self.dateField resignFirstResponder];
    }
}

- (void)dateCancelButtonClicked:(id)sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        [self.dateField resignFirstResponder];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Check the delegate if the fields must be prepopulated with an existing transaction
    if([self.delegate respondsToSelector:@selector(transactionForEdit)])
    {
        self.fillTransaction = [self.delegate transactionForEdit];
        if(self.fillTransaction)
        {
            [self.valueField setText:[NSString stringWithFormat:@"$%.2f", [self.fillTransaction.value floatValue]]];
            [self.categoryField setText:[self.fillTransaction.category title]];
            [self.merchantField setText:[self.fillTransaction merchant]];
            [self.dateField setText:[[[spnSpendTracker sharedManager] dateFormatterMonthDayYear] stringFromDate:[self.fillTransaction date]]];
            [self.descriptionView setText:[self.fillTransaction notes]];
            self.date = [self.fillTransaction date];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// <UITextFieldDelegate> methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.categoryField)
    {
        [textField setText:[textField.text capitalizedString]];
    }
    
    [textField resignFirstResponder];
    
    return YES;
}

// <UITextViewDelegate> methods
//- (BOOL)textViewShouldEndEditing:(UITextView *)textView
//{
//    //[textView resignFirstResponder];
//    return YES;
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    UIView* firstResponderView = [self.view spnFirstResponder];
    
    // Resign first repsonder status if touching outside of the subview that has
    // first responder status.
    if ([touch view] != firstResponderView)
    {
        [firstResponderView resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}



@end
