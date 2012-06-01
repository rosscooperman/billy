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


#import "BLFixItemsViewController.h"
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

@end


@implementation BLFixItemsViewController

@synthesize contentArea;
@synthesize rawText;
@synthesize lineItems;
@synthesize dataFields;
@synthesize activeField;


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
  [self findLineItems];
  [self generateTextFields];
}


- (void)viewWillDisappear:(BOOL)animated
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Instance Methods

- (void)findLineItems
{
  if (!self.lineItems) self.lineItems = [NSMutableArray array];
  
  NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines;
  
  NSString *pattern = @"^\\s*([\\dI])\\s+(.*)?\\s+\\$?(\\d+\\.\\d{2})\\s*$";
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:nil];
  NSRange range = [self.rawText rangeOfString:self.rawText];
  
  [regex enumerateMatchesInString:self.rawText options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
    NSString *quantity = [self.rawText substringWithRange:[result rangeAtIndex:1]];
    NSString *text = [self.rawText substringWithRange:[result rangeAtIndex:2]];
    NSString *price = [self.rawText substringWithRange:[result rangeAtIndex:3]];
    
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
}


- (UIView *)generateViewForIndex:(NSInteger)index
{
  NSDictionary *line = [self.lineItems objectAtIndex:index];
  
  // create the wrapper that will surround all of the text fields
  CGRect frame = CGRectMake(5, 25 + ((TEXT_BOX_HEIGHT + 2) * index), 310, TEXT_BOX_HEIGHT);
  UIView *wrapper = [[UIView alloc] initWithFrame:frame];
  
  // generate the quantity text field
  BLTextField *quantity = [self generateTextField];
  quantity.frame = CGRectMake(5, 0, QUANTITY_BOX_WIDTH, TEXT_BOX_HEIGHT);
  quantity.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
  quantity.text = [line objectForKey:@"quantity"];
  quantity.textAlignment = UITextAlignmentCenter;
  quantity.keyboardType = UIKeyboardTypeNumberPad;
  quantity.tag = 0;
  [wrapper addSubview:quantity];
  
  // generate the name text field
  BLTextField *name = [self generateTextField];
  name.frame = CGRectMake(7 + QUANTITY_BOX_WIDTH, 0, NAME_BOX_WIDTH, TEXT_BOX_HEIGHT);
  name.text = [[line objectForKey:@"name"] uppercaseString];
  name.tag = 1;
  [wrapper addSubview:name];
  
  // generate the price field
  BLTextField *price = [self generateTextField];
  price.frame = CGRectMake(9 + QUANTITY_BOX_WIDTH + NAME_BOX_WIDTH, 0, PRICE_BOX_WIDTH, TEXT_BOX_HEIGHT);
  price.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
  price.text = [line objectForKey:@"price"];
  price.textAlignment = UITextAlignmentCenter;
  price.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
  price.tag = 2;
  [wrapper addSubview:price];
  
  // add this collection of fields to the dataFields array
  NSDictionary *fields = [NSDictionary dictionaryWithObjectsAndKeys:quantity, @"quantity", name, @"name", price, @"price", nil];
  [self.dataFields addObject:fields];
  
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
  textField.returnKeyType = UIReturnKeyNext;
  textField.delegate = self;
  textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  return textField;
}


- (void)keyboardShown:(NSNotification *)notification
{
  NSDictionary *info = [notification userInfo];
  CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  
  UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height - 65, 0.0);
  self.contentArea.contentInset = contentInsets;
  self.contentArea.scrollIndicatorInsets = contentInsets;
  
  CGRect frame = self.view.frame;
  frame.size.height -= keyboardSize.height;
  CGPoint translatedOrigin = [self.view convertPoint:activeField.superview.frame.origin fromView:self.contentArea];
  translatedOrigin.y += TEXT_BOX_HEIGHT + 10;
  if (!CGRectContainsPoint(frame, translatedOrigin) ) {
    CGPoint scrollPoint = CGPointMake(0.0, self.activeField.frame.origin.y + keyboardSize.height - 75);
    [self.contentArea setContentOffset:scrollPoint animated:YES];
  }
}


- (void)keyboardHidden:(NSNotification *)notification
{
  [UIView animateWithDuration:0.3 animations:^{
    self.contentArea.contentInset = UIEdgeInsetsZero;
    self.contentArea.scrollIndicatorInsets = UIEdgeInsetsZero;
  }];
}


#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  self.activeField = textField;
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


#pragma mark - IBAction Methods

- (void)contentAreaTapped:(UITapGestureRecognizer *)recognizer
{
  [self.activeField resignFirstResponder];
}

@end
