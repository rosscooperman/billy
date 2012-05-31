//
//  BLSplitCountViewController.m
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLSplitCountViewController.h"


@interface BLSplitCountViewController ()

- (void)setCount:(NSInteger)count;

@end


@implementation BLSplitCountViewController

@synthesize countLabel;
@synthesize minusButton;
@synthesize plusButton;


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self setCount:[BLAppDelegate appDelegate].splitCount];
}


#pragma mark - Instance Methods

- (void)setCount:(NSInteger)count
{
  self.minusButton.enabled = YES;
  self.plusButton.enabled = YES;
  self.countLabel.text = [NSString stringWithFormat:@"%d", count];
  self.countLabel.textColor = [[BLAppDelegate appDelegate] colorAtIndex:count];
  
  if (count <= 2) {
    self.minusButton.enabled = NO;
  }
  else if (count >= 8) {
    self.plusButton.enabled = NO;
  }
}


#pragma mark - IBAction Methods

- (void)incrementCount:(id)sender
{
  [BLAppDelegate appDelegate].splitCount++;
  [self setCount:[BLAppDelegate appDelegate].splitCount];
}


- (void)decrementCount:(id)sender
{
  [BLAppDelegate appDelegate].splitCount--;
  [self setCount:[BLAppDelegate appDelegate].splitCount];
}

@end
