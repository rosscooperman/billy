//
//  BLSplitCountViewController.m
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLSplitCountViewController.h"


@interface BLSplitCountViewController ()

@property (nonatomic, assign) NSInteger count;

@end


@implementation BLSplitCountViewController

@synthesize countLabel;
@synthesize minusButton;
@synthesize plusButton;
@synthesize count = _count;


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.count = [BLAppDelegate appDelegate].splitCount;
}


#pragma mark - Property Implementations

- (void)setCount:(NSInteger)count
{
  _count = count;
  
  self.minusButton.enabled = YES;
  self.plusButton.enabled = YES;
  self.countLabel.text = [NSString stringWithFormat:@"%d", self.count];
  self.countLabel.textColor = [[BLAppDelegate appDelegate] colorAtIndex:self.count];
  
  if (self.count <= 0) {
    self.minusButton.enabled = NO;
  }
  else if (self.count >= 8) {
    self.plusButton.enabled = NO;
  }
}


#pragma mark - IBAction Methods

- (void)incrementCount:(id)sender
{
  self.count++;
}


- (void)decrementCount:(id)sender
{
  self.count--;
}

@end
