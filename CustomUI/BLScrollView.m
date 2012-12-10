//
//  BLScrollView.m
//  billy
//
//  Created by Ross Cooperman on 11/8/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLScrollView.h"


#define OVERFLOW_HEIGHT 1000.0f


@interface BLScrollView ()

@property (nonatomic, strong) UIView *overflowView;
@property (nonatomic, strong) UIImageView *topTear;
@property (nonatomic, strong) UIImageView *bottomTear;
@property (nonatomic, strong) UIImageView *bottomBorder;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat separationPoint;


- (void)createSubviews;

@end


@implementation BLScrollView

@synthesize overflowView;
@synthesize topTear;
@synthesize bottomTear;
@synthesize borderWidth;
@synthesize bottomBorder;
@synthesize separationPoint;


#pragma mark - Object Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) [self createSubviews];
  return self;
}


#pragma mark - Instance Methods

- (void)createSubviews
{
  self.borderWidth = 1.0f / [UIScreen mainScreen].scale;
  self.clipsToBounds = YES;
  
  // create and insert the overflow view
  self.overflowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -(OVERFLOW_HEIGHT + self.borderWidth), 320.0f, OVERFLOW_HEIGHT)];
  self.overflowView.backgroundColor = [UIColor colorWithRed:0.94118f green:0.9451f blue:0.94118f alpha:1.0f];
  [self insertSubview:self.overflowView atIndex:0];
  
  // create and insert the bottom tear view
  self.bottomTear = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tearBottom"]];
  self.bottomTear.frame = CGRectMake(0.0f, OVERFLOW_HEIGHT - self.bottomTear.image.size.height, 320.0f, self.bottomTear.image.size.height);
  self.bottomTear.contentMode = UIViewContentModeScaleToFill;
  [self.overflowView addSubview:self.bottomTear];
  
  // create and insert the top tear view
  self.topTear = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tearTop"]];
  CGFloat topTearY = OVERFLOW_HEIGHT - self.bottomTear.image.size.height - self.topTear.image.size.height + 1.0f;
  self.topTear.frame = CGRectMake(0.0f, topTearY, 320.0f, self.topTear.image.size.height);
  self.topTear.contentMode = UIViewContentModeScaleToFill;
  [self.overflowView addSubview:self.topTear];
  
  // calculate the separation point where the top and bottom tear will start to separate
  self.separationPoint = CGRectGetMaxY(self.overflowView.frame) - self.topTear.frame.size.height - self.bottomTear.frame.size.height + 1.0f;
  
  // create the scroll view's bottom border
  self.bottomBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottomBorder"]];
  self.bottomBorder.frame = CGRectMake(0.0f, -self.borderWidth, 320.0f, self.bottomBorder.image.size.height);
}


#pragma mark - Overridden Methods

- (void)didMoveToSuperview
{
  [self.bottomBorder removeFromSuperview];
  [self.superview insertSubview:self.bottomBorder belowSubview:self];
}


- (void)setContentOffset:(CGPoint)contentOffset
{
  [super setContentOffset:contentOffset];
  
  // if the scroll is above the point where top and bottom tears separate move the top tear
  if (contentOffset.y <= self.separationPoint) {
    self.topTear.transform = CGAffineTransformMakeTranslation(0.0, contentOffset.y - self.separationPoint);
  }
  
  // make sure the position of the bottom border is correct
  CGRect newFrame = self.bottomBorder.frame;
  newFrame.origin.y = MIN(self.frame.origin.y + self.contentSize.height - self.contentOffset.y - self.borderWidth, CGRectGetMaxY(self.frame));
  self.bottomBorder.frame = newFrame;
//  TFLog(@"%f, %f", newFrame.origin.y, );
  
//  CGFloat bottomY = self.contentOffset.y + self.bounds.size.height;
//
//  // deal with the situation where there is more to reveal at the bottom and the bottom border is still contained by the scroll view
//  if (bottomY < self.contentSize.height - self.bottomBorder.frame.size.height && self.bottomBorder.superview == self) {
//    TFLog(@"<");
//    
//    // move the bottom border into our superview and adjust its frame accordingly
//    [self.bottomBorder removeFromSuperview];
//    [self.superview insertSubview:self.bottomBorder atIndex:0];
//    self.bottomBorder.frame = (CGRect){ CGPointMake(0.0f, CGRectGetMaxY(self.frame)), self.bottomBorder.frame.size };
//  }
//  
//  // and the situation where we've scrolled past the bottom of the scroll view's contents
//  else if (bottomY >= self.contentSize.height - self.bottomBorder.frame.size.height && self.bottomBorder.superview != self) {
//    TFLog(@">=");
//    [self.bottomBorder removeFromSuperview];
//    [self addSubview:self.bottomBorder];
//
//    CGRect currentFrame = self.bottomBorder.frame;
//    self.bottomBorder.frame = (CGRect){ CGPointMake(currentFrame.origin.x, self.contentSize.height - self.bottomBorder.frame.size.height), currentFrame.size };
//  }
}

@end
