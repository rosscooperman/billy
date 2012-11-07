//
//  BLViewController.m
//  billy
//
//  Created by Ross Cooperman on 9/29/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLViewController.h"


@interface BLViewController ()

- (void)customizeAppearance;

@end


@implementation BLViewController

#pragma mark - Object Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self customizeAppearance];
    self.navigationItem.hidesBackButton = YES;
  }
  return self;
}


#pragma mark - Instance Methods

- (void)customizeAppearance
{
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"viewBackground"]];
}

@end
