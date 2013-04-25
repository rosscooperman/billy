//
//  BLView.m
//  billy
//
//  Created by Ross Cooperman on 4/15/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#import "BLView.h"

@implementation BLView


#pragma mark - Property Implementations

- (CGFloat)borderWidth
{
  static CGFloat _borderWidth = 0.0f;
  if (_borderWidth <= 0.0f) {
    _borderWidth = 1.0f / [UIScreen mainScreen].scale;
  }
  return _borderWidth;
}

@end
