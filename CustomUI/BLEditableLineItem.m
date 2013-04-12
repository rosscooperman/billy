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

@property (nonatomic, strong) UIView *fieldWrapper;
@property (nonatomic, strong) UITextField *quantity;
@property (nonatomic, strong) UITextField *name;
@property (nonatomic, strong) UITextField *price;
@property (nonatomic, assign) CGFloat border;
@property (nonatomic, assign) BOOL isPanning;
@property (nonatomic, strong) UIImageView *redDelete;
@property (nonatomic, strong) UIImageView *greyDelete;


- (void)createSubviews;
- (void)setReturnTypes;
- (BLTextField *)textFieldWithFrame:(CGRect)frame;
- (void)panView:(UIPanGestureRecognizer *)recognizer;
- (void)keyboardShown:(NSNotification *)notification;
- (void)keyboardHidden:(NSNotification *)notification;

@end


@implementation BLEditableLineItem

@synthesize lineItem = _lineItem;
@synthesize fieldWrapper;
@synthesize quantity;
@synthesize name;
@synthesize price;
@synthesize border;
@synthesize redDelete;
@synthesize greyDelete;


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


- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Instance Methods

- (BOOL)resignFirstResponder
{
  [self.quantity resignFirstResponder];
  [self.name resignFirstResponder];
  [self.price resignFirstResponder];
  
  return [super resignFirstResponder];
}


- (BOOL)becomeFirstResponder
{
  return [self.quantity becomeFirstResponder];
}


- (void)createSubviews
{
  self.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
  
  // add the grey delete indicator
  self.greyDelete = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, HEIGHT, HEIGHT)];
  self.greyDelete.image = [UIImage imageNamed:@"deleteXGrey"];
  self.greyDelete.contentMode = UIViewContentModeCenter;
  [self addSubview:self.greyDelete];
  
  // add the (RED) delete indicator
  self.redDelete = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, HEIGHT, HEIGHT)];
  self.redDelete.image = [UIImage imageNamed:@"deleteXRed"];
  self.redDelete.contentMode = UIViewContentModeCenter;
  self.redDelete.alpha = 0.0;
  [self addSubview:self.redDelete];
  
  // add a couple of border views to avoid weird transition regions when line items slide
  UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, self.border)];
  topBorder.backgroundColor = [UIColor colorWithRed:0.54118f green:0.77255f blue:0.64706f alpha:1.0f];
  [self addSubview:topBorder];
  UIView *leftBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.border, self.border, HEIGHT)];
  leftBorder.backgroundColor = [UIColor colorWithRed:0.54118f green:0.77255f blue:0.64706f alpha:1.0f];
  [self addSubview:leftBorder];

  // generate the view that wraps all of the content fields
  self.fieldWrapper = [[UIView alloc] initWithFrame:self.bounds];
  self.fieldWrapper.backgroundColor = [UIColor colorWithRed:0.54118f green:0.77255f blue:0.64706f alpha:1.0f];
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
  self.name.keyboardType = UIKeyboardTypeDefault;
  self.name.autocapitalizationType = UITextAutocapitalizationTypeWords;
  self.name.textAlignment = UITextAlignmentLeft;
  self.name.placeholder = @"Description";
  [self.fieldWrapper addSubview:name];
  
  // create the price text box
  CGRect priceFrame = CGRectMake(320.0f - PRICE_WIDTH + self.border, self.border, PRICE_WIDTH - (self.border * 2.0f), HEIGHT - self.border);
  self.price = [self textFieldWithFrame:priceFrame];
  self.price.text = (self.lineItem.price > 0.0) ? [NSString stringWithFormat:@"%.2f", self.lineItem.price] : @"";
  self.price.textAlignment = UITextAlignmentRight;
  self.price.placeholder = @"0.00";
  self.price.returnKeyType = UIReturnKeyDone;
  [self.fieldWrapper addSubview:self.price];
  
  // make sure the return types (done or next) are properly set for price and name
  [self setReturnTypes];
  
  // if there's only one line item and all fields are empty, start editing immediately
  if (self.lineItem.bill.lineItems.count == 1 && self.lineItem.quantity == 0 && self.lineItem.desc.length == 0 && self.lineItem.price == 0.0) {
    [self.quantity becomeFirstResponder];
  }
  
  // create the pan gesture recognizer for deletion
  UIPanGestureRecognizer *panny = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
  panny.maximumNumberOfTouches = 1;
  panny.minimumNumberOfTouches = 1;
  panny.cancelsTouchesInView = NO;
  panny.delegate = self;
  [self.fieldWrapper addGestureRecognizer:panny];
  
  // register for keyboardShow and keyboardHidden notifications to disable interaction with the wrapper
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardDidHideNotification object:nil];
}


- (void)setReturnTypes
{
  self.name.returnKeyType = (self.price.text.length > 0) ? UIReturnKeyDone : UIReturnKeyNext;
  self.quantity.returnKeyType = (self.price.text.length > 0 && self.name.text.length > 0) ? UIReturnKeyDone : UIReturnKeyNext;
}


- (void)layoutSubviews
{
  if (!self.quantity) [self createSubviews];
  [super layoutSubviews];
}


- (BLTextField *)textFieldWithFrame:(CGRect)frame
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
  CGPoint translation = [recognizer translationInView:self];

  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan: {
      if (fabs(translation.x) > fabs(translation.y)) {
        self.isPanning = YES;
      }
      else {
        recognizer.enabled = NO;
      }
    }
      
    case UIGestureRecognizerStateChanged: {
      if (self.isPanning) {
        self.fieldWrapper.transform = CGAffineTransformMakeTranslation(translation.x, 0.0f);
        self.redDelete.transform = CGAffineTransformMakeTranslation(MAX(0.0f, translation.x - HEIGHT), 0.0f);
        self.redDelete.alpha = MIN(1.0f, translation.x / HEIGHT);
        self.greyDelete.alpha = 1.0f - self.redDelete.alpha;
      }
      break;
    }
      
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateFailed:
    case UIGestureRecognizerStateCancelled: {
      CGFloat animationDuration = translation.x / HEIGHT / 10.0f;
      CGAffineTransform newTransform = CGAffineTransformIdentity;
      BOOL willDelete = translation.x > HEIGHT;
      
      if (willDelete) {
        newTransform = CGAffineTransformMakeTranslation(320.0f, 0.0f);
        animationDuration = (320.0f - translation.x) / HEIGHT / 10.0f;
      }

      [UIView animateWithDuration:animationDuration animations:^{
        self.fieldWrapper.transform = self.redDelete.transform = newTransform;
        self.redDelete.alpha = 0.0f;
      } completion:^(BOOL finished) {
        if (willDelete) {
          [self.lineItem.bill.lineItems enumerateObjectsUsingBlock:^(LineItem *item, BOOL *stop) {
            if (item.index > self.lineItem.index) item.index--;
          }];
          [self.lineItem.managedObjectContext deleteObject:self.lineItem];
          [self.lineItem.managedObjectContext save:nil];
        }
      }];
      
      recognizer.enabled = YES;
      self.isPanning = NO;
      break;
    }
      
    case UIGestureRecognizerStatePossible:
      // don't do anything in this case
      break;
  }
}


- (void)keyboardShown:(NSNotification *)notification
{
  [self.fieldWrapper.gestureRecognizers enumerateObjectsUsingBlock:^(UIGestureRecognizer *recognizer, NSUInteger idx, BOOL *stop) {
    recognizer.enabled = NO;
  }];
}


- (void)keyboardHidden:(NSNotification *)notification
{
  [self.fieldWrapper.gestureRecognizers enumerateObjectsUsingBlock:^(UIGestureRecognizer *recognizer, NSUInteger idx, BOOL *stop) {
    recognizer.enabled = YES;
  }];
}


#pragma mark - Property Implementations

- (BOOL)isActive
{
  return [self.quantity isFirstResponder] || [self.name isFirstResponder] || [self.price isFirstResponder];
}


#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  if (textField.returnKeyType == UIReturnKeyNext) {
    if (textField == self.quantity) {
      (self.name.text.length > 0) ? [self.price becomeFirstResponder] : [self.name becomeFirstResponder];
    }
    else if (textField == self.name) {
      [self.price becomeFirstResponder];
    }
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


#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)a shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)b
{
  return YES;
}

@end
