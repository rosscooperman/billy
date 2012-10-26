//
//  BLProgressButton.m
//  billy
//
//  Created by Ross Cooperman on 10/26/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLProgressButton.h"


@interface BLProgressButton ()

@property (nonatomic, strong) UIView *highlight;


- (void)createSubviews;

@end


@implementation BLProgressButton

@synthesize highlight;


#pragma mark - Object Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self createSubviews];
  }
  return self;
}


#pragma mark - Instance Methods

- (void)createSubviews
{
  self.highlight = [[UIView alloc] initWithFrame:self.bounds];
  self.highlight.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
  self.highlight.hidden = YES;
  [self addSubview:self.highlight];
}


#pragma mark - UIControl Methods

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
  self.highlight.hidden = NO;
  return [super beginTrackingWithTouch:touch withEvent:event];
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
  self.highlight.hidden = YES;
  return [super endTrackingWithTouch:touch withEvent:event];
}


- (void)cancelTrackingWithEvent:(UIEvent *)event
{
  self.highlight.hidden = YES;
  return [super cancelTrackingWithEvent:event];
}

@end
