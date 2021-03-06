//
//  BLMainView.m
//  billy
//
//  Created by Ross Cooperman on 9/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLMainView.h"


@interface BLMainView ()

- (void)customizeAppearance;

@end


@implementation BLMainView


# pragma mark - Overridden Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self customizeAppearance];
  }
  return self;
}


#pragma mark - Instance Methods

- (void)customizeAppearance
{
  // set up any default property settings
  self.clipsToBounds = NO;

  // give the view the appropriate background image
  self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"billBackground"]];
  
  // add the bottom border just below this view
  UIImageView *bottomBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottomBorder"]];
  bottomBorder.frame = CGRectMake(self.bounds.origin.x, self.bounds.size.height, self.bounds.size.width, 2.0f);
  bottomBorder.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
  [self addSubview:bottomBorder];
}

@end
