//
//  BLTextField.m
//  billy
//
//  Created by Ross Cooperman on 6/1/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLTextField.h"

@implementation BLTextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
  return CGRectInset(bounds, 6, 0);
}


- (CGRect)editingRectForBounds:(CGRect)bounds
{
  return [self textRectForBounds:bounds];
}

@end
