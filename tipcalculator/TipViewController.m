//
//  TipViewController.m
//  tipcalculator
//
//  Created by Casing Chu on 1/16/15.
//  Copyright (c) 2015 casing. All rights reserved.
//

#import "TipViewController.h"
#import "SettingsViewController.h"

@interface TipViewController ()

@property (weak, nonatomic) IBOutlet UITextField *billTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipControl;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property SettingsViewController *settingsViewController;
@property NSMutableArray *tipValues;
@property NSNumberFormatter *currencyFormatter;

- (IBAction)onTap:(id)sender;
- (void)updateValues;
- (void)onSettingsButton;
- (void)saveDefaults;
- (void)restoreDefaults;
- (BOOL)isLastBillTextExpired;
- (float)getBillValue;
- (void)applyTheme;
- (void)displayStatus;
- (NSString*)getCurrencyString:(float)value;

@end

@implementation TipViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Tip Calculator";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currencyFormatter = [[NSNumberFormatter alloc] init];
    [self.currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [self.currencyFormatter setMaximumFractionDigits:2];
    [self.currencyFormatter setMinimumFractionDigits:2];
    self.tipValues = [[NSMutableArray alloc] init];
    self.settingsViewController = [[SettingsViewController alloc] init];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onSettingsButton)];
    [self restoreDefaults];
}

- (void)viewWillAppear:(BOOL)animated {
    [self restoreDefaults];
    [self applyTheme];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTap:(id)sender
{
    [self.view endEditing:YES];
    [self updateValues];
    [self displayStatus];
}

- (float)getBillValue {
    NSString *textFieldStr = [NSString stringWithFormat:@"%@", self.billTextField.text];
    
    NSMutableString *textFieldStrValue = [NSMutableString stringWithString:textFieldStr];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    [textFieldStrValue replaceOccurrencesOfString:numberFormatter.currencySymbol
                                       withString:@""
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, [textFieldStrValue length])];
    
    [textFieldStrValue replaceOccurrencesOfString:numberFormatter.groupingSeparator
                                       withString:@""
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, [textFieldStrValue length])];
    
    NSDecimalNumber *textFieldNum = [NSDecimalNumber decimalNumberWithString:textFieldStrValue];
    return [textFieldNum floatValue];
}

- (void)displayStatus {
    
    float tipValue = [self.tipValues[self.tipControl.selectedSegmentIndex] floatValue];
    if (tipValue >= 0.2) {
        // Fade In
        self.statusView.alpha = 0;
        [UIView animateWithDuration:2.0 animations:^{
            self.statusView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
        
        // Fade Out
        self.statusView.alpha = 1;
        [UIView animateWithDuration:2.0 animations:^{
            self.statusView.alpha = 0;
        } completion:^(BOOL finished) {
        }];
    }
}

- (NSString*)getCurrencyString:(float)value {
    NSDecimalNumber *currencyDecimalNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%0.2f", value]];
    return [self.currencyFormatter stringFromNumber:currencyDecimalNumber];
}

- (void)updateValues
{
    float billAmount = [self getBillValue];
    
    float tipAmount = billAmount * [self.tipValues[self.tipControl.selectedSegmentIndex] floatValue];
    float totalAmount = billAmount + tipAmount;

    self.tipLabel.text = [self getCurrencyString:tipAmount];
    self.totalLabel.text = [self getCurrencyString:totalAmount];
    
    [self saveDefaults];
}

- (void)onSettingsButton
{
    [self.view endEditing:YES];
    [self.navigationController pushViewController:[self settingsViewController] animated:YES];
}


- (void)saveDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:self.billTextField.text forKey:@"previousBill"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.tipControl.selectedSegmentIndex forKey:@"defaultTipIndex"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastSaved"];//Store current date
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isLastBillTextExpired {
    
    NSDate *lastSaved = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSaved"];
    NSDate *current = [NSDate date];
    NSTimeInterval secondsBetweenDates = [current timeIntervalSinceDate:lastSaved];
    
    if (secondsBetweenDates > 600) { //10 Minutes before values expires
        return YES;
    }
    
    return NO;
}

-(void)applyTheme {
    int themeId = [[NSUserDefaults standardUserDefaults] integerForKey:@"themeId"];
    if(themeId == 0) {
        // Light Theme
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    } else if(themeId == 1) {
        // Dark Theme
        [self.view setBackgroundColor:[UIColor lightGrayColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor lightGrayColor]];
    }
}

- (void)restoreDefaults
{
    
    // Restore last Bill value if value has not yet expired
    if ([self isLastBillTextExpired]) {
        [self.billTextField setText:@"$0.00"];
    } else {
        NSString *previousBill = [[NSUserDefaults standardUserDefaults] objectForKey:@"previousBill"];
        [self.billTextField setText:previousBill];
    }
    
    // Restore the last value tip value selected
    int intValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"defaultTipIndex"];
    [self.tipControl setSelectedSegmentIndex:intValue];
    
    // Restore all the custom tip values
    NSMutableArray *tipValues = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]
                                                                objectForKey:@"tipValues"]];
    if(tipValues.count == 3) {
        self.tipValues = [NSMutableArray arrayWithArray:tipValues];
    } else {
        self.tipValues = [NSMutableArray arrayWithArray:@[@(0.10), @(0.15), @(0.20)]];
    }
    
    for(int i=0;i<self.tipValues.count;i++) {
        int value = [self.tipValues[i] floatValue] * 100.0 + 0.5; //Handle Rounding Errors
        [self.tipControl setTitle:[NSString stringWithFormat:@"%d%%", value]forSegmentAtIndex:i];
    }
    
    [self updateValues];
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSInteger MAX_DIGITS = 11; // $999,999,999.99
    
    NSString *stringMaybeChanged = [NSString stringWithString:string];
    if (stringMaybeChanged.length > 1)
    {
        NSMutableString *stringPasted = [NSMutableString stringWithString:stringMaybeChanged];
        
        [stringPasted replaceOccurrencesOfString:self.currencyFormatter.currencySymbol
                                      withString:@""
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [stringPasted length])];
        
        [stringPasted replaceOccurrencesOfString:self.currencyFormatter.groupingSeparator
                                      withString:@""
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [stringPasted length])];
        
        NSDecimalNumber *numberPasted = [NSDecimalNumber decimalNumberWithString:stringPasted];
        stringMaybeChanged = [self.currencyFormatter stringFromNumber:numberPasted];
    }
    
    UITextRange *selectedRange = [textField selectedTextRange];
    UITextPosition *start = textField.beginningOfDocument;
    NSInteger cursorOffset = [textField offsetFromPosition:start toPosition:selectedRange.start];
    NSMutableString *textFieldTextStr = [NSMutableString stringWithString:textField.text];
    NSUInteger textFieldTextStrLength = textFieldTextStr.length;
    
    [textFieldTextStr replaceCharactersInRange:range withString:stringMaybeChanged];
    
    [textFieldTextStr replaceOccurrencesOfString:self.currencyFormatter.currencySymbol
                                      withString:@""
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [textFieldTextStr length])];
    
    [textFieldTextStr replaceOccurrencesOfString:self.currencyFormatter.groupingSeparator
                                      withString:@""
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [textFieldTextStr length])];
    
    [textFieldTextStr replaceOccurrencesOfString:self.currencyFormatter.decimalSeparator
                                      withString:@""
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [textFieldTextStr length])];
    
    if (textFieldTextStr.length <= MAX_DIGITS)
    {
        NSDecimalNumber *textFieldTextNum = [NSDecimalNumber decimalNumberWithString:textFieldTextStr];
        NSDecimalNumber *divideByNum = [[[NSDecimalNumber alloc] initWithInt:10] decimalNumberByRaisingToPower:self.currencyFormatter.maximumFractionDigits];
        NSDecimalNumber *textFieldTextNewNum = [textFieldTextNum decimalNumberByDividingBy:divideByNum];
        NSString *textFieldTextNewStr = [self.currencyFormatter stringFromNumber:textFieldTextNewNum];
        
        textField.text = textFieldTextNewStr;
        
        if (cursorOffset != textFieldTextStrLength)
        {
            NSInteger lengthDelta = textFieldTextNewStr.length - textFieldTextStrLength;
            NSInteger newCursorOffset = MAX(0, MIN(textFieldTextNewStr.length, cursorOffset + lengthDelta));
            UITextPosition* newPosition = [textField positionFromPosition:textField.beginningOfDocument offset:newCursorOffset];
            UITextRange* newRange = [textField textRangeFromPosition:newPosition toPosition:newPosition];
            [textField setSelectedTextRange:newRange];
        }
        
        [self updateValues];
    }
    
    return NO;
}

@end
