//
//  BLFixItemsViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/1/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define TEXT_BOX_HEIGHT 45
#define QUANTITY_BOX_WIDTH 45
#define NAME_BOX_WIDTH 189
#define PRICE_BOX_WIDTH 72


#import <QuartzCore/QuartzCore.h>
#import "BLFixItemsViewController.h"
#import "BLSplitBillViewController.h"
#import "BLTextField.h"


@interface BLFixItemsViewController ()

@property (nonatomic, strong) NSMutableArray *lineItems;
@property (nonatomic, strong) NSMutableArray *dataFields;
@property (nonatomic, strong) UITextField *activeField;


- (void)findLineItems;
- (void)generateTextFields;
- (BLTextField *)generateTextField;
- (UIView *)generateViewForIndex:(NSInteger)index;
- (void)keyboardShown:(NSNotification *)notification;
- (void)keyboardHidden:(NSNotification *)notification;
- (void)swipeToDelete:(UISwipeGestureRecognizer *)recognizer;
- (void)deleteItemAtIndex:(NSInteger)index;
- (void)updateStoredItems;
- (BOOL)validateLineItems;

@end


@implementation BLFixItemsViewController

@synthesize contentArea;
@synthesize rawText;
@synthesize lineItems = _lineItems;
@synthesize dataFields;
@synthesize activeField;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  if (!self.rawText) self.rawText = [[BLAppDelegate appDelegate] rawText];
  
  [self findLineItems];
  
  BOOL selectFirstField = NO;
  if (self.lineItems.count <= 0) {
    [self.lineItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"quantity", @"", @"name", @"", @"price", nil]];
    selectFirstField = YES;
  }
  
  [self generateTextFields]; 
  [self updateStoredItems];
  
  if (selectFirstField) [[[self.dataFields objectAtIndex:0] objectForKey:@"quantity"] becomeFirstResponder];
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

- (void)findLineItems
{
  if (!self.lineItems) self.lineItems = [NSMutableArray array];
  if (!self.rawText || self.rawText.length <= 0) return;
  
  NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines;
  
  NSString *pattern = @"^\\s*([\\dIOS]+)\\s+(.*)?\\s+\\$?([\\dIOS]+\\.[\\dIOS]{2})\\s*$";
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:nil];
  NSRange range = [self.rawText rangeOfString:self.rawText];
  
  [regex enumerateMatchesInString:self.rawText options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
    NSString *quantity = [[self.rawText substringWithRange:[result rangeAtIndex:1]] uppercaseString];
    quantity = [quantity stringByReplacingOccurrencesOfString:@"I" withString:@"1"];
    quantity = [quantity stringByReplacingOccurrencesOfString:@"O" withString:@"0"];
    quantity = [quantity stringByReplacingOccurrencesOfString:@"S" withString:@"5"];
    
    NSString *text = [self.rawText substringWithRange:[result rangeAtIndex:2]];
    
    NSString *price = [[self.rawText substringWithRange:[result rangeAtIndex:3]] uppercaseString];
    price = [price stringByReplacingOccurrencesOfString:@"I" withString:@"1"];
    price = [price stringByReplacingOccurrencesOfString:@"O" withString:@"0"];
    price = [price stringByReplacingOccurrencesOfString:@"S" withString:@"5"];
    
    NSDictionary *line = [NSDictionary dictionaryWithObjectsAndKeys:quantity, @"quantity", text, @"name", price, @"price", nil];
    [self.lineItems addObject:line];
  }];
}


- (void)generateTextFields
{
  NSInteger count = self.lineItems.count;
  self.dataFields = [NSMutableArray arrayWithCapacity:count];
  
  for (NSInteger i = 0; i < count; i++) {
    [self.contentArea addSubview:[self generateViewForIndex:i]];
  }
  self.contentArea.contentSize = CGSizeMake(320, ((TEXT_BOX_HEIGHT + 2) * count) + 8);
  self.contentArea.contentInset = UIEdgeInsetsMake(0.0, 0.0, 75.0, 0.0);
}


- (UIView *)generateViewForIndex:(NSInteger)index
{
  NSDictionary *line = [self.lineItems objectAtIndex:index];
  
  // create the wrapper that will surround all of the text fields
  CGRect frame = CGRectMake(5, 25 + ((TEXT_BOX_HEIGHT + 2) * index), 310, TEXT_BOX_HEIGHT);
  UIView *wrapper = [[UIView alloc] initWithFrame:frame];
  
  // generate the quantity text field
  BLTextField *quantity = [self generateTextField];
  quantity.frame = CGRectMake(0, 0, QUANTITY_BOX_WIDTH, TEXT_BOX_HEIGHT);
  quantity.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
  quantity.text = [line objectForKey:@"quantity"];
  quantity.textAlignment = UITextAlignmentCenter;
  quantity.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
  quantity.tag = 0;
  quantity.placeholder = @"#";
  [wrapper addSubview:quantity];
  
  // generate the name text field
  BLTextField *name = [self generateTextField];
  name.frame = CGRectMake(2 + QUANTITY_BOX_WIDTH, 0, NAME_BOX_WIDTH, TEXT_BOX_HEIGHT);
  name.text = [[line objectForKey:@"name"] uppercaseString];
  name.tag = 1;
  name.placeholder = @"DESCRIPTION";
  [wrapper addSubview:name];
  
  // generate the price field
  BLTextField *price = [self generateTextField];
  price.frame = CGRectMake(4 + QUANTITY_BOX_WIDTH + NAME_BOX_WIDTH, 0, PRICE_BOX_WIDTH, TEXT_BOX_HEIGHT);
  price.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
  price.text = [line objectForKey:@"price"];
  price.textAlignment = UITextAlignmentCenter;
  price.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
  price.tag = 2;
  price.placeholder = @"0.00";
  [wrapper addSubview:price];
  
  // add this collection of fields to the dataFields array
  NSDictionary *fields = [NSDictionary dictionaryWithObjectsAndKeys:quantity, @"quantity", name, @"name", price, @"price", nil];
  [self.dataFields addObject:fields];
  
  // add a pan gesture recognizer to the wrapper
  UISwipeGestureRecognizer *swipeToDelete = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDelete:)];
  swipeToDelete.numberOfTouchesRequired = 1;
  [wrapper addGestureRecognizer:swipeToDelete];
  
  return wrapper;
}


- (BLTextField *)generateTextField
{
  BLTextField *textField = [[BLTextField alloc] init];
  textField.backgroundColor = [UIColor colorWithWhite:0.88627451 alpha:1.0];
  textField.textColor = [UIColor blackColor];
  textField.borderStyle = UITextBorderStyleNone;
  textField.font = [UIFont fontWithName:@"Futura-Medium" size:16];
  textField.autocorrectionType = UITextAutocorrectionTypeNo;
  textField.keyboardAppearance = UIKeyboardAppearanceAlert;
  textField.returnKeyType = UIReturnKeyDone;
  textField.delegate = self;
  textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  return textField;
}


- (void)keyboardShown:(NSNotification *)notification
{
  NSDictionary *info = [notification userInfo];
  CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  
  UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + 30, 0.0);
  self.contentArea.contentInset = contentInsets;
  self.contentArea.scrollIndicatorInsets = contentInsets;
  
  CGRect frame = self.contentArea.frame;
  frame.size.height -= keyboardSize.height;
  CGPoint translatedOrigin = [self.view convertPoint:activeField.superview.frame.origin fromView:self.contentArea];
  translatedOrigin.y += TEXT_BOX_HEIGHT + 10;
  if (!CGRectContainsPoint(frame, translatedOrigin) ) {
    CGPoint scrollPoint = CGPointMake(0.0, self.activeField.superview.frame.origin.y - keyboardSize.height);
    [self.contentArea setContentOffset:scrollPoint animated:YES];
  }
}


- (void)keyboardHidden:(NSNotification *)notification
{
  [UIView animateWithDuration:0.3 animations:^{
    self.contentArea.contentInset = UIEdgeInsetsMake(0.0, 0.0, 75.0, 0.0);
    self.contentArea.scrollIndicatorInsets = UIEdgeInsetsZero;
  }];
}


- (void)swipeToDelete:(UISwipeGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateRecognized) {
    BLTextField *quantity = [recognizer.view.subviews objectAtIndex:0];
    __block NSInteger index = -1;
    [self.dataFields enumerateObjectsUsingBlock:^(NSDictionary *fields, NSUInteger idx, BOOL *stop) {
      if ([fields objectForKey:@"quantity"] == quantity) {
        index = idx;
        *stop = YES;
      }
    }];
    
    if (index >= 0) [self deleteItemAtIndex:index];
  }
}


- (void)deleteItemAtIndex:(NSInteger)index
{
  NSDictionary *fields = [self.dataFields objectAtIndex:index];
  
  BLTextField *quantity = [fields objectForKey:@"quantity"];
  BLTextField *name = [fields objectForKey:@"name"];
  BLTextField *price = [fields objectForKey:@"price"];
  if (quantity.enabled) {
    if (quantity.text.length <= 0 && name.text.length <= 0 && price.text.length <= 0) {
      [self.dataFields removeObjectAtIndex:index];
      [self.lineItems removeObjectAtIndex:index];
      
      CGRect frame = quantity.superview.frame;
      frame.origin.y += frame.size.height;
      frame.size.height = 0.0;
      UIView *blindView = [[UIView alloc] initWithFrame:frame];
      blindView.backgroundColor = [UIColor blackColor];
      [quantity.superview.superview insertSubview:blindView aboveSubview:quantity.superview];
      
      [UIView animateWithDuration:0.3 animations:^{
        blindView.frame = quantity.superview.frame;
        [quantity.superview.superview.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
          if (idx > index + 1 && view != blindView) {
            view.frame = CGRectOffset(view.frame, 0, -(TEXT_BOX_HEIGHT + 2));
          }
        }];
      } completion:^(BOOL finished) {
        [quantity.superview removeFromSuperview];
        [blindView removeFromSuperview];
      }];
      self.contentArea.contentSize = CGSizeMake(320, ((TEXT_BOX_HEIGHT + 2) * self.dataFields.count) + 8);   
    }
    else {
      quantity.enabled = NO;
      name.enabled = NO;
      price.enabled = NO;

      UIColor *newBackground = [UIColor colorWithWhite:0.88627451 alpha:0.2];
      quantity.backgroundColor = newBackground;
      name.backgroundColor = newBackground;
      price.backgroundColor = newBackground;
    }
  }
  else {
    quantity.enabled = YES;
    name.enabled = YES;
    price.enabled = YES;

    UIColor *newBackground = [UIColor colorWithWhite:0.88627451 alpha:1.0];
    quantity.backgroundColor = newBackground;
    name.backgroundColor = newBackground;
    price.backgroundColor = newBackground;
  }
}


- (void)updateStoredItems
{
  NSMutableArray *lineItems = [[NSMutableArray alloc] initWithCapacity:self.dataFields.count];
  [self.dataFields enumerateObjectsUsingBlock:^(NSDictionary *fields, NSUInteger idx, BOOL *stop) {
    if ([[fields objectForKey:@"quantity"] isEnabled]) {
      NSNumber *quantity = [NSNumber numberWithInt:[[[fields objectForKey:@"quantity"] text] intValue]];
      NSString *name = [[fields objectForKey:@"name"] text];
      NSNumber *price = [NSNumber numberWithFloat:[[[fields objectForKey:@"price"] text] floatValue]];
      
      if ([quantity integerValue] > 0 && [price floatValue] > 0.0) {
        NSDictionary *lineItem = [NSDictionary dictionaryWithObjectsAndKeys:quantity, @"quantity", name, @"name", price, @"price", nil];
        [lineItems addObject:lineItem];
      }
    }
  }];
  [[BLAppDelegate appDelegate] setLineItems:lineItems];
}


#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  self.activeField = textField;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return NO;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  if (textField.tag == 0) {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSCharacterSet *nonDigitsSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    textField.text = [newString stringByTrimmingCharactersInSet:nonDigitsSet];
  }
  else if (textField.tag == 2) {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSCharacterSet *nonDigitsSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    textField.text = [newString stringByTrimmingCharactersInSet:nonDigitsSet];    
  }
  else {
    textField.text = [[textField.text stringByReplacingCharactersInRange:range withString:string] uppercaseString];
  }

  return NO;
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
        field.backgroundColor = [UIColor colorWithWhite:0.88627451 alpha:1.0];
      }
    }];    
  }];
  return valid;
}


#pragma mark - IBAction Methods

- (void)contentAreaTapped:(UITapGestureRecognizer *)recognizer
{
  [self.activeField resignFirstResponder];
}


- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)acceptChanges:(id)sender
{
  if ([self validateLineItems]) {
    [self updateStoredItems];
    BLSplitBillViewController *splitBillController = [[BLSplitBillViewController alloc] init];
    [self.navigationController pushViewController:splitBillController animated:YES];
  }
}


- (void)addRow:(id)sender
{
  NSDictionary *line = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"quantity", @"", @"name", @"", @"price", nil];
  [self.lineItems addObject:line];
  
  NSInteger index = self.lineItems.count - 1;
  UIView *newRow = [self generateViewForIndex:index];
  [self.contentArea addSubview:newRow];
  self.contentArea.contentSize = CGSizeMake(320, ((TEXT_BOX_HEIGHT + 2) * self.lineItems.count) + 8);

  NSDictionary *fields = [self.dataFields objectAtIndex:index];
  BLTextField *field = [fields objectForKey:@"quantity"];
  [field becomeFirstResponder];
}

@end
