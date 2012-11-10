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

@property (nonatomic, strong) NSMutableArray *lineItems;
@property (nonatomic, strong) NSMutableArray *dataFields;
@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic, strong) Bill *bill;
@property (nonatomic, assign) BLTourStep tourStep;
@property (readonly) CGPoint tourInsertionPoint;
@property (nonatomic, assign) BOOL shouldMarkTourShown;
@property (nonatomic, strong) UIView *contentBackground;
@property (nonatomic, assign) CGFloat borderWidth;


- (void)findLineItems;
- (void)generateTextFields;
- (BLTextField *)generateTextFieldForIndex:(NSInteger)index;
- (UIView *)generateViewForIndex:(NSInteger)index;
- (void)keyboardShown:(NSNotification *)notification;
- (void)keyboardHidden:(NSNotification *)notification;
- (void)swipeToDelete:(UISwipeGestureRecognizer *)recognizer;
- (void)deleteItemAtIndex:(NSInteger)index;
- (void)updateStoredItems;
- (BOOL)validateLineItems;
- (void)nextTourStep;

@end


@implementation BLFixItemsViewController

@synthesize contentArea;
@synthesize nextScreenButton;
@synthesize previousScreenButton;
@synthesize addLineItemButton;
@synthesize tapRecognizer;
@synthesize lineItems = _lineItems;
@synthesize dataFields;
@synthesize activeField;
@synthesize bill;
@synthesize tourStep;
@synthesize contentBackground;
@synthesize borderWidth;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  self.borderWidth = 1.0f / [UIScreen mainScreen].scale;
  self.bill = [BLAppDelegate appDelegate].currentBill;
  self.lineItems = [NSMutableArray array];
    
  // find/detect any line items in raw text (and create a new one if none are found)
  [self findLineItems];
  BOOL selectFirstField = NO;
  if (self.lineItems.count <= 0) {
    if (self.bill.lineItems.count > 0) {
      NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
      self.lineItems = [[self.bill.lineItems sortedArrayUsingDescriptors:descriptors] mutableCopy];
    }
    else {
      NSManagedObjectContext *context = [BLAppDelegate appDelegate].managedObjectContext;
      LineItem *lineItem = [NSEntityDescription insertNewObjectForEntityForName:@"LineItem" inManagedObjectContext:context];
      lineItem.index = 0;
      
      [self.bill addLineItemsObject:lineItem];
      [self.lineItems addObject:lineItem];
      
      selectFirstField = YES;
    }
  }
  
  [self generateTextFields]; 
  [self updateStoredItems];
  
  if (selectFirstField) [[[self.dataFields objectAtIndex:0] objectForKey:@"quantity"] becomeFirstResponder];
  
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

- (void)findLineItems
{
  if (!self.bill.rawText || self.bill.rawText.length <= 0) return;
  NSManagedObjectContext *context = [BLAppDelegate appDelegate].managedObjectContext;
  
  NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines;
  NSString *pattern = @"^\\s*([\\dIOS]+)\\s+(.*)?\\s+\\$?([\\dIOS]+\\.[\\dIOS]{2})\\s*$";
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:nil];
  NSRange range = [self.bill.rawText rangeOfString:self.bill.rawText];
  
  // clear out any existing line items if we've found any line items in the raw text
  if ([regex numberOfMatchesInString:self.bill.rawText options:0 range:range] > 0) {
    [self.bill.lineItems enumerateObjectsUsingBlock:^(LineItem *lineItem, BOOL *stop) {
      [self.bill.managedObjectContext deleteObject:lineItem];
    }];
  }

  [regex enumerateMatchesInString:self.bill.rawText options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags f, BOOL *s) {
    // create a new line item with a description
    LineItem *lineItem = [NSEntityDescription insertNewObjectForEntityForName:@"LineItem" inManagedObjectContext:context];
    lineItem.index = self.lineItems.count;
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
  [self.bill.managedObjectContext save:nil];
}


- (void)generateTextFields
{
  NSInteger count = self.lineItems.count;
  self.dataFields = [NSMutableArray arrayWithCapacity:count];
  
  // add the individual line item views
  for (NSInteger i = 0; i < count; i++) {
    [self.contentArea addSubview:[self generateViewForIndex:i]];
  }
  
  // set up the content area so it will scroll correctly
  self.contentArea.contentSize = CGSizeMake(320.0f, (TEXT_BOX_HEIGHT + self.borderWidth) * count);
  
  // add a background view to provide the lines between items
  CGRect bgFrame = (CGRect){ CGPointMake(0.0f, -self.borderWidth), self.contentArea.contentSize };
  self.contentBackground = [[UIView alloc] initWithFrame:bgFrame];
  self.contentBackground.autoresizesSubviews = YES;
  self.contentBackground.backgroundColor = [UIColor colorWithRed:0.54118f green:0.77255f blue:0.64706f alpha:1.0f];
  [self.contentArea insertSubview:self.contentBackground atIndex:0];
  
  // add a bottom border to the background view
  UIImageView *bottomBorder = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(bgFrame) + self.borderWidth, 320.0f, 2.0f)];
  bottomBorder.image = [UIImage imageNamed:@"bottomBorder"];
  bottomBorder.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
  [self.contentBackground addSubview:bottomBorder];
}


- (UIView *)generateViewForIndex:(NSInteger)index
{
  LineItem *lineItem = [self.lineItems objectAtIndex:index];
  
  // create the wrapper that will surround all of the text fields
  CGRect frame = CGRectMake(0.0f, (TEXT_BOX_HEIGHT + self.borderWidth) * index, 320.0f, TEXT_BOX_HEIGHT);
  UIView *wrapper = [[UIView alloc] initWithFrame:frame];
    
  // generate the quantity text field
  BLTextField *quantity = [self generateTextFieldForIndex:index];
  quantity.frame = CGRectMake(0.0f, 0.0f, QUANTITY_BOX_WIDTH, TEXT_BOX_HEIGHT);
  quantity.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];
  quantity.text = (lineItem.quantity > 0) ? [NSString stringWithFormat:@"%lld", lineItem.quantity] : @"";
  quantity.textAlignment = UITextAlignmentCenter;
  quantity.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
  quantity.tag = 0;
  quantity.placeholder = @"#";
  [wrapper addSubview:quantity];
  
  // generate the name text field
  BLTextField *name = [self generateTextFieldForIndex:index];
  CGFloat width = 320.0f - ((2.0f * self.borderWidth) + QUANTITY_BOX_WIDTH + PRICE_BOX_WIDTH);
  name.frame = CGRectMake(CGRectGetMaxX(quantity.frame) + self.borderWidth, 0.0f, width, TEXT_BOX_HEIGHT);
  name.text = [lineItem.desc uppercaseString];
  name.autocapitalizationType = UITextAutocapitalizationTypeWords;
  name.tag = 1;
  name.placeholder = @"Description";
  [wrapper addSubview:name];
  
  // generate the price field
  BLTextField *price = [self generateTextFieldForIndex:index];
  price.frame = CGRectMake(CGRectGetMaxX(name.frame) + self.borderWidth, 0.0f, PRICE_BOX_WIDTH, TEXT_BOX_HEIGHT);
  price.text = (lineItem.price > 0.0f) ? [NSString stringWithFormat:@"%.2f", lineItem.price] : @"";
  price.textAlignment = UITextAlignmentRight;
  price.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
  price.tag = 2;
  price.placeholder = @"0.00";
  [wrapper addSubview:price];
  
  // add this collection of fields to the dataFields array
  NSDictionary *fields = [NSDictionary dictionaryWithObjectsAndKeys:quantity, @"quantity", name, @"name", price, @"price", nil];
  [self.dataFields addObject:fields];
  
  // add a pan gesture recognizer to the wrapper
//  UISwipeGestureRecognizer *swipeToDelete = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDelete:)];
//  swipeToDelete.numberOfTouchesRequired = 1;
//  [wrapper addGestureRecognizer:swipeToDelete];
  
  return wrapper;
}


- (BLTextField *)generateTextFieldForIndex:(NSInteger)index
{
  BLTextField *textField = [[BLTextField alloc] init];
  textField.backgroundColor = (index % 2 == 0) ? [UIColor whiteColor] : [UIColor colorWithRed:0.97255f green:0.99608f blue:0.98824f alpha:1.0f];
  textField.textColor = [UIColor blackColor];
  textField.borderStyle = UITextBorderStyleNone;
  textField.font = [UIFont fontWithName:@"Avenir" size:18.0f];
  textField.autocorrectionType = UITextAutocorrectionTypeNo;
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
  
  UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 0.0f, keyboardSize.height + 30.0f, 0.0f);
  self.contentArea.contentInset = contentInsets;
  self.contentArea.scrollIndicatorInsets = contentInsets;
  
  CGRect frame = self.contentArea.frame;
  frame.size.height -= keyboardSize.height;
  CGPoint translatedOrigin = [self.view convertPoint:activeField.superview.frame.origin fromView:self.contentArea];
  translatedOrigin.y += TEXT_BOX_HEIGHT + 10.0f;
  if (!CGRectContainsPoint(frame, translatedOrigin) ) {
    CGPoint scrollPoint = CGPointMake(0.0f, self.activeField.superview.frame.origin.y - keyboardSize.height);
    [self.contentArea setContentOffset:scrollPoint animated:YES];
  }
}


- (void)keyboardHidden:(NSNotification *)notification
{
  [UIView animateWithDuration:0.3f animations:^{
    self.contentArea.contentInset = self.contentArea.scrollIndicatorInsets = UIEdgeInsetsZero;
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
    
    if (index >= 0 && self.tourStep >= BLTourStepDeleteItem) {
      [self deleteItemAtIndex:index];
      if (self.tourStep == BLTourStepDeleteItem || self.tourStep == BLTourStepDeletedItem) [self nextTourStep];
    }
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
      self.contentArea.contentSize = CGSizeMake(320.0f, (TEXT_BOX_HEIGHT + self.borderWidth) * self.dataFields.count);
      self.contentBackground.frame = (CGRect){ CGPointMake(0.0f, -self.borderWidth), self.contentArea.contentSize };
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
  [self.bill.managedObjectContext save:nil];
}


- (void)updateStoredItems
{
  [self.dataFields enumerateObjectsUsingBlock:^(NSDictionary *fields, NSUInteger idx, BOOL *stop) {
    LineItem *lineItem = [self.lineItems objectAtIndex:idx];
    
    lineItem.price = [[[fields objectForKey:@"price"] text] doubleValue];
    lineItem.desc = [[fields objectForKey:@"name"] text];
    
    double newQuantity = [[[fields objectForKey:@"quantity"] text] intValue];
    if (newQuantity != lineItem.quantity) {
      lineItem.quantity = newQuantity;
      [lineItem.assignments enumerateObjectsUsingBlock:^(Assignment *assignment, BOOL *stop) {
        [self.bill.managedObjectContext deleteObject:assignment];
      }];
    }
  }];
  [self.bill.managedObjectContext save:nil];
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


#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  self.activeField = textField;
  if (self.tourStep == BLTourStepDeletedItem) [self nextTourStep];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField.returnKeyType == UIReturnKeyNext) {
    [[textField.superview.subviews objectAtIndex:textField.tag + 1] becomeFirstResponder];
  }
  else {
    [textField resignFirstResponder];
    if (self.tourStep == BLTourStepFinishFirstItem || self.tourStep == BLTourStepFinishSecondItem || self.tourStep == BLTourStepFinishThirdItem) {
      [self nextTourStep];
    }
  }
  return NO;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  BOOL returnValue = YES;
  
  if (textField.tag == 0) {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSCharacterSet *nonDigitsSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange nonDigitRange = [newString rangeOfCharacterFromSet:nonDigitsSet];
    returnValue = nonDigitRange.location == NSNotFound;
    
    if (returnValue && newString.length > 0 && self.tourStep == BLTourStepQuantity) [self nextTourStep];
  }
  else if (textField.tag == 1) {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length > 0 && self.tourStep == BLTourStepDescription) [self nextTourStep];
  }
  else if (textField.tag == 2) {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSCharacterSet *nonDigitsSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSRange nonDigitRange = [newString rangeOfCharacterFromSet:nonDigitsSet];
    returnValue = nonDigitRange.location == NSNotFound;
    
    if (returnValue && newString.length > 0 && self.tourStep == BLTourStepPrice) [self nextTourStep];
  }

  return returnValue;
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
  [self textFieldShouldReturn:self.activeField];
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
  if (self.tourStep == BLTourStepSecondItem || self.tourStep == BLTourStepThirdItem || self.tourStep == BLTourStepDeletedItem) {
    if (self.tourStep == BLTourStepDeletedItem) self.tourStep = BLTourStepAddAfterDelete;
    [self nextTourStep];
    return;
  }
  
  NSManagedObjectContext *context = [BLAppDelegate appDelegate].managedObjectContext;
  LineItem *lineItem = [NSEntityDescription insertNewObjectForEntityForName:@"LineItem" inManagedObjectContext:context];
  lineItem.index = self.lineItems.count;
  
  [self.bill addLineItemsObject:lineItem];
  [self.lineItems addObject:lineItem];
  
  UIView *newRow = [self generateViewForIndex:lineItem.index];
  [self.contentArea addSubview:newRow];
  self.contentArea.contentSize = CGSizeMake(320.0f, (TEXT_BOX_HEIGHT + self.borderWidth) * self.lineItems.count);
  self.contentBackground.frame = (CGRect){ CGPointMake(0.0f, -self.borderWidth), self.contentArea.contentSize };
  
  NSDictionary *fields = [self.dataFields objectAtIndex:lineItem.index];
  BLTextField *field = [fields objectForKey:@"quantity"];
  [field becomeFirstResponder];
}

@end
