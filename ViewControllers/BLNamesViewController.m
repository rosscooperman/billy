//
//  BLNamesViewController.m
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define TEXT_BOX_HEIGHT 50
#define TEXT_BOX_WIDTH 206


#import "BLNamesViewController.h"
#import "BLCameraViewController.h"
#import "BLFixItemsViewController.h"


@interface BLNamesViewController ()

@property (nonatomic, strong) NSMutableArray *textFields;
@property (nonatomic, unsafe_unretained) UITextField *activeField;
@property (nonatomic, strong) UIView *innerContainer;


- (UIView *)generateTextFieldForIndex:(NSInteger)index;
- (void)keyboardShown:(NSNotification *)notification;
- (void)keyboardHidden:(NSNotification *)notification;
- (void)setFinalTextFieldReturnButton;

@end


@implementation BLNamesViewController

@synthesize contentArea;
@synthesize textFields;
@synthesize activeField;
@synthesize innerContainer;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  NSInteger count = [BLAppDelegate appDelegate].splitCount;
  self.textFields = [NSMutableArray arrayWithCapacity:count];
  
  CGFloat innerHeight = ((TEXT_BOX_HEIGHT + 2) * count) + 2;
  CGFloat innerTop = ((self.contentArea.frame.size.height - innerHeight) / 2) + 15;
  CGRect frame = CGRectMake(0, innerTop, TEXT_BOX_WIDTH, innerHeight);
  
  self.innerContainer = [[UIView alloc] initWithFrame:frame];
  self.contentArea.contentSize = CGSizeMake(320, frame.size.height);
  
  for (NSInteger i = 0; i < count; i++) {
    [self.innerContainer addSubview:[self generateTextFieldForIndex:i]];
  }
  
  [self.contentArea addSubview:self.innerContainer];
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

- (UIView *)generateTextFieldForIndex:(NSInteger)index
{
  // set up the wrapper view
  CGRect frame = CGRectMake((320 - TEXT_BOX_WIDTH) / 2, (TEXT_BOX_HEIGHT + 2) * index, TEXT_BOX_WIDTH, TEXT_BOX_HEIGHT);
  UIView *wrapper = [[UIView alloc] initWithFrame:frame];
  wrapper.backgroundColor = [[BLAppDelegate appDelegate] colorAtIndex:index + 1];
  
  // set up the text field
  UITextField *textField = [[UITextField alloc] initWithFrame:CGRectInset(wrapper.bounds, 10, 0)];
  textField.borderStyle = UITextBorderStyleNone;
  textField.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:26];
  textField.backgroundColor = [UIColor clearColor];
  textField.textColor = [UIColor blackColor];
  textField.autocorrectionType = UITextAutocorrectionTypeNo;
  textField.keyboardAppearance = UIKeyboardAppearanceAlert;
  textField.returnKeyType = UIReturnKeyNext;
  textField.delegate = self;
  textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  textField.text = [[[BLAppDelegate appDelegate] nameAtIndex:index] uppercaseString];
  [self.textFields insertObject:textField atIndex:index];
  [wrapper addSubview:textField];
  
  return wrapper;
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
  CGPoint translatedOrigin = [self.view convertPoint:activeField.superview.frame.origin fromView:self.innerContainer];
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


- (void)setFinalTextFieldReturnButton
{
  __block BOOL isBlank = NO;
  [self.textFields enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
    if (textField.text.length <= 0) {
      isBlank = YES;
      *stop = YES;
    }
  }];
  
  UITextField *lastField = self.textFields.lastObject;
  lastField.returnKeyType = (isBlank) ? UIReturnKeyNext : UIReturnKeyDone;
}


#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  self.activeField = textField;
  [self setFinalTextFieldReturnButton];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  UITextField *nextField;
  NSInteger currentIndex = [self.textFields indexOfObject:textField];
  if (currentIndex == [BLAppDelegate appDelegate].splitCount - 1) {
    if (textField.returnKeyType == UIReturnKeyDone) {
      [textField resignFirstResponder];
      return NO;
    }
    nextField = [self.textFields objectAtIndex:0];
  }
  else {
    nextField = [self.textFields objectAtIndex:currentIndex + 1];
  }
  [nextField becomeFirstResponder];
  
  return NO;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  NSString *newText = [[textField.text stringByReplacingCharactersInRange:range withString:string] uppercaseString];
  textField.text = newText;
  [self setFinalTextFieldReturnButton];
  return NO;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
  NSInteger index = [self.textFields indexOfObject:textField];
  [[BLAppDelegate appDelegate] setName:textField.text atIndex:index];
}


#pragma mark - IBAction Methods

- (void)nextScreen:(id)sender
{
//  BLCameraViewController *cameraController = [[BLCameraViewController alloc] init];
//  [self.navigationController pushViewController:cameraController animated:YES];
  
  //FUDGED!!!!
  BLFixItemsViewController *fixItemsController = [[BLFixItemsViewController alloc] init];
  fixItemsController.rawText = @"1 Bacon Almsnds 5.00\n2 Fira Pspcvcrs 0.00\n1 southamptsm ips 8.00\n1 Pickiss 4.00\n1 ZZZZZZZZZZZZZZZZZZZZIZ G '  \n1 Ribs 12.00\n1 market fish 26.00\nSUB 101AL; 55.00\n1ax 1: 4.88"; 
  [self.navigationController pushViewController:fixItemsController animated:YES];

}


- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)contentAreaTapped:(UITapGestureRecognizer *)recognizer
{
  if (!CGRectContainsPoint(self.innerContainer.frame, [recognizer locationInView:self.contentArea])) {
    [self.textFields enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
      [textField resignFirstResponder];
    }];
  }  
}

@end
