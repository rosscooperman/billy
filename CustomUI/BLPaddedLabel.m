//
//  BLPaddedLabel.m
//  billy
//
//  Created by Ross Cooperman on 2/22/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#import "BLPaddedLabel.h"

@implementation BLPaddedLabel

@synthesize padding = _padding;


- (void)drawTextInRect:(CGRect)rect
{
  CGRect inset = (self.textAlignment == UITextAlignmentCenter) ? rect : CGRectInset(rect, self.padding, 0.0f);
  [super drawTextInRect:inset];
}


- (void)setPadding:(CGFloat)padding
{
  _padding = padding;
  [self setNeedsDisplay];
}


- (CGFloat)padding
{
  if (!_padding) _padding = 6.0f;
  return _padding;
}

@end
