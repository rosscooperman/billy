//
//  UIViewController+ButtonManagement.m
//  billy
//
//  Created by Ross Cooperman on 8/3/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "UIViewController+ButtonManagement.h"
#import "BLAppDelegate.h"


@implementation UIViewController (ButtonManagement)

- (void)disableButton:(UIButton *)button
{
  button.enabled = NO;
  button.backgroundColor = [[BLAppDelegate appDelegate] colorAtIndex:0];
}


- (void)enableButton:(UIButton *)button type:(BLButtonType)type
{
  button.enabled = YES;
  switch (type) {
    case BLButtonTypeBack:
      button.backgroundColor = [UIColor colorWithRed:0.98039 green:0.16863 blue:0.20392 alpha:1.0];
      break;
      
    case BLButtonTypeForward:
      button.backgroundColor = [UIColor colorWithRed:0.09804 green:0.77255 blue:0.22745 alpha:1.0];
      break;
      
    case BLButtonTypeOther:
      button.backgroundColor = [UIColor colorWithRed:0.31373 green:0.88627 blue:0.65882 alpha:1.0];
      break;
  }
}

@end
