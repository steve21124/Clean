//
//  GetAddressViewController.h
//  Clean
//
//  Created by Sapan Bhuta on 8/28/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQFlatButton.h"

@interface GetAddressViewController : UIViewController
@property JSQFlatButton *back;
@property JSQFlatButton *save;
@property UIButton *locationButton;
@property UIPageControl *page;
- (void)animateHideKeyboard;
- (void)nextVC;
@end
