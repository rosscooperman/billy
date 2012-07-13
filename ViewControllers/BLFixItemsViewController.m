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
#import "Bill.h"
#import "LineItem.h"


@interface BLFixItemsViewController ()

@property (nonatomic, strong) NSMutableArray *lineItems;
@property (nonatomic, strong) NSMutableArray *dataFields;
@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic, strong) Bill *bill;


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
@synthesize lineItems = _lineItems;
@synthesize dataFields;
@synthesize activeField;
@synthesize bill;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  self.lineItems = [NSMutableArray array];
  
  // fetch the current bill and clear out any existing line items
  self.bill = [BLAppDelegate appDelegate].currentBill;
  [self.bill.lineItems enumerateObjectsUsingBlock:^(LineItem *lineItem, BOOL *stop) {
    [[BLAppDelegate appDelegate].managedObjectContext deleteObject:lineItem];
  }];
  [[BLAppDelegate appDelegate].managedObjectContext save:nil];
  
  // find/detect any line items in raw text (and create a new one if none are found)
  [self findLineItems];
  BOOL selectFirstField = NO;
  if (self.lineItems.count <= 0) {
    NSManagedObjectContext *context = [BLAppDelegate appDelegate].managedObjectContext;
    LineItem *lineItem = [NSEntityDescription insertNewObjectForEntityForName:@"LineItem" inManagedObjectContext:context];
    
    [self.bill addLineItemsObject:lineItem];
    [self.lineItems addObject:lineItem];
    
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
  if (!self.bill.rawText || self.bill.rawText.length <= 0) return;
  NSManagedObjectContext *context = [BLAppDelegate appDelegate].managedObjectContext;
  
  NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines;
  NSString *pattern = @"^\\s*([\\dIOS]+)\\s+(.*)?\\s+\\$?([\\dIOS]+\\.[\\dIOS]{2})\\s*$";
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:nil];
  NSRange range = [self.bill.rawText rangeOfString:self.bill.rawText];

  [regex enumerateMatchesInString:self.bill.rawText options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags f, BOOL *s) {
    // create a new line item with a description
    LineItem *lineItem = [NSEntityDescription insertNewObjectForEntityForName:@"LineItem" inManagedObjectContext:context];
    lineItem.desc = [self.bill.rawText substringWithRange:[result rangeAtIndex:2]];

    // tweak and set the new line item's quantity
    NSString *quantity = [[self.bill.rawText substringWithRange:[result rangeAtIndex:1]] uppercaseString];
    quantity = [quantity stringByReplacingOccurrencesOfString:@"I" withString:@"1"];
    quantity = [quantity stringByReplacingOccurrencesOfString:@"O" withString:@"0"];
    quantity = [quantity stringByReplacingOccurrencesOfString:@"S" withString:@"5"];
    lineItem.quantity = quantity.longLongValue;
    
    // tweak and set the line item's price
    NSString *price = [[self.bill.rawText substringWithRange:[result rangeAtIndex:3]] uppercaseString];
    price = [price stringByReplacingOccurrencesOfString:@"I" withString:@"1"];
    price = [price stringByReplacingOccurrencesOfString:@"O" withString:@"0"];
    price = [price stringByReplacingOccurrencesOfString:@"S" withString:@"5"];
    lineItem.price = price.doubleValue;
    
    [self.bill addLineItemsObject:lineItem];
    [self.lineItems addObject:lineItem];
  }];
  [[BLAppDelegate appDelegate].managedObjectContext save:nil];
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
  LineItem *lineItem = [self.lineItems objectAtIndex:index];
  
  // create the wrapper that will surround all of the text fields
  CGRect frame = CGRectMake(5, 25 + ((TEXT_BOX_HEIGHT + 2) * index), 310, TEXT_BOX_HEIGHT);
  UIView *wrapper = [[UIView alloc] initWithFrame:frame];
  
  // generate the quantity text field
  BLTextField *quantity = [self generateTextField];
  quantity.frame = CGRectMake(0, 0, QUANTITY_BOX_WIDTH, TEXT_BOX_HEIGHT);
  quantity.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
  quantity.text = (lineItem.quantity > 0) ? [NSString stringWithFormat:@"%lld", lineItem.quantity] : @"";
  quantity.textAlignment = UITextAlignmentCenter;
  quantity.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
  quantity.tag = 0;
  quantity.placeholder = @"#";
  [wrapper addSubview:quantity];
  
  // generate the name text field
  BLTextField *name = [self generateTextField];
  name.frame = CGRectMake(2 + QUANTITY_BOX_WIDTH, 0, NAME_BOX_WIDTH, TEXT_BOX_HEIGHT);
  name.text = [lineItem.desc uppercaseString];
  name.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
  name.tag = 1;
  name.placeholder = @"DESCRIPTION";
  [wrapper addSubview:name];
  
  // generate the price field
  BLTextField *price = [self generateTextField];
  price.frame = CGRectMake(4 + QUANTITY_BOX_WIDTH + NAME_BOX_WIDTH, 0, PRICE_BOX_WIDTH, TEXT_BOX_HEIGHT);
  price.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
  price.text = (lineItem.price > 0.0) ? [NSString stringWithFormat:@"%.2f", lineItem.price] : @"";
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
  textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
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
  LineItem *lineItem = [self.lineItems objectAtIndex:index];
  
  BLTextField *quantity = [fields objectForKey:@"quantity"];
  BLTextField *name = [fields objectForKey:@"name"];
  BLTextField *price = [fields objectForKey:@"price"];
  if (quantity.enabled) {
    lineItem.deleted = YES;
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
    lineItem.deleted = NO;
    quantity.enabled = YES;
    name.enabled = YES;
    price.enabled = YES;

    UIColor *newBackground = [UIColor colorWithWhite:0.88627451 alpha:1.0];
    quantity.backgroundColor = newBackground;
    name.backgroundColor = newBackground;
    price.backgroundColor = newBackground;
  }
  [[BLAppDelegate appDelegate].managedObjectContext save:nil];
}


- (void)updateStoredItems
{
  [self.dataFields enumerateObjectsUsingBlock:^(NSDictionary *fields, NSUInteger idx, BOOL *stop) {
    LineItem *lineItem = [self.lineItems objectAtIndex:idx];
    
    lineItem.quantity = [[[fields objectForKey:@"quantity"] text] intValue];
    lineItem.desc = [[fields objectForKey:@"name"] text];
    lineItem.price = [[[fields objectForKey:@"price"] text] doubleValue];
  }];
  [[BLAppDelegate appDelegate].managedObjectContext save:nil];
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
    NSRange nonDigitRange = [newString rangeOfCharacterFromSet:nonDigitsSet];
    return nonDigitRange.location == NSNotFound;
  }
  else if (textField.tag == 2) {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSCharacterSet *nonDigitsSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSRange nonDigitRange = [newString rangeOfCharacterFromSet:nonDigitsSet];
    return nonDigitRange.location == NSNotFound;
  }

  return YES;
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
  NSManagedObjectContext *context = [BLAppDelegate appDelegate].managedObjectContext;
  LineItem *lineItem = [NSEntityDescription insertNewObjectForEntityForName:@"LineItem" inManagedObjectContext:context];
  lineItem.index = self.lineItems.count;
  
  [self.bill addLineItemsObject:lineItem];
  [self.lineItems addObject:lineItem];

  UIView *newRow = [self generateViewForIndex:lineItem.index];
  [self.contentArea addSubview:newRow];
  self.contentArea.contentSize = CGSizeMake(320, ((TEXT_BOX_HEIGHT + 2) * self.lineItems.count) + 8);

  NSDictionary *fields = [self.dataFields objectAtIndex:lineItem.index];
  BLTextField *field = [fields objectForKey:@"quantity"];
  [field becomeFirstResponder];
}

@end
