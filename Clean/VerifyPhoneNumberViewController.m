//
//  VerifyPhoneNumberViewController.m
//  Cents
//
//  Created by Sapan Bhuta on 7/30/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "VerifyPhoneNumberViewController.h"
#import "JSQFlatButton.h"
#import <Parse/Parse.h>
#import "VCFlow.h"
#import "GetAddressViewController.h"
#import "RootViewController.h"
#import "User.h"
#import "ParseLogic.h"
#import "Constants.h"

@interface VerifyPhoneNumberViewController ()
@property UITextField *codeEntry;
@property NSTimer *buttonCheckTimer;
@property JSQFlatButton *resend;
@property JSQFlatButton *enter;
@property int randomNum;
@end

@implementation VerifyPhoneNumberViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [Constants backgroundColor];
    [self createPage];
    [self createTitle];
    [self createEntryField];
    [self createButtons];
}

- (void)createPage
{
    _page = [[UIPageControl alloc] init];
    _page.center = CGPointMake(self.view.center.x, 100);
    _page.numberOfPages = 5;
    _page.currentPage = 1;
    _page.backgroundColor = [UIColor clearColor];
    _page.tintColor = [UIColor whiteColor];
    _page.currentPageIndicatorTintColor = [UIColor colorWithRed:0.0f green:0.49f blue:0.96f alpha:1.0f];
    [self.view addSubview:_page];
}

- (void)createTitle
{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, self.view.frame.size.width-2*10, 50)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50];
    title.textColor = [UIColor whiteColor];
    title.text = @"Verify Number";
    title.adjustsFontSizeToFitWidth = YES;
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];
}

- (void)createEntryField
{
    _codeEntry = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width-2*20, 100)];
    _codeEntry.placeholder = @"enter code";
    _codeEntry.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
    _codeEntry.textColor = [UIColor whiteColor];
    _codeEntry.adjustsFontSizeToFitWidth = YES;
    _codeEntry.keyboardAppearance = UIKeyboardAppearanceDark;
    _codeEntry.keyboardType = UIKeyboardTypeNumberPad;
    _codeEntry.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_codeEntry];
    [_codeEntry becomeFirstResponder];
}

- (void)createButtons
{
    _resend = [[JSQFlatButton alloc] initWithFrame:CGRectMake(0,
                                                              self.view.frame.size.height-216-54,
                                                              self.view.frame.size.width/2-.25,
                                                              54)
                                   backgroundColor:[UIColor colorWithRed:0.18f green:0.67f blue:0.84f alpha:1.0f]
                                   foregroundColor:[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.0f]
                                             title:@"back"//@"resend"
                                             image:nil];
    [_resend addTarget:self action:@selector(resend:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_resend];

    _enter = [[JSQFlatButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2+.25,
                                                             self.view.frame.size.height-216-54,
                                                             self.view.frame.size.width/2-.25,
                                                             54)
                                  backgroundColor:[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.0f]
                                  foregroundColor:[UIColor colorWithRed:0.35f green:0.35f blue:0.81f alpha:1.0f]
                                            title:@"enter"
                                            image:nil];
    [_enter addTarget:self action:@selector(enter:) forControlEvents:UIControlEventTouchUpInside];
    _enter.enabled = NO;
    [self.view addSubview:_enter];

    _buttonCheckTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(buttonCheck) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self sendSMSToNumber:[User phoneNumber]];
}

- (void)resend:(JSQFlatButton *)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
//    _codeEntry.text = @"";
    [self sendSMSToNumber:[User phoneNumber]];
}

- (void)enter:(JSQFlatButton *)sender
{
    [User setVerifiedPhoneNumber:[User phoneNumber]];

    [ParseLogic checkForExistingUserWithCompletionHandler:^(bool exists) {
        if (exists) {
            [self presentViewController:[VCFlow nextVC] animated:NO completion:nil];
        } else {
            [self presentViewController:[GetAddressViewController new] animated:NO completion:nil];
        }
    }];
}

- (BOOL)codeIsValid
{
    return _randomNum == [_codeEntry.text intValue];
}

- (void)buttonCheck
{
    if ([_codeEntry.text length] > 3)
    {
        [self codeIsValid] ? [_codeEntry setTextColor:[UIColor greenColor]] : [_codeEntry setTextColor:[UIColor redColor]];
    }
    else
    {
        _codeEntry.textColor = [UIColor whiteColor];
    }

    _enter.enabled = [self codeIsValid];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)sendSMSToNumber:(NSString *)phoneNumber
{
    NSLog(@"PHONE NUMBER: %@",phoneNumber);
    _randomNum = 1000 + arc4random_uniform(8999);
    NSLog(@"Clean Code: %@",@(_randomNum).description);
    NSString *message = [NSString stringWithFormat:@"Clean Code: %@",@(_randomNum).description];
    [PFCloud callFunctionInBackground:@"verifyNum" withParameters:@{@"number" : phoneNumber, @"message":message} block:nil];
}

@end