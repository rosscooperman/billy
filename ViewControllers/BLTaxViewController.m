//
//  BLTaxViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/11/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLTaxViewController.h"


@interface BLTaxViewController ()

@property (nonatomic, assign) float totalAmount;
@property (nonatomic, assign) float taxPercentage;
@property (nonatomic, assign) float taxAmount;


- (void)updateLabels;

@end


@implementation BLTaxViewController

@synthesize percentLabel;
@synthesize amountField;
@synthesize minusButton;
@synthesize plusButton;
@synthesize totalAmount;
@synthesize taxPercentage = _taxPercentage;
@synthesize taxAmount = _taxAmount;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines;
  
  NSString *pattern = @"[1tl]ax.+\\$?(\\d+\\.\\d{2})";
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:nil];
  
  NSString *rawText = [[BLAppDelegate appDelegate] rawText];
  NSRange range = [rawText rangeOfString:rawText];
  NSTextCheckingResult *result = [regex firstMatchInString:rawText options:options range:range];
  
  self.totalAmount = 0.0;
  [[[BLAppDelegate appDelegate] lineItems] enumerateObjectsUsingBlock:^(NSDictionary *lineItem, NSUInteger idx, BOOL *stop) {
    self.totalAmount += [[lineItem valueForKey:@"price"] floatValue] * [[lineItem valueForKey:@"quantity"] floatValue];
  }];
  if (self.totalAmount <= 0.0) self.totalAmount = 0.0001; // avoid divide by zero errors
  
  if (result.range.length > 0) {
    self.taxAmount = [[rawText substringWithRange:[result rangeAtIndex:1]] floatValue];
    self.taxPercentage = self.taxAmount / self.totalAmount;
  }
  else {
    self.taxPercentage = 0.07;
    self.taxAmount = self.taxPercentage * self.totalAmount;
  }
  
  [self updateLabels];
}


#pragma mark - Instance Methods

- (void)updateLabels
{
  self.amountField.text = [NSString stringWithFormat:@"%.2f", self.taxAmount];
  NSString *percentString = [NSString stringWithFormat:@"%.3f", self.taxPercentage * 100.0];
  NSCharacterSet *zeroSet = [NSCharacterSet characterSetWithCharactersInString:@"0"];
  self.percentLabel.text = [NSString stringWithFormat:@"%@%%", [percentString stringByTrimmingCharactersInSet:zeroSet]];
}


#pragma mark - Property Implementations


#pragma mark - IBAction Methods

- (void)incrementPercentage:(id)sender
{
  
}


- (void)decrementPercentage:(id)sender
{
  
}


- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)nextScreen:(id)sender
{
  
}


#pragma mark - UITextFieldDelegate Methods

@end
