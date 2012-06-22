//
//  BLTaxViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/11/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLTaxViewController.h"
#import "BLTipViewController.h"


@interface BLTaxViewController ()

@property (nonatomic, assign) float totalAmount;
@property (nonatomic, assign) float taxPercentage;
@property (nonatomic, assign) float taxAmount;
@property (nonatomic, readonly) NSNumberFormatter *percentFormatter;
@property (nonatomic, strong) NSTimer *longPressTimer;


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
@synthesize totalAmount;
@synthesize taxPercentage = _taxPercentage;
@synthesize taxAmount = _taxAmount;
@synthesize percentFormatter = _percentFormatter;
@synthesize longPressTimer;
@synthesize contentWrapper;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines;
  
  NSString *pattern = @"[1tl]ax.+\\$?(\\d+\\.\\d{2})";
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:nil];
  
  NSString *rawText = [[BLAppDelegate appDelegate] rawText];
  NSTextCheckingResult *result = nil;
  if (rawText.length > 0) {
    NSRange range = [rawText rangeOfString:rawText];
    result = [regex firstMatchInString:rawText options:options range:range];
  }
  
  self.totalAmount = 0.0;
  [[[BLAppDelegate appDelegate] lineItems] enumerateObjectsUsingBlock:^(NSDictionary *lineItem, NSUInteger idx, BOOL *stop) {
    self.totalAmount += [[lineItem valueForKey:@"price"] floatValue];
  }];
  if (self.totalAmount <= 0.0) self.totalAmount = 0.0001; // avoid divide by zero errors
  
  if (result && result.range.length > 0) {
    self.taxAmount = [[rawText substringWithRange:[result rangeAtIndex:1]] floatValue];
  }
  else {
    self.taxPercentage = 0.07;
  }
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
    self.amountField.text = [NSString stringWithFormat:@"%.2f", self.taxAmount];
    if (self.taxAmount <= 0.0) {
      self.minusButton.enabled = NO;
    }
    else {
      self.minusButton.enabled = YES;    
    }
  }
  self.percentLabel.text = [self.percentFormatter stringFromNumber:[NSNumber numberWithFloat:self.taxPercentage]];
}


- (void)setTaxAmount:(float)taxAmount
{
  _taxAmount = taxAmount;
  _taxPercentage = (self.taxAmount == 0.0) ? 0.0 : self.taxAmount / self.totalAmount;
  [self updateLabels];
}


- (void)setTaxPercentage:(float)taxPercentage
{
  _taxPercentage = taxPercentage;
  _taxAmount = self.taxPercentage * self.totalAmount;
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


#pragma mark - Property Implementations

- (NSNumberFormatter *)percentFormatter
{
  if (!_percentFormatter) {
    _percentFormatter = [[NSNumberFormatter alloc] init];
    _percentFormatter.roundingMode = NSNumberFormatterRoundHalfUp;
    _percentFormatter.roundingIncrement = [NSNumber numberWithFloat:0.005];
    _percentFormatter.numberStyle = NSNumberFormatterPercentStyle;
    _percentFormatter.maximumFractionDigits = 3;
  }
  return _percentFormatter;
}


#pragma mark - IBAction Methods

- (void)incrementAmount:(id)sender
{
  self.taxAmount += 0.01;
}


- (void)decrementAmount:(id)sender
{
  if (self.taxAmount >= 0.01) {
    self.taxAmount -= 0.01;
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
  [[BLAppDelegate appDelegate] setTaxAmount:self.taxAmount];
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
  textField.text = [newString stringByTrimmingCharactersInSet:nonDigitsSet];
  
  self.taxAmount = [textField.text floatValue];
  return NO;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return NO;
}

@end
