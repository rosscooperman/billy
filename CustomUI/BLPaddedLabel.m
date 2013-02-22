//
//  BLPaddedLabel.m
//  billy
//
//  Created by Ross Cooperman on 2/22/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#import "BLPaddedLabel.h"

@implementation BLPaddedLabel

- (void)drawTextInRect:(CGRect)rect
{
  CGRect inset = (self.textAlignment == UITextAlignmentCenter) ? rect : CGRectInset(rect, 6.0f, 0.0f);
  [super drawTextInRect:inset];
}

@end
