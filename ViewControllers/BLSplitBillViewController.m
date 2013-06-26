//
//  BLSplitBillViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/2/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define TEXT_BOX_HEIGHT 45
#define QUANTITY_BOX_WIDTH 45
#define NAME_BOX_WIDTH 189
#define SPLIT_NAME_BOX_WIDTH 95
#define PRICE_BOX_WIDTH 72
#define BUTTON_WIDTH 45


#import "BLSplitBillViewController.h"
#import "UIViewController+ButtonManagement.h"
#import "BLTaxTipViewController.h"
#import "BLLineItem.h"
#import "BLSplitAdjuster.h"
#import "Bill.h"
#import "LineItem.h"
#import "Assignment.h"


@interface BLSplitBillViewController ()

@property (nonatomic, strong) Bill *bill;
@property (nonatomic, strong) BLSplitAdjuster *adjusterView;
@property (nonatomic, weak) BLLineItem *activeLineItem;


- (void)lineItemTapped:(id)sender;
- (void)showAdjusterAt:(BLLineItem *)theLineItem;
- (void)hideAdjuster:(void(^)())complete;
- (void)displayValidationFailures;

@end


@implementation BLSplitBillViewController

@synthesize contentArea;
@synthesize nextScreenButton;
@synthesize bill;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  self.bill = [BLAppDelegate appDelegate].currentBill;
  
  NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
  NSArray *sortedLineItems = [self.bill.lineItems sortedArrayUsingDescriptors:descriptors];
  
  __block NSUInteger currentIndex = 0;
  [sortedLineItems enumerateObjectsUsingBlock:^(LineItem *lineItem, NSUInteger i, BOOL *stop) {
    if (lineItem.quantity > 0 && lineItem.price > 0) {
      BLLineItem *lineItemView = [[BLLineItem alloc] initWithLineItem:lineItem atIndex:currentIndex++];
      [lineItemView addTarget:self action:@selector(lineItemTapped:) forControlEvents:UIControlEventTouchUpInside];
      [self.contentArea addSubview:lineItemView];
      self.contentArea.contentSize = CGSizeMake(320.0f, CGRectGetMaxY(lineItemView.frame) + (1.0f / [UIScreen mainScreen].scale));
    }
  }];
  
  self.adjusterView = [[BLSplitAdjuster alloc] initWithBill:self.bill];
  
  // the adjuster view needs to be positioned out of view to start (if there are fewer than 2 line items it will be peeking out)
  self.adjusterView.transform = CGAffineTransformMakeTranslation(0.0f, -self.adjusterView.frame.size.height);
  
  [self.contentArea insertSubview:self.adjusterView atIndex:0];
}


#pragma mark - Instance Methods

- (void)showAdjusterAt:(BLLineItem *)theLineItem
{
  void(^showBlock)() = ^{
    self.activeLineItem = theLineItem;
    self.adjusterView.lineItem = theLineItem.lineItem;
    
    // set the starting transform of the adjuster view
    self.adjusterView.transform = CGAffineTransformMakeTranslation(0.0f, CGRectGetMaxY(theLineItem.frame) - self.adjusterView.frame.size.height);
    
    // set the transform of each lineItem, the ending transform for the adjuster, and the new contentSize for the contentArea
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0f, self.adjusterView.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
      [self.contentArea.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger i, BOOL *stop) {
        if ([subview isKindOfClass:[BLLineItem class]] && [(BLLineItem *)subview index] > theLineItem.index) {
          subview.transform = transform;
        }
      }];
      self.adjusterView.transform = CGAffineTransformMakeTranslation(0.0f, CGRectGetMaxY(theLineItem.frame));
      self.contentArea.contentSize = CGSizeMake(320.0f, self.contentArea.contentSize.height + self.adjusterView.frame.size.height);
    }];
  };
  
  if (self.activeLineItem) {
    [self hideAdjuster:showBlock];
  }
  else {
    showBlock();
  }
}


- (void)hideAdjuster:(void(^)())complete
{
  [UIView animateWithDuration:0.3f animations:^{
    [self.contentArea.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger i, BOOL *stop) {
      if ([subview isKindOfClass:[BLLineItem class]]) subview.transform = CGAffineTransformIdentity;
    }];
    CGFloat transformY = CGRectGetMaxY(self.activeLineItem.frame) - self.adjusterView.frame.size.height;
    self.adjusterView.transform = CGAffineTransformMakeTranslation(0.0f, transformY);
    self.contentArea.contentSize = CGSizeMake(320.0f, self.contentArea.contentSize.height - self.adjusterView.frame.size.height);
  } completion:^(BOOL finished) {
    self.activeLineItem = nil;
    if (complete) complete();
  }];
}


- (void)displayValidationFailures
{
  [self.contentArea.subviews enumerateObjectsUsingBlock:^(BLLineItem *subview, NSUInteger i, BOOL *stop) {
    if ([subview isKindOfClass:[BLLineItem class]]) {
      [subview updateCompletionStatus];
    }
  }];
}


#pragma mark - IBAction Methods

- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)nextScreen:(id)sender
{
  if ([self.bill validateLineItems]) {
    BLTaxTipViewController *taxController = [[BLTaxTipViewController alloc] init];
    [self.navigationController pushViewController:taxController animated:YES];
  }
  else {
    [self displayValidationFailures];
  }
}


- (void)lineItemTapped:(id)sender
{
  if (self.activeLineItem == sender) {
    [self hideAdjuster:nil];
  }
  else {
    [self showAdjusterAt:sender];
  }
}

@end
