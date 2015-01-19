//
//  SettingsViewController.m
//  tipcalculator
//
//  Created by Casing Chu on 1/17/15.
//  Copyright (c) 2015 casing. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tip1TextField;
@property (weak, nonatomic) IBOutlet UITextField *tip2TextField;
@property (weak, nonatomic) IBOutlet UITextField *tip3TextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *themeControl;

- (IBAction)onTap:(id)sender;
- (IBAction)themeValueChanged:(id)sender;

- (void)saveDefaults;
- (void)restoreDefaults;

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self restoreDefaults];
}

- (void)viewWillAppear:(BOOL)animated {
    [self restoreDefaults];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self saveDefaults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveDefaults
{
    NSMutableArray *tipValues = [NSMutableArray
                                 arrayWithArray:@[@([self.tip1TextField.text floatValue] / 100.0),
                                                  @([self.tip2TextField.text floatValue] / 100.0),
                                                  @([self.tip3TextField.text floatValue] / 100.0)]];
    
    [[NSUserDefaults standardUserDefaults] setObject:tipValues forKey:@"tipValues"];
    [[NSUserDefaults standardUserDefaults] setInteger:[self.themeControl selectedSegmentIndex] forKey:@"themeId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)themeValueChanged:(id)sender {
    int themeId = [self.themeControl selectedSegmentIndex];
    if(themeId == 0) {
        // Light
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    } else if(themeId == 1) {
        // Dark
        [self.view setBackgroundColor:[UIColor lightGrayColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor lightGrayColor]];
    }
}

- (void)restoreDefaults
{
    NSMutableArray *tipValues = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]
                                                                objectForKey:@"tipValues"]];
    
    // Set to Default
    if(tipValues.count != 3) {
        tipValues = [NSMutableArray arrayWithArray:@[@(0.10), @(0.15), @(0.20)]];
    }
        
    int tip = [tipValues[0] floatValue] * 100.0 + 0.5; //Handle Rounding errors
    [self.tip1TextField setText:[NSString stringWithFormat:@"%d", tip]];
    
    tip = [tipValues[1] floatValue] * 100.0 + 0.5;
    [self.tip2TextField setText:[NSString stringWithFormat:@"%d", tip]];
    
    tip = [tipValues[2] floatValue] * 100.0 + 0.5;
    [self.tip3TextField setText:[NSString stringWithFormat:@"%d", tip]];
    
    int themeId = [[NSUserDefaults standardUserDefaults] integerForKey:@"themeId"];
    [self.themeControl setSelectedSegmentIndex:themeId];
    [self themeValueChanged:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Support BackSpace
    if([string length]==0){
        return YES;
    }
    
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if (![myCharSet characterIsMember:c]) {
            return NO;
        }
    }
    
    // If is number check that we are in the range from 0-100
    NSMutableString *textFieldTextStr = [NSMutableString stringWithString:textField.text];
    [textFieldTextStr replaceCharactersInRange:range withString:string];
    
    int value = [textFieldTextStr intValue];
    if(value >= 0 && value <= 100) {
        textField.text = textFieldTextStr;
    }
    
    return NO;
}

@end
