//
//  GetAddressViewController.m
//  Clean
//
//  Created by Sapan Bhuta on 8/28/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "GetAddressViewController.h"
#import "GetPayCardViewController.h"
#import "JSQFlatButton.h"
#import "INTULocationManager.h"
#import "User.h"
#import "Constants.h"

@interface GetAddressViewController () <UIAlertViewDelegate>
@property UITextField *addressField;
@property UITextView *addressLabel;
@property BOOL gettingLocation;
@property int requestID;
@property CLLocation *location;
@property NSArray *formattedAddress;
@property NSString *addressString;
@property UIActivityIndicatorView *activity;
@property NSTimer *buttonCheckTimer;
@property BOOL saving;
@property UIAlertView *errorAlert;
@property UIAlertView *checkAlert;
@end

@implementation GetAddressViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [Constants backgroundColor];
    [self createPage];
    [self createTitle];
    [self createButton];
    [self createEntryField];
    [self createAddressLabel];
    [self createLocationButton];
    [self createActivityView];
    _gettingLocation = NO;
    _saving = NO;
    self.buttonCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1/10 target:self selector:@selector(buttonCheck) userInfo:nil repeats:YES];
}

- (void)buttonCheck
{
    if (!_saving && (_formattedAddress || _addressField.text.length > 0))
    {
        _save.enabled = YES;
    }
    else
    {
        _save.enabled = NO;
    }
}

- (void)createPage
{
    _page = [[UIPageControl alloc] init];
    _page.center = CGPointMake(self.view.center.x, 100);
    _page.numberOfPages = 5;
    _page.currentPage = 2;
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
    title.text = @"Address";
    title.adjustsFontSizeToFitWidth = YES;
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];
}

- (void)createButton
{
    _back = [[JSQFlatButton alloc] initWithFrame:CGRectZero
                                      backgroundColor:[UIColor colorWithRed:0.18f green:0.67f blue:0.84f alpha:1.0f]
                                      foregroundColor:[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.0f]
                                                title:@"back"
                                                image:nil];
    [_back addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_back];

    _save = [[JSQFlatButton alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-216-54,self.view.frame.size.width,54)
                                 backgroundColor:[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.0f]
                                 foregroundColor:[UIColor colorWithRed:0.35f green:0.35f blue:0.81f alpha:1.0f]
                                           title:@"save"
                                           image:nil];
    [_save addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_save];
    _save.enabled = NO;
}

- (void)back:(JSQFlatButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createEntryField
{
    _addressField = [[UITextField alloc] initWithFrame:CGRectMake(20, 150, self.view.frame.size.width-2*20, 100)];
    _addressField.placeholder = @"enter address";
    _addressField.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:35];
    _addressField.textColor = [UIColor whiteColor];
    _addressField.adjustsFontSizeToFitWidth = YES;
    _addressField.keyboardAppearance = UIKeyboardAppearanceDark;
    _addressField.keyboardType = UIKeyboardTypeDefault;
    _addressField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_addressField];
    [_addressField becomeFirstResponder];
}

- (void)createAddressLabel
{
    _addressLabel = [[UITextView alloc] initWithFrame:CGRectMake(20, 150, self.view.frame.size.width-2*20, 100)];
    _addressLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25];
    _addressLabel.backgroundColor = [UIColor clearColor];
    _addressLabel.textColor = [UIColor whiteColor];
    _addressLabel.textAlignment = NSTextAlignmentCenter;
    _addressLabel.editable = NO;
    _addressLabel.selectable = NO;
    [self.view addSubview:_addressLabel];
    _addressLabel.hidden = YES;
}

- (void)createActivityView
{
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activity.center = _addressLabel.center;
    [_activity hidesWhenStopped];
    [self.view addSubview:_activity];
}

- (void)createLocationButton
{
    _locationButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _locationButton.tintColor = [UIColor whiteColor];
    [_locationButton addTarget:self action:@selector(location:) forControlEvents:UIControlEventTouchUpInside];
    [_locationButton setImage:[UIImage imageNamed:@"navigate"] forState:UIControlStateNormal];
    _locationButton.frame = CGRectMake(self.view.frame.size.width - 53, 121.5, 48, 48);
    _locationButton.center = CGPointMake(self.view.frame.size.width/2, 140);
    [self.view addSubview:_locationButton];
}

- (void)location:(UIButton *)sender
{
    if (_gettingLocation)
    {
        [self revertFromLocationGetting];
    }
    else
    {
        _gettingLocation = YES;
//        _locationButton.enabled = NO;
        [_activity startAnimating];

        INTULocationManager *locMgr = [INTULocationManager sharedInstance];
        _requestID = (int)[locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse
                                                             timeout:30.0
                                                delayUntilAuthorized:YES
                                                               block:^(CLLocation *currentLocation,
                                                                       INTULocationAccuracy achievedAccuracy,
                                                                       INTULocationStatus status)
         {
             if (status == INTULocationStatusSuccess)
             {
                 [[CLGeocoder new] reverseGeocodeLocation:currentLocation
                                        completionHandler:^(NSArray *placemarks, NSError *error)
                 {
                     if (error || placemarks.count == 0)
                     {
                         [self revertFromLocationGetting];
                         [[[UIAlertView alloc] initWithTitle:@"Error Gettting Location" message:@"Please try again or enter manually" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                     }
                     else
                     {
                         [_activity stopAnimating];
                         _location = currentLocation;
                         _formattedAddress = [placemarks.firstObject addressDictionary][@"FormattedAddressLines"];
                         _addressString = [NSString stringWithFormat:@"%@\n%@",_formattedAddress[0],_formattedAddress[1]];
                         _addressLabel.text = _addressString;
                         _addressLabel.hidden = NO;
                         _locationButton.enabled = YES;
                         _save.enabled = YES;
                     }
                 }];
             }
             else if (status == INTULocationStatusTimedOut)
             {
                 [self revertFromLocationGetting];
                 [[[UIAlertView alloc] initWithTitle:@"Error Gettting Location" message:@"Please try again or enter manually" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
             }
             else
             {
                 [self revertFromLocationGetting];
                 [[[UIAlertView alloc] initWithTitle:@"Error Gettting Location" message:@"Please try again or enter manually" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
             }
         }];

        _addressField.hidden = YES;
        [_addressField resignFirstResponder];
        [self animateHideKeyboard];
    }
}

- (void)animateHideKeyboard
{
    [UIView animateWithDuration:.3 animations:^{
        _locationButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2+100);
        _save.transform = CGAffineTransformMakeTranslation(0, 216);
        _back.transform = CGAffineTransformMakeTranslation(0, 216);
    }];
}

- (void)revertFromLocationGetting
{
    _gettingLocation = NO;
    [[INTULocationManager sharedInstance] cancelLocationRequest:_requestID];
    [_activity stopAnimating];
//    _save.enabled = NO;
    _addressLabel.hidden = YES;
    [UIView animateWithDuration:.3 animations:^{
        _locationButton.center = CGPointMake(self.view.frame.size.width/2, 140);
        _save.transform = CGAffineTransformMakeTranslation(0, 0);
        _back.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        _addressField.hidden = NO;
        _locationButton.enabled = YES;
        [_addressField becomeFirstResponder];
        _gettingLocation = NO;
    }];
}

- (void)save:(JSQFlatButton *)sender
{
    _saving = YES;
    if (_addressString && _gettingLocation)
    {
        [self saveGeocodedAddressInfo];
        [self nextVC];
    }
    else
    {
        [[CLGeocoder new] geocodeAddressString:_addressField.text completionHandler:^(NSArray *placemarks, NSError *error)
        {
            if (error || placemarks.count != 1)
            {
                _errorAlert = [[UIAlertView alloc] initWithTitle:@"Error Locating Address" message:@"Are you sure you entered the address correctly?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
                _errorAlert.delegate = self;
                _errorAlert.tag = 0;
                [_errorAlert show];
            }
            else
            {
                CLPlacemark *placemark = placemarks.firstObject;
                _location = placemark.location;
                _formattedAddress = [placemark addressDictionary][@"FormattedAddressLines"];
                _addressString = [NSString stringWithFormat:@"%@\n%@",_formattedAddress[0],_formattedAddress[1]];
                _checkAlert = [[UIAlertView alloc] initWithTitle:@"Is this the correct address?" message:_addressString delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
                _checkAlert.delegate = self;
                _checkAlert.tag = 1;
                [_checkAlert show];
            }
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        _saving = NO;
        _location = nil;
        _formattedAddress = nil;
        _addressString = nil;
    }
    else
    {
        if (alertView.tag == 0)
        {
            [User setAddress:_addressField.text];
            [self nextVC];
        }
        else
        {
            [self saveGeocodedAddressInfo];
            [self nextVC];
        }
    }
}

- (void)saveGeocodedAddressInfo
{
    CGFloat latitude = _location.coordinate.latitude;
    CGFloat longitude = _location.coordinate.longitude;
    [User setLatitude:latitude];
    [User setLongitude:longitude];
    [User setAddress:_addressString];
}

- (void)nextVC
{
    [self presentViewController:[GetPayCardViewController new] animated:NO completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end