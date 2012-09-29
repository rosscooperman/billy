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


- (void)setCount:(NSInteger)count;
- (void)transitionTour;

@end


@implementation BLSplitCountViewController

@synthesize countLabel;
@synthesize minusButton;
@synthesize plusButton;
@synthesize bill;
@synthesize nextScreenButton;
@synthesize coverView;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  [self showTourText:@"cycle through the number of splits\nby tapping +/-" atPoint:CGPointMake(5.0, 5.0) animated:NO];
  if (self.shouldShowTour) [self disableButton:self.nextScreenButton];
}


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


- (void)viewDidAppear:(BOOL)animated
{
  [[BLAppDelegate appDelegate] askForRating];
  [UIView animateWithDuration:5.0 animations:^{
    CATransform3D transform = CATransform3DMakeRotation(M_PI_2, 1.0f, 0.0f, 0.0f);
    transform.m11 = 0.001f;
    transform.m44 = -0.0015f;
    self.coverView.layer.transform = transform;
  }];
}


- (void)viewDidDisappear:(BOOL)animated
{
  [self hideTourTextAnimated:NO complete:nil];
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

@end
