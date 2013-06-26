//
//  BLFixItemsViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/1/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define TEXT_BOX_HEIGHT 45.0f
#define QUANTITY_BOX_WIDTH 40.0f
#define PRICE_BOX_WIDTH 85.0f


#import <QuartzCore/QuartzCore.h>

#import "UIViewController+ButtonManagement.h"
#import "BLFixItemsViewController.h"
#import "BLSplitBillViewController.h"
#import "BLTextField.h"
#import "BLEditableLineItem.h"
#import "BLScrollView.h"
#import "Bill.h"
#import "LineItem.h"
#import "Assignment.h"


@interface BLFixItemsViewController ()

@property (nonatomic, strong) Bill *bill;
@property (nonatomic, strong) UIView *contentBackground;
@property (nonatomic, assign) CGFloat borderWidth;


- (void)keyboardShown:(NSNotification *)notification;
- (void)keyboardHidden:(NSNotification *)notification;
- (void)managedObjectChanged:(NSNotification *)notification;
- (void)lineItemsRemoved:(NSArray *)lineItems;
- (void)lineItemsAdded:(NSArray *)lineItems;

@end


@implementation BLFixItemsViewController

@synthesize contentArea;
@synthesize addLineItemButton;
@synthesize tapRecognizer;
@synthesize bill;
@synthesize contentBackground;
@synthesize borderWidth;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  self.borderWidth = 1.0f / [UIScreen mainScreen].scale;
  self.bill = [BLAppDelegate appDelegate].currentBill;
  
  NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
  NSArray *sortedLineItems = [self.bill.lineItems sortedArrayUsingDescriptors:descriptors];
  
  [sortedLineItems enumerateObjectsUsingBlock:^(LineItem *lineItem, NSUInteger i, BOOL *stop) {
    BLEditableLineItem *lineItemView = [[BLEditableLineItem alloc] initWithLineItem:lineItem];
    [self.contentArea addSubview:lineItemView];
    self.contentArea.contentSize = CGSizeMake(320.0f, CGRectGetMaxY(lineItemView.frame) + (1.0f / [UIScreen mainScreen].scale));
  }];
}


- (void)viewWillAppear:(BOOL)animated
{
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
  [center addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
  [center addObserver:self selector:@selector(managedObjectChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidAppear:(BOOL)animated
{
  if (self.navigationController.navigationBarHidden) {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
  }
}


#pragma mark - Instance Methods

- (void)keyboardShown:(NSNotification *)notification
{
  NSDictionary *info = [notification userInfo];
  CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

  UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 0.0f, keyboardSize.height, 0.0f);
  self.contentArea.contentInset = contentInsets;
  self.contentArea.scrollIndicatorInsets = contentInsets;
  
  __block BLEditableLineItem *activeView = nil;
  [self.contentArea.subviews enumerateObjectsUsingBlock:^(BLEditableLineItem *view, NSUInteger idx, BOOL *stop) {
    if ([view respondsToSelector:@selector(isActive)] && [view isActive]) activeView = view;
  }];
  if (!activeView) return;

  // build a CGRect that represents the portion of the contentArea that will be visible with the keyboard shown
  // this is tricky to do because the contentArea takes up some, but not all, of the space the keyboard will occupy
  CGRect frame = self.contentArea.frame;
  CGPoint windowOrigin = [[BLAppDelegate appDelegate].window convertPoint:frame.origin fromView:self.contentArea.superview];
  CGFloat maxY = windowOrigin.y + frame.size.height;
  frame.size.height -= (keyboardSize.height - (480.0f - maxY));
  frame = CGRectOffset(frame, self.contentArea.contentOffset.x, self.contentArea.contentOffset.y);

  // now create a test point that represents the bottom left corner of the view the user tapped on
  CGPoint testPoint = activeView.frame.origin;
  testPoint.y += activeView.frame.size.height;
  
  // if the bottom left corner of the tapped view is obscurred (entirely or partially) scroll the contentArea to compensate
  if (!CGRectContainsPoint(frame, testPoint) ) {
    CGPoint scrollPoint = CGPointMake(0.0f, activeView.frame.origin.y + activeView.frame.size.height + 16.0f - keyboardSize.height);
    [self.contentArea setContentOffset:scrollPoint animated:YES];
  }
}


- (void)keyboardHidden:(NSNotification *)notification
{
  [UIView animateWithDuration:0.3f animations:^{
    self.contentArea.contentInset = self.contentArea.scrollIndicatorInsets = UIEdgeInsetsZero;
  }];
}


- (void)lineItemsRemoved:(NSArray *)lineItems
{
  __block BOOL foundSpot = NO;
  __block CGFloat shiftHeight = 0.0f;
  __block UIView *foundView = nil;
  
  [UIView animateWithDuration:0.2 animations:^{
    [lineItems enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
      if (obj.entity == [NSEntityDescription entityForName:@"LineItem" inManagedObjectContext:self.bill.managedObjectContext]) {
        [self.contentArea.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
          if (foundSpot) {
            subview.frame = CGRectOffset(subview.frame, 0.0f, -shiftHeight);
          }
          else if ([subview isKindOfClass:[BLEditableLineItem class]]) {
            BLEditableLineItem *lineItemView = (BLEditableLineItem *)subview;
            foundSpot = (lineItemView.lineItem == obj);
            shiftHeight = lineItemView.frame.size.height;
            foundView = subview;
            
            if (foundSpot) {
              CGRect newFrame = subview.frame;
              newFrame.size.height = 0.0f;
              subview.frame = newFrame;
            }
          }
        }];
      }
    }];
    
    if (foundSpot) self.contentArea.bottomBorder.frame = CGRectOffset(self.contentArea.bottomBorder.frame, 0.0f, -shiftHeight);
  } completion:^(BOOL finished) {
    self.contentArea.contentSize = CGSizeMake(self.contentArea.contentSize.width, self.contentArea.contentSize.height - shiftHeight);
    if (foundView) [foundView removeFromSuperview];
  }];
}


- (void)lineItemsAdded:(NSArray *)lineItems
{
  __block CGFloat extraHeight = 0.0f;
  NSMutableArray *addedLineItems = [NSMutableArray arrayWithCapacity:lineItems.count];
  
  UIView *maskingView = [self.contentArea.subviews lastObject];
  
  [lineItems enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
    if (obj.entity == [NSEntityDescription entityForName:@"LineItem" inManagedObjectContext:self.bill.managedObjectContext]) {
      LineItem *lineItem = (LineItem *)obj;
      BLEditableLineItem *lineItemView = [[BLEditableLineItem alloc] initWithLineItem:lineItem];
      [addedLineItems addObject:lineItemView];
      
      extraHeight += lineItemView.frame.size.height;
      lineItemView.transform = CGAffineTransformMakeTranslation(0.0f, -lineItemView.frame.size.height);
      
      if (maskingView) {
        [self.contentArea insertSubview:lineItemView belowSubview:maskingView];
      }
      else {
        [self.contentArea addSubview:lineItemView];
      }
    }
  }];

  [UIView animateWithDuration:0.2 animations:^{
    if (CGRectGetMaxY(self.contentArea.frame) >= CGRectGetMaxY(self.contentArea.bottomBorder.frame)) {
      self.contentArea.bottomBorder.frame = CGRectOffset(self.contentArea.bottomBorder.frame, 0.0f, extraHeight);
    }
    [addedLineItems enumerateObjectsUsingBlock:^(BLEditableLineItem *lineItem, NSUInteger idx, BOOL *stop) {
      lineItem.transform = CGAffineTransformIdentity;
    }];
  } completion:^(BOOL finished) {
    self.contentArea.contentSize = CGSizeMake(self.contentArea.contentSize.width, self.contentArea.contentSize.height + extraHeight);
    if (addedLineItems.count > 0) [[addedLineItems objectAtIndex:0] becomeFirstResponder];
    if (maskingView) {
      [addedLineItems enumerateObjectsUsingBlock:^(BLEditableLineItem *lineItem, NSUInteger idx, BOOL *stop) {
        [lineItem.superview bringSubviewToFront:lineItem];
      }];
    }
  }];
}


- (void)managedObjectChanged:(NSNotification *)notification
{
  [self lineItemsRemoved:[notification.userInfo objectForKey:NSDeletedObjectsKey]];
  [self lineItemsAdded:[notification.userInfo objectForKey:NSInsertedObjectsKey]];
}


#pragma mark - IBAction Methods

- (void)contentAreaTapped:(UITapGestureRecognizer *)recognizer
{
  [self.contentArea.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
    [subview resignFirstResponder];
  }];
}


- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)acceptChanges:(id)sender
{
  BLSplitBillViewController *splitBillController = [[BLSplitBillViewController alloc] init];
  [self.navigationController pushViewController:splitBillController animated:YES];
}


- (void)addRow:(id)sender
{
  NSManagedObjectContext *context = [BLAppDelegate appDelegate].managedObjectContext;
  LineItem *lineItem = [NSEntityDescription insertNewObjectForEntityForName:@"LineItem" inManagedObjectContext:context];
  lineItem.index = self.bill.lineItems.count;

  [self.bill addLineItemsObject:lineItem];
  [self.bill.managedObjectContext save:nil];
}

@end
