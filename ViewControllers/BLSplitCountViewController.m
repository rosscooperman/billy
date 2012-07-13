//
//  BLSplitCountViewController.m
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLSplitCountViewController.h"
#import "BLNamesViewController.h"
#import "Bill.h"


@interface BLSplitCountViewController ()

@property (nonatomic, strong) Bill *bill;


- (void)setCount:(NSInteger)count;

@end


@implementation BLSplitCountViewController

@synthesize countLabel;
@synthesize minusButton;
@synthesize plusButton;
@synthesize bill;


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.bill = [BLAppDelegate appDelegate].currentBill;
  [self setCount:self.bill.splitCount];
}


- (void)viewWillDisappear:(BOOL)animated
{
  [[BLAppDelegate appDelegate].managedObjectContext save:nil];
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
  [self setCount:++self.bill.splitCount];
}


- (void)decrementCount:(id)sender
{
  [self setCount:--self.bill.splitCount];
}


- (void)nextScreen:(id)sender
{
  BLNamesViewController *namesController = [[BLNamesViewController alloc] init];
  [self.navigationController pushViewController:namesController animated:YES];
}

@end
