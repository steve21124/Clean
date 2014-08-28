//
//  GetPhoneNumberViewController.m
//  Cents
//
//  Created by Sapan Bhuta on 7/30/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "GetPhoneNumberViewController.h"
#import "JSQFlatButton.h"
#import "UIColor+FlatUI.h"
#import "VerifyPhoneNumberViewController.h"
#import "LTPhoneNumberField.h"

@interface GetPhoneNumberViewController ()
@property LTPhoneNumberField *phoneEntry;
@property NSTimer *buttonCheckTimer;
@property JSQFlatButton *verify;
@end

@implementation GetPhoneNumberViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor midnightBlueColor];
    [self createTitle];
    [self createEntryField];
    [self createButton];
}

- (void)createTitle
{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, self.view.frame.size.width-2*10, 50)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50];
    title.textColor = [UIColor whiteColor];
    title.text = @"Phone Number";
    title.adjustsFontSizeToFitWidth = YES;
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];
}

- (void)createEntryField
{
    _phoneEntry = [[LTPhoneNumberField alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width-2*20, 100)];
    _phoneEntry.placeholder = @"enter phone number";
    _phoneEntry.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
    _phoneEntry.textColor = [UIColor whiteColor];
    _phoneEntry.adjustsFontSizeToFitWidth = YES;
    _phoneEntry.keyboardAppearance = UIKeyboardAppearanceDark;
    _phoneEntry.keyboardType = UIKeyboardTypePhonePad;
    _phoneEntry.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_phoneEntry];
    [_phoneEntry becomeFirstResponder];
}

- (void)createButton
{
    _verify = [[JSQFlatButton alloc] initWithFrame:CGRectMake(0,
                                                              self.view.frame.size.height-216-54,
                                                              self.view.frame.size.width,
                                                              54)
                                   backgroundColor:[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.0f]
                                   foregroundColor:[UIColor colorWithRed:0.35f green:0.35f blue:0.81f alpha:1.0f]
                                             title:@"verify via sms"
                                             image:nil];
    [_verify addTarget:self action:@selector(verify:) forControlEvents:UIControlEventTouchUpInside];
    _verify.enabled = NO;
    [self.view addSubview:_verify];

    _buttonCheckTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(buttonCheck) userInfo:nil repeats:YES];
}

- (void)verify:(UIButton *)sender
{
    NSLog(@"Clean number: %@",[self clean:_phoneEntry.text]);
    [[NSUserDefaults standardUserDefaults] setObject:[self clean:_phoneEntry.text] forKey:@"phoneNumber"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self presentViewController:[VerifyPhoneNumberViewController new] animated:NO completion:nil];
}

- (void)buttonCheck
{
    if (_phoneEntry.containsValidNumber)
    {
        _phoneEntry.textColor = [UIColor greenColor];
        _verify.enabled = YES;
    }
    else
    {
        _phoneEntry.textColor = [UIColor whiteColor];
        _verify.enabled = NO;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (NSString *)clean:(NSString *)phoneNumber
{
    NSArray *symbols = @[@"+", @"(",@")", @" ", @"-", @"*", @"#", @",", @";",@" "];
    for (NSString *symbol in symbols)
    {
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:symbol withString:@""];
    }
    if (phoneNumber.length == 10)
    {
        phoneNumber = [@"1" stringByAppendingString:phoneNumber];
    }
    return phoneNumber;
}

@end