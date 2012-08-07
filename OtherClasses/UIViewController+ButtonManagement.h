//
//  UIViewController+ButtonManagement.h
//  billy
//
//  Created by Ross Cooperman on 8/3/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
  BLButtonTypeBack,
  BLButtonTypeForward,
  BLButtonTypeOther
} BLButtonType;


@interface UIViewController (ButtonManagement)

- (void)disableButton:(UIButton *)button;
- (void)enableButton:(UIButton *)button type:(BLButtonType)type;

@end
