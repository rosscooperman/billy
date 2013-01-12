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

#import "UIViewController+GuidedTour.h"
#import "UIViewController+ButtonManagement.h"
#import "BLFixItemsViewController.h"
#import "BLSplitBillViewController.h"
#import "BLTextField.h"
#import "BLEditableLineItem.h"
#import "Bill.h"
#import "LineItem.h"
#import "Assignment.h"


typedef enum {
  BLTourStepStart = 0,
  BLTourStepQuantity,
  BLTourStepDescription,
  BLTourStepPrice,
  BLTourStepFinishFirstItem,
  BLTourStepSecondItem,
  BLTourStepFinishSecondItem,
  BLTourStepThirdItem,
  BLTourStepFinishThirdItem,
  BLTourStepDeleteItem,
  BLTourStepDeletedItem,
  BLTourStepAddAfterDelete,
  BLTourStepDone
} BLTourStep;


@interface BLFixItemsViewController ()

@property (nonatomic, strong) NSMutableArray *dataFields;
@property (nonatomic, strong) Bill *bill;
@property (nonatomic, assign) BLTourStep tourStep;
@property (readonly) CGPoint tourInsertionPoint;
@property (nonatomic, assign) BOOL shouldMarkTourShown;
@property (nonatomic, strong) UIView *contentBackground;
@property (nonatomic, assign) CGFloat borderWidth;


- (void)keyboardShown:(NSNotification *)notification;
- (void)keyboardHidden:(NSNotification *)notification;
- (BOOL)validateLineItems;
- (void)nextTourStep;

@end


@implementation BLFixItemsViewController

@synthesize contentArea;
@synthesize nextScreenButton;
@synthesize previousScreenButton;
@synthesize addLineItemButton;
@synthesize tapRecognizer;
@synthesize dataFields;
@synthesize bill;
@synthesize tourStep;
@synthesize contentBackground;
@synthesize borderWidth;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  self.borderWidth = 1.0f / [UIScreen mainScreen].scale;
  self.bill = [BLAppDelegate appDelegate].currentBill;
  
  // if we're supposed to show the guided tour text, do so now
  if (self.shouldShowTour) {
    self.tourStep = BLTourStepStart;
    [self nextTourStep];
  }
  else {
    self.tourStep = BLTourStepDone;
  }
}


- (void)viewWillAppear:(BOOL)animated
{
  NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
  NSArray *sortedLineItems = [self.bill.lineItems sortedArrayUsingDescriptors:descriptors];
  
  [sortedLineItems enumerateObjectsUsingBlock:^(LineItem *lineItem, NSUInteger i, BOOL *stop) {
    BLEditableLineItem *lineItemView = [[BLEditableLineItem alloc] initWithLineItem:lineItem];
    [self.contentArea addSubview:lineItemView];
    self.contentArea.contentSize = CGSizeMake(320.0f, CGRectGetMaxY(lineItemView.frame) + (1.0f / [UIScreen mainScreen].scale));
  }];
    
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
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


- (void)viewDidDisappear:(BOOL)animated
{
  [self hideTourTextAnimated:NO complete:nil];
  if (self.shouldMarkTourShown) [self markTourShown];
}


#pragma mark - Property Implementations

- (CGPoint)tourInsertionPoint
{
  if (self.dataFields.count > 0) {
    NSDictionary *fields = [self.dataFields lastObject];
    UIView *field = [fields objectForKey:@"quantity"];
    return CGPointMake(5.0, CGRectGetMaxY(field.superview.frame) - 15.0);
  }
  return CGPointMake(5.0, 5.0);
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

  CGRect frame = self.contentArea.frame;
  frame.size.height -= keyboardSize.height;
  CGPoint translatedOrigin = [self.view convertPoint:activeView.frame.origin fromView:self.contentArea];
  translatedOrigin.y += frame.size.height + 10.0f;
  
  if (!CGRectContainsPoint(frame, translatedOrigin) ) {
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


- (void)nextTourStep
{
  switch (self.tourStep) {
    // the tour is just beginning, do a bunch of setup
    case BLTourStepStart: {
      self.tourStep = BLTourStepQuantity;
      
      [self showTourText:@"start by entering items\nadd a quantity..." atPoint:self.tourInsertionPoint animated:NO];
      
      [self disableButton:self.nextScreenButton];
      [self disableButton:self.previousScreenButton];
      [self disableButton:self.addLineItemButton];
      self.tapRecognizer.enabled = NO;
      
      [[[self.dataFields objectAtIndex:0] objectForKey:@"quantity"] setReturnKeyType:UIReturnKeyNext];
      [[[self.dataFields objectAtIndex:0] objectForKey:@"name"] setReturnKeyType:UIReturnKeyNext];
      [[[self.dataFields objectAtIndex:0] objectForKey:@"price"] setEnablesReturnKeyAutomatically:YES];
            
      break;
    }
    
    // the user has entered a quantity, move on to description
    case BLTourStepQuantity: {
      self.tourStep = BLTourStepDescription;
      
      [self hideTourTextAnimated:YES complete:^{
        [self showTourText:@"...a short description..." atPoint:self.tourInsertionPoint animated:YES];
      }];
      break;
    }
      
    case BLTourStepDescription: {
      self.tourStep = BLTourStepPrice;
      
      [self hideTourTextAnimated:YES complete:^{
        [self showTourText:@"...and a price" atPoint:self.tourInsertionPoint animated:YES];
      }];
      break;
    }
      
    case BLTourStepPrice: {
      self.tourStep = BLTourStepFinishFirstItem;
      
      [self hideTourTextAnimated:YES complete:^{
        [self showTourText:@"tap 'done' when you're...done" atPoint:self.tourInsertionPoint animated:YES];
      }];
      break;
    }
      
    case BLTourStepFinishFirstItem: {
      self.tourStep = BLTourStepSecondItem;
      
      [[self.dataFields objectAtIndex:0] enumerateKeysAndObjectsUsingBlock:^(NSString *key, UITextField *field, BOOL *stop) {
        field.returnKeyType = UIReturnKeyDone;
        field.enablesReturnKeyAutomatically = NO;
      }];
      
      [self hideTourTextAnimated:YES complete:^{
        [self showTourText:@"awesome!\nadd another item with the +" atPoint:self.tourInsertionPoint animated:YES];
        [self enableButton:self.addLineItemButton type:BLButtonTypeOther];
      }];
      break;
    }
      
    case BLTourStepSecondItem: {
      self.tourStep = BLTourStepFinishSecondItem;
      
      [self disableButton:self.addLineItemButton];
      self.tapRecognizer.enabled = YES;
      [self hideTourTextAnimated:YES complete:^{
        [self addRow:nil];
      }];
      break;
    }
      
    case BLTourStepFinishSecondItem: {
      __block BOOL blankField = NO;
      [self.dataFields.lastObject enumerateKeysAndObjectsUsingBlock:^(NSString *key, UITextField *field, BOOL *stop) {
        if (field.text.length == 0) {
          blankField = YES;
          *stop = YES;
        }
      }];
      
      if (!blankField) {
        self.tourStep = BLTourStepThirdItem;
        [self showTourText:@"amazing!\nlet's add one more before continuing" atPoint:self.tourInsertionPoint animated:YES];
        [self enableButton:self.addLineItemButton type:BLButtonTypeOther];
      }
      
      break;
    }
      
    case BLTourStepThirdItem: {
      self.tourStep = BLTourStepFinishThirdItem;
      
      [self disableButton:self.addLineItemButton];
      self.tapRecognizer.enabled = YES;
      [self hideTourTextAnimated:YES complete:^{
        [self addRow:nil];
      }];
      break;
    }
      
    case BLTourStepFinishThirdItem: {
      __block BOOL blankField = NO;
      [self.dataFields.lastObject enumerateKeysAndObjectsUsingBlock:^(NSString *key, UITextField *field, BOOL *stop) {
        if (field.text.length == 0) {
          blankField = YES;
          *stop = YES;
        }
      }];
      
      if (!blankField) {
        self.tourStep = BLTourStepDeleteItem;
        [self showTourText:@"whoopsies.\nswipe to delete that third item" atPoint:self.tourInsertionPoint animated:YES];
      }
      
      break;
    }
      
    case BLTourStepDeleteItem: {
      self.tourStep = BLTourStepDeletedItem;
      
      [self hideTourTextAnimated:YES complete:^{
        self.shouldMarkTourShown = YES;
        
        NSString *text = @"professional swiping skills!\nif you want to undelete the item\njust swipe again";
        [self showTourText:text atPoint:self.tourInsertionPoint animated:YES];
        [self showTourText:@"let's continue" atPoint:CGPointMake(315.0, 400.0) animated:YES];
        
        [self enableButton:self.previousScreenButton type:BLButtonTypeBack];
        [self enableButton:self.nextScreenButton type:BLButtonTypeForward];
        [self enableButton:self.addLineItemButton type:BLButtonTypeOther];
      }];
      break;
    }
    
    case BLTourStepDeletedItem: {
      self.tourStep = BLTourStepDone;
      [self hideTourTextAnimated:YES complete:nil];
      break;
    }
      
    case BLTourStepAddAfterDelete: {
      self.tourStep = BLTourStepDone;
      
      [self hideTourTextAnimated:YES complete:^{
        [self addRow:nil];
      }];
      break;
    }
      
    case BLTourStepDone:
      break;
  }
}


- (BOOL)validateLineItems
{
  __block BOOL valid = YES;
  [self.dataFields enumerateObjectsUsingBlock:^(NSDictionary *fields, NSUInteger idx, BOOL *stop) {
    [fields enumerateKeysAndObjectsUsingBlock:^(NSString *key, UITextField *field, BOOL *stop) {
      if (!field.enabled) {
        return;
      }
      else if (field.text.length <= 0) {
        field.backgroundColor = [UIColor redColor];
        valid = NO;
      }
      else {
        // HERE BE WHERE A LITTLE TRIANGLE WILL GET ADDED
        //field.backgroundColor = [UIColor colorWithWhite:0.88627451 alpha:1.0];
      }
    }];    
  }];
  return valid;
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
  if ([self validateLineItems]) {
    BLSplitBillViewController *splitBillController = [[BLSplitBillViewController alloc] init];
    [self.navigationController pushViewController:splitBillController animated:YES];
  }
}


- (void)addRow:(id)sender
{
  if (self.tourStep == BLTourStepSecondItem || self.tourStep == BLTourStepThirdItem || self.tourStep == BLTourStepDeletedItem) {
    if (self.tourStep == BLTourStepDeletedItem) self.tourStep = BLTourStepAddAfterDelete;
    [self nextTourStep];
    return;
  }
  
//  NSManagedObjectContext *context = [BLAppDelegate appDelegate].managedObjectContext;
//  LineItem *lineItem = [NSEntityDescription insertNewObjectForEntityForName:@"LineItem" inManagedObjectContext:context];
//  lineItem.index = self.lineItems.count;
//  
//  [self.bill addLineItemsObject:lineItem];
//  [self.lineItems addObject:lineItem];
//  
//  UIView *newRow = [self generateViewForIndex:lineItem.index];
//  [self.contentArea addSubview:newRow];
//  self.contentArea.contentSize = CGSizeMake(320.0f, (TEXT_BOX_HEIGHT + self.borderWidth) * self.bill.lineItems.count);
//  self.contentBackground.frame = (CGRect){ CGPointMake(0.0f, -self.borderWidth), self.contentArea.contentSize };
//  
//  NSDictionary *fields = [self.dataFields objectAtIndex:lineItem.index];
//  BLTextField *field = [fields objectForKey:@"quantity"];
//  [field becomeFirstResponder];
}

@end
