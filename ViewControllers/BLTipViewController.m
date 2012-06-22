//
//  BLTipViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/16/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLTipViewController.h"
#import "BLSummaryViewController.h"


@interface BLTipViewController ()

@property (nonatomic, assign) float totalAmount;
@property (nonatomic, assign) float tipPercentage;
@property (nonatomic, strong) NSTimer *longPressTimer;
@property (nonatomic, readonly) NSNumberFormatter *percentFormatter;


@end


@implementation BLTipViewController

@synthesize percentLabel;
@synthesize amountLabel;
@synthesize minusButton;
@synthesize plusButton;
@synthesize totalAmount;
@synthesize tipPercentage = _tipPercentage;
@synthesize longPressTimer;
@synthesize percentFormatter = _percentFormatter;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  self.totalAmount = 0.0;
  [[[BLAppDelegate appDelegate] lineItems] enumerateObjectsUsingBlock:^(NSDictionary *lineItem, NSUInteger idx, BOOL *stop) {
    self.totalAmount += [[lineItem valueForKey:@"price"] floatValue];
  }];
  self.totalAmount += [[BLAppDelegate appDelegate] taxAmount];
  self.tipPercentage = 0.2;
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
  self.amountLabel.text = [NSString stringWithFormat:@"$%.2f", self.totalAmount * self.tipPercentage];
}


#pragma mark - IBAction Methods

- (void)incrementPercentage:(id)sender
{
  self.tipPercentage += 0.01;
  self.tipPercentage = MIN(self.tipPercentage, 1.0);
  if (self.tipPercentage >= 1.0) {
    self.plusButton.enabled = NO;
    if (self.longPressTimer) {
      [self.longPressTimer invalidate];
      self.longPressTimer = nil;
    }
  }
  self.minusButton.enabled = YES;
}


- (void)decrementPercentage:(id)sender
{
  self.tipPercentage -= 0.01;
  self.tipPercentage = MAX(self.tipPercentage, 0.0);
  if (self.tipPercentage <= 0.0) {
    self.minusButton.enabled = NO;
    if (self.longPressTimer) {
      [self.longPressTimer invalidate];
      self.longPressTimer = nil;
    }
  }
  self.plusButton.enabled = YES;
}


- (void)nextScreen:(id)sender
{
  [[BLAppDelegate appDelegate] setTipAmount:(self.tipPercentage * self.totalAmount)];
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
