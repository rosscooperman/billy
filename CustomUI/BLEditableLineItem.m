//
//  BLEditableLineItem.m
//  billy
//
//  Created by Ross Cooperman on 12/21/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define HEIGHT 45.0f
#define QUANTITY_WIDTH 40.0f
#define NAME_WIDTH 195.0f
#define PRICE_WIDTH 85.0f


#import "BLEditableLineItem.h"
#import "BLTextField.h"
#import "LineItem.h"
#import "Bill.h"


@interface BLEditableLineItem ()

@property (nonatomic, strong) LineItem *lineItem;
@property (nonatomic, strong) UIView *fieldWrapper;
@property (nonatomic, strong) UITextField *quantity;
@property (nonatomic, strong) UITextField *name;
@property (nonatomic, strong) UITextField *price;
@property (nonatomic, assign) CGFloat border;


- (void)createSubviews;
- (BLTextField *)textFieldWithFrame:(CGRect)frame;
- (void)panView:(UIPanGestureRecognizer *)recognizer;

@end


@implementation BLEditableLineItem

@synthesize lineItem = _lineItem;
@synthesize fieldWrapper;
@synthesize quantity;
@synthesize name;
@synthesize price;
@synthesize border;


#pragma mark - Object Lifecycle

- (id)initWithLineItem:(LineItem *)lineItem
{
  self.border = 1.0f / [UIScreen mainScreen].scale;
  
  self = [super initWithFrame:CGRectMake(0.0f, (lineItem.index * HEIGHT) - self.border, 320.0f, HEIGHT)];
  if (self) {
    self.lineItem = lineItem;
  }
  return self;
}


#pragma mark - Instance Methods

- (BOOL)resignFirstResponder
{
  [self.quantity resignFirstResponder];
  [self.name resignFirstResponder];
  [self.price resignFirstResponder];

  return [super resignFirstResponder];
}


- (void)createSubviews
{
  self.backgroundColor = [UIColor colorWithRed:0.54118f green:0.77255f blue:0.64706f alpha:1.0f];
  
  // generate the view that wraps the field
  self.fieldWrapper = [[UIView alloc] initWithFrame:self.bounds];
//  self.fieldWrapper.backgroundColor = ;
  [self addSubview:self.fieldWrapper];

  // create the quantity text box
  self.quantity = [self textFieldWithFrame:CGRectMake(self.border, self.border, QUANTITY_WIDTH - self.border, HEIGHT - self.border)];
  self.quantity.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];
  self.quantity.text = (self.lineItem.quantity > 0) ? [NSString stringWithFormat:@"%lld", self.lineItem.quantity] : @"";
  self.quantity.placeholder = @"#";
  [self.fieldWrapper addSubview:quantity];
  
  // create the name text box
  self.name = [self textFieldWithFrame:CGRectMake(self.border + QUANTITY_WIDTH, self.border, NAME_WIDTH - self.border, HEIGHT - self.border)];
  self.name.text = self.lineItem.desc;
  self.name.autocapitalizationType = UITextAutocapitalizationTypeWords;
  self.name.textAlignment = UITextAlignmentLeft;
  self.name.placeholder = @"Description";
  [self.fieldWrapper addSubview:name];
  
  // create the price text box
  CGRect priceFrame = CGRectMake(320.0f - PRICE_WIDTH + self.border, self.border, PRICE_WIDTH - (self.border * 2.0f), HEIGHT - self.border);
  self.price = [self textFieldWithFrame:priceFrame];
  self.price.text = (self.lineItem.price > 0.0) ? [NSString stringWithFormat:@"%.2f", self.lineItem.price] : @"";
  self.price.textAlignment = UITextAlignmentRight;
  self.price.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
  self.price.placeholder = @"0.00";
  self.price.returnKeyType = UIReturnKeyDone;
  [self.fieldWrapper addSubview:self.price];
  
  // if there's only one line item and all fields are empty, start editing immediately
  if (self.lineItem.bill.lineItems.count == 1 && self.lineItem.quantity == 0 && self.lineItem.desc.length == 0 && self.lineItem.price == 0.0) {
    [self.quantity becomeFirstResponder];
  }
  
  // create the pan gesture recognizer for deletion
  UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
  recognizer.maximumNumberOfTouches = 1;
  recognizer.minimumNumberOfTouches = 1;
  [self.fieldWrapper addGestureRecognizer:recognizer];
}


- (void)layoutSubviews
{
  if (!self.quantity) [self createSubviews];
  [super layoutSubviews];
}


- (BLTextField *)textFieldWithFrame:(CGRect)frame;
{
  BLTextField *textField = [[BLTextField alloc] initWithFrame:frame];

  textField.backgroundColor = [UIColor whiteColor];
  textField.textColor = [UIColor blackColor];
  textField.borderStyle = UITextBorderStyleNone;
  textField.font = [UIFont fontWithName:@"Avenir" size:18.0f];
  textField.autocorrectionType = UITextAutocorrectionTypeNo;
  textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
  textField.returnKeyType = UIReturnKeyNext;
  textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  textField.textAlignment = UITextAlignmentCenter;
  textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
  textField.delegate = self;

  return textField;
}


- (void)panView:(UIPanGestureRecognizer *)recognizer
{
  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan:
    case UIGestureRecognizerStateChanged: {
      self.fieldWrapper.transform = CGAffineTransformMakeTranslation([recognizer translationInView:self].x, 0.0f);
      break;
    }
      
    case UIGestureRecognizerStateEnded: {
      [UIView animateWithDuration:0.1 animations:^{
        self.fieldWrapper.transform = CGAffineTransformIdentity;
      }];
      break;
    }
      
    case UIGestureRecognizerStateCancelled:
    case UIGestureRecognizerStatePossible:
    case UIGestureRecognizerStateFailed:
      // don't do anything in this case
      break;
  }
}


#pragma mark - Property Implementations

- (BOOL)isActive
{
  return [self.quantity isFirstResponder] || [self.name isFirstResponder] || [self.price isFirstResponder];
}


#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField.returnKeyType == UIReturnKeyNext) {
    (textField == self.quantity) ? [self.name becomeFirstResponder] : [self.price becomeFirstResponder];
  }
  else {
    [textField resignFirstResponder];
  }
  return NO;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  BOOL returnValue = YES;
  
  if (textField == self.quantity) {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSCharacterSet *nonDigitsSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange nonDigitRange = [newString rangeOfCharacterFromSet:nonDigitsSet];
    returnValue = nonDigitRange.location == NSNotFound;    
  }
  else if (textField == self.price) {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSCharacterSet *nonDigitsSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSRange nonDigitRange = [newString rangeOfCharacterFromSet:nonDigitsSet];
    returnValue = nonDigitRange.location == NSNotFound;
  }
  
  if (returnValue) {
    self.lineItem.quantity = [self.quantity.text integerValue];
    self.lineItem.desc = self.name.text;
    self.lineItem.price = [self.price.text floatValue];
    
    [self.lineItem.managedObjectContext save:nil];
  }
  
  return returnValue;
}

@end
