//
//  BLSplitCountViewController.m
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIViewController+GuidedTour.h"
#import "UIViewController+ButtonManagement.h"
#import "BLSplitCountViewController.h"
#import "BLNamesViewController.h"
#import "Bill.h"


@interface BLSplitCountViewController ()

@property (nonatomic, strong) Bill *bill;
@property (nonatomic, assign) BOOL transitioned;


- (void)layoutControls;
- (void)setCount:(NSInteger)count;
- (void)transitionTour;

@end


@implementation BLSplitCountViewController

@synthesize countLabel;
@synthesize controlView;
@synthesize minusButton;
@synthesize plusButton;
@synthesize bill;
@synthesize nextScreenButton;
@synthesize realView;
@synthesize fauxHeader;
@synthesize transitioned;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  [self showTourText:@"cycle through the number of splits\nby tapping +/-" atPoint:CGPointMake(5.0, 5.0) animated:NO];
  if (self.shouldShowTour) [self disableButton:self.nextScreenButton];
  
  // bump up the font size of the count label
  self.countLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:375.0];
  self.realView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"viewBackground"]];  
}


- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.bill = [BLAppDelegate appDelegate].currentBill;
  [self setCount:self.bill.splitCount];
  [self layoutControls];
  
  if (!self.transitioned) [self.controlView.superview addObserver:self forKeyPath:@"frame" options:0 context:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
  [[BLAppDelegate appDelegate].managedObjectContext save:nil];  
  if (!self.transitioned) [self.controlView.superview removeObserver:self forKeyPath:@"frame"];
}


- (void)viewDidAppear:(BOOL)animated
{
  self.realView.frame = self.view.frame;
  if (self.transitioned) return;

  [UIView transitionFromView:self.view toView:self.realView duration:1.0 options:UIViewAnimationOptionTransitionCurlUp completion:^(BOOL finished) {
    self.navigationController.navigationBarHidden = NO;    
    [[BLAppDelegate appDelegate] askForRating];
  }];
}


- (void)viewDidDisappear:(BOOL)animated
{
  [self hideTourTextAnimated:NO complete:nil];
  if (!self.transitioned) {
    self.view = self.realView;
    
    CGRect newFrame = self.controlView.superview.frame;
    newFrame.origin.y = self.fauxHeader.frame.origin.y;
    newFrame.size.height += self.fauxHeader.frame.size.height;
    self.controlView.superview.frame = newFrame;
    [self.fauxHeader removeFromSuperview];

    self.transitioned = YES;
  }
}


#pragma mark - Instance Methods

- (void)layoutControls
{
  CGFloat idealTop = CGRectGetMidY(self.controlView.superview.bounds) - (self.controlView.bounds.size.height / 2.0f);
  CGFloat lineHeight = 1.0f / [UIScreen mainScreen].scale;
  CGFloat testTop = -lineHeight, selectedTop = -lineHeight;
  CGFloat closest = 1000.0f;
  
  while (testTop < self.controlView.superview.bounds.size.height) {
    CGFloat proximity = fabsf(idealTop - testTop);
    if (proximity < closest) {
      closest = proximity;
      selectedTop = testTop;
    }
    
    testTop += 45.0f + (1.5f * lineHeight);
  }
  
  CGRect newFrame = self.controlView.frame;
  newFrame.origin.y = selectedTop;
  self.controlView.frame = newFrame;
}


- (void)setCount:(NSInteger)count
{
  self.minusButton.enabled = YES;
  self.plusButton.enabled = YES;
  self.countLabel.text = [NSString stringWithFormat:@"%d", count];
  self.countLabel.textColor = [[BLAppDelegate appDelegate] tertiaryColorAtIndex:count];
  
  if (count <= 2) {
    self.minusButton.enabled = NO;
  }
  else if (count >= 8) {
    self.plusButton.enabled = NO;
  }
}


-(void)transitionTour
{
  if (self.nextScreenButton.enabled) return;
  
  [self enableButton:self.nextScreenButton type:BLButtonTypeForward];
  [self hideTourTextAnimated:YES complete:^{
    [self showTourText:@"tap the check to continue" atPoint:CGPointMake(315.0, 400.0) animated:YES];
    [self markTourShown];
  }];
}


#pragma mark - IBAction Methods

- (void)incrementCount:(id)sender
{
  [self setCount:++self.bill.splitCount];
  [self transitionTour];
}


- (void)decrementCount:(id)sender
{
  [self setCount:--self.bill.splitCount];
  [self transitionTour];
}


- (void)nextScreen:(id)sender
{
  BLNamesViewController *namesController = [[BLNamesViewController alloc] init];
  [self.navigationController pushViewController:namesController animated:YES];
}


#pragma mark - KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  [self layoutControls];
}

@end
