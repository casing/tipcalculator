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
@property SettingsViewController *settingsViewController;
@property NSMutableArray *tipValues;

- (IBAction)onTap:(id)sender;
- (void)updateValues;
- (void)onSettingsButton;
- (void)saveDefaults;
- (void)restoreDefaults;

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
    [self saveDefaults];
}

- (void)updateValues
{
    float billAmount = [self.billTextField.text floatValue];
    
    float tipAmount = billAmount * [self.tipValues[self.tipControl.selectedSegmentIndex] floatValue];
    float totalAmount = billAmount + tipAmount;
    
    self.tipLabel.text = [NSString stringWithFormat:@"$%0.2f", tipAmount];
    self.totalLabel.text = [NSString stringWithFormat:@"$%0.2f", totalAmount];
}

- (void)onSettingsButton
{
    [self.view endEditing:YES];
    [self.navigationController pushViewController:[self settingsViewController] animated:YES];
}


- (void)saveDefaults
{
    [[NSUserDefaults standardUserDefaults]setObject:self.billTextField.text forKey:@"previousBill"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.tipControl.selectedSegmentIndex forKey:@"defaultTipIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreDefaults
{
    NSString *previousBill = [[NSUserDefaults standardUserDefaults] objectForKey:@"previousBill"];
    [self.billTextField setText:previousBill];
    
    int intValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"defaultTipIndex"];
    [self.tipControl setSelectedSegmentIndex:intValue];
    
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

@end
