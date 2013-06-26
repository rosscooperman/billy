//
//  BLSplitCountViewController.m
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIViewController+ButtonManagement.h"
#import "BLSplitCountViewController.h"
#import "BLNamesViewController.h"
#import "Bill.h"


// these imports are only for the shortcut in development functionality
#import "BLTaxTipViewController.h"
#import "BLSummaryViewController.h"
#import "BLSplitBillViewController.h"
#import "BLFixItemsViewController.h"
#import "Person.h"
#import "Assignment.h"


@interface BLSplitCountViewController ()

@property (nonatomic, strong) Bill *bill;
@property (nonatomic, assign) BOOL transitioned;


- (void)layoutControls;
- (void)setCount:(NSInteger)count;

@end


@implementation BLSplitCountViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad
{  
  // bump up the font size of the count label
  self.countLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:375.0];
  self.realView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"viewBackground"]];
  
  // show the "skip ahead switch" if in debug mode
  NSString *enableShortcuts = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BLEnableShortcuts"];
  if ([enableShortcuts isEqualToString:@"YES"]) {
    self.skipAheadSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"enableShortcuts"];
    self.skipAheadSwitch.hidden = NO;
  }
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
  CGFloat testTop = lineHeight, selectedTop = lineHeight;
  CGFloat closest = 1000.0f;
  
  while (testTop < self.controlView.superview.bounds.size.height) {
    CGFloat proximity = fabsf(idealTop - testTop);
    if (proximity < closest) {
      closest = proximity;
      selectedTop = testTop;
    }
    
    testTop += 45.0f + lineHeight;
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
  
  self.bill.splitCount = count;
}


#pragma mark - IBAction Methods

- (void)incrementCount:(id)sender
{
  self.count = self.bill.splitCount + 1;
}


- (void)decrementCount:(id)sender
{
  self.count = self.bill.splitCount - 1;
}


- (void)nextScreen:(id)sender
{
  if (self.skipAheadSwitch.on) {
    // \n1 Empire White 18.00\n2 Empire White 18.00\n2 Uni 18.00
    self.bill.rawText = @"2 Bread 0.00\n2 Bread 0.00\n2 Mussels 12.00\n2 Crudo 11.00\nSubtotal 23.00\nTax 2.04\nTotal 25.04";
    [self.bill.people enumerateObjectsUsingBlock:^(Person *person, BOOL *stop) {
      person.name = @"George";

      [self.bill.lineItems enumerateObjectsUsingBlock:^(LineItem *lineItem, BOOL *stop) {
        Assignment *assignment = [NSEntityDescription insertNewObjectForEntityForName:@"Assignment" inManagedObjectContext:self.bill.managedObjectContext];
        assignment.lineItem = lineItem;
        assignment.quantity = 1;
        assignment.person = person;
        [person addAssignmentsObject:assignment];
      }];
    }];
    self.bill.taxPercentage = 0.08875;
    self.bill.tipPercentage = 0.25;
    [self.bill.managedObjectContext save:nil];
    
    BLFixItemsViewController *shortcutController = [[BLFixItemsViewController alloc] init];
    [self.navigationController pushViewController:shortcutController animated:YES];
  }
  else {
    BLNamesViewController *namesController = [[BLNamesViewController alloc] init];
    [self.navigationController pushViewController:namesController animated:YES];
  }
}


- (void)toggleSkipAhead:(id)sender
{
  [[NSUserDefaults standardUserDefaults] setBool:self.skipAheadSwitch.on forKey:@"enableShortcuts"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  [self layoutControls];
}

@end
