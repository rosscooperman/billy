//
//  BLTaxViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/11/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLTaxViewController.h"
#import "BLTipViewController.h"
#import "Bill.h"
#import "LineItem.h"
#import "Assignment.h"


@interface BLTaxViewController ()

@property (nonatomic, strong) Bill *bill;
@property (nonatomic, assign) float taxPercentage;
@property (nonatomic, strong) NSTimer *longPressTimer;


- (void)updateTax:(double)amount;
- (void)updateLabels;
- (void)keyboardShown:(NSNotification *)notification;
- (void)keyboardHidden:(NSNotification *)notification;

@end


@implementation BLTaxViewController

@synthesize percentLabel;
@synthesize amountField;
@synthesize minusButton;
@synthesize plusButton;
@synthesize closeKeyboardRecognizer;
@synthesize bill;
@synthesize taxPercentage = _taxPercentage;
@synthesize longPressTimer;
@synthesize contentWrapper;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  self.bill = [BLAppDelegate appDelegate].currentBill;
  
  // calculate the subtotal from the available line items
  self.bill.subtotal = 0.0;
  [self.bill.lineItems enumerateObjectsUsingBlock:^(LineItem *lineItem, BOOL *stop) {
    self.bill.subtotal += lineItem.price;
  }];
  
  // if we don't have an established value for the bill's tax, try to get it from the receipt raw text
  if (!self.bill.tax && self.bill.rawText.length > 0) {
    NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines;
    
    NSString *pattern = @"[1tl]ax.+\\$?(\\d+\\.\\d{2})";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:nil];
    
    NSTextCheckingResult *result = nil;
    NSRange range = [self.bill.rawText rangeOfString:self.bill.rawText];
    result = [regex firstMatchInString:self.bill.rawText options:options range:range];
    
    if (result && result.range.length > 0) {
      self.bill.tax = [[self.bill.rawText substringWithRange:[result rangeAtIndex:1]] floatValue];
      if (self.bill.tax <= 0.0) self.bill.tax = 0.00001;
      self.taxPercentage = self.bill.tax / self.bill.subtotal;
    }
  }
  
  // still no tax value available? assume an average percentage
  if (!self.bill.tax) {
    self.taxPercentage = 0.07;
    self.bill.tax = self.bill.subtotal * self.taxPercentage;
  }
  
  // if, at this point, there's on tax percentage, calculate it based on the tax amount
  if (!self.taxPercentage || self.taxPercentage <= 0.0) {
    self.taxPercentage = self.bill.tax / self.bill.subtotal;
  }
  
  [self updateLabels];
}


- (void)viewWillAppear:(BOOL)animated
{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Instance Methods

- (void)updateLabels
{
  // roundabout way of testing whether the keyboard is currently shown (and so the amount label should not be touched)
  if (CGAffineTransformIsIdentity(self.contentWrapper.transform)) {
    self.amountField.text = [NSString stringWithFormat:@"%.2f", self.bill.tax];
    if (self.bill.tax <= 0.0) {
      self.minusButton.enabled = NO;
    }
    else {
      self.minusButton.enabled = YES;    
    }
  }
  self.percentLabel.text = [NSString stringWithFormat:@"%.3f%%", self.taxPercentage * 100.0];
  [self.bill.managedObjectContext save:nil];  
}


- (void)updateTax:(double)amount
{
  self.bill.tax = amount;
  _taxPercentage = (self.bill.tax == 0.0) ? 0.0 : self.bill.tax / self.bill.subtotal;
  [self updateLabels];
}


- (void)setTaxPercentage:(float)taxPercentage
{
  _taxPercentage = taxPercentage;
  self.bill.tax = self.taxPercentage * self.bill.subtotal;
  [self updateLabels];
}


- (void)keyboardShown:(NSNotification *)notification
{
  self.closeKeyboardRecognizer.enabled = YES;
  
  NSDictionary *info = [notification userInfo];
  CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
  [UIView animateWithDuration:duration animations:^{
    self.contentWrapper.transform = CGAffineTransformMakeTranslation(0.0, -(keyboardSize.height / 2.0));
  }];
}


- (void)keyboardHidden:(NSNotification *)notification
{
  self.closeKeyboardRecognizer.enabled = NO;
  
  NSDictionary *info = [notification userInfo];
  CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
  [UIView animateWithDuration:duration animations:^{
    self.contentWrapper.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    [self updateLabels];
  }];
}


#pragma mark - IBAction Methods

- (void)incrementAmount:(id)sender
{
  [self updateTax:self.bill.tax + 0.01];
}


- (void)decrementAmount:(id)sender
{
  if (self.bill.tax >= 0.01) {
    [self updateTax:self.bill.tax - 0.01];
  }
}


- (void)handleIncrementLongPress:(UILongPressGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(incrementAmount:) userInfo:nil repeats:YES];
  }
  else if (recognizer.state == UIGestureRecognizerStateEnded) {
    [self.longPressTimer invalidate];
    self.longPressTimer = nil;
  }  
}


- (void)handleDecrementLongPress:(UILongPressGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(decrementAmount:) userInfo:nil repeats:YES];
  }
  else if (recognizer.state == UIGestureRecognizerStateEnded) {
    [self.longPressTimer invalidate];
    self.longPressTimer = nil;
  }
}


- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)nextScreen:(id)sender
{
  BLTipViewController *tipController = [[BLTipViewController alloc] init];
  [self.navigationController pushViewController:tipController animated:YES];
}


- (void)closeKeyboard:(id)sender
{
  [self.amountField resignFirstResponder];
}


#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  self.plusButton.enabled = NO;
  self.minusButton.enabled = NO;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
  self.plusButton.enabled = YES;
  self.minusButton.enabled = YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

  NSCharacterSet *nonDigitsSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
  NSRange nonDigitRange = [newString rangeOfCharacterFromSet:nonDigitsSet];
  if (nonDigitRange.location != NSNotFound) {
    return NO;
  }
  
  [self updateTax:[newString floatValue]];
  return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return NO;
}

@end
