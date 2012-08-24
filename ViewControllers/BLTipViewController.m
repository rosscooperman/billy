//
//  BLTipViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/16/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLTipViewController.h"
#import "BLSummaryViewController.h"
#import "UIViewController+GuidedTour.h"
#import "Bill.h"


@interface BLTipViewController ()

@property (nonatomic, strong) Bill *bill;
@property (nonatomic, assign) float tipPercentage;
@property (nonatomic, strong) NSTimer *longPressTimer;
@property (nonatomic, readonly) NSNumberFormatter *percentFormatter;


@end


@implementation BLTipViewController

@synthesize percentLabel;
@synthesize amountLabel;
@synthesize minusButton;
@synthesize plusButton;
@synthesize bill;
@synthesize tipPercentage = _tipPercentage;
@synthesize longPressTimer;
@synthesize percentFormatter = _percentFormatter;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  self.bill = [BLAppDelegate appDelegate].currentBill;
  self.tipPercentage = 0.2;
  
  [self showTourText:@"adjust the tip percentage\nby tapping +/-" atPoint:CGPointMake(5.0, 5.0) animated:NO];
}


#pragma mark - Property Implementations

- (NSNumberFormatter *)percentFormatter
{
  if (!_percentFormatter) {
    _percentFormatter = [[NSNumberFormatter alloc] init];
    _percentFormatter.roundingMode = NSNumberFormatterRoundHalfUp;
    _percentFormatter.roundingIncrement = [NSNumber numberWithFloat:0.01];
    _percentFormatter.numberStyle = NSNumberFormatterPercentStyle;
    _percentFormatter.maximumFractionDigits = 0;
    _percentFormatter.minimumFractionDigits = 0;
  }
  return _percentFormatter;
}


- (void)setTipPercentage:(float)tipPercentage
{
  _tipPercentage = tipPercentage;
  self.percentLabel.text = [self.percentFormatter stringFromNumber:[NSNumber numberWithFloat:self.tipPercentage]];
  self.bill.tip = (self.bill.subtotal + self.bill.tax) * self.tipPercentage;
  self.bill.total = self.bill.subtotal + self.bill.tax + self.bill.tip;
  self.amountLabel.text = [NSString stringWithFormat:@"$%.2f", self.bill.tip];
  [self.bill.managedObjectContext save:nil];
}


#pragma mark - IBAction Methods

- (void)incrementPercentage:(id)sender
{
  self.tipPercentage = MIN(self.tipPercentage + 0.01, 1.0);
  if (self.tipPercentage >= 1.0) {
    self.plusButton.enabled = NO;
    if (self.longPressTimer) {
      [self.longPressTimer invalidate];
      self.longPressTimer = nil;
    }
  }
  self.minusButton.enabled = YES;
  if (self.shouldShowTour) [self hideTourTextAnimated:YES complete:nil];
}


- (void)decrementPercentage:(id)sender
{
  self.tipPercentage = MAX(self.tipPercentage - 0.01, 0.0);
  if (self.tipPercentage <= 0.0) {
    self.minusButton.enabled = NO;
    if (self.longPressTimer) {
      [self.longPressTimer invalidate];
      self.longPressTimer = nil;
    }
  }
  self.plusButton.enabled = YES;
  if (self.shouldShowTour) [self hideTourTextAnimated:YES complete:nil];
}


- (void)nextScreen:(id)sender
{
  BLSummaryViewController *summaryController = [[BLSummaryViewController alloc] init];
  [self.navigationController pushViewController:summaryController animated:YES];
}


- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)handleIncrementLongPress:(UILongPressGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(incrementPercentage:) userInfo:nil repeats:YES];
  }
  else if (recognizer.state == UIGestureRecognizerStateEnded && self.longPressTimer) {
    [self.longPressTimer invalidate];
    self.longPressTimer = nil;
  }
}


- (void)handleDecrementLongPress:(UILongPressGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(decrementPercentage:) userInfo:nil repeats:YES];
  }
  else if (recognizer.state == UIGestureRecognizerStateEnded && self.longPressTimer) {
    [self.longPressTimer invalidate];
    self.longPressTimer = nil;
  }
}

@end
