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
#import "BLTextField.h"


@interface BLNamesViewController ()

@property (nonatomic, strong) NSMutableArray *textFields;
@property (nonatomic, unsafe_unretained) UITextField *activeField;
@property (nonatomic, strong) UIView *innerContainer;


- (UIView *)generateTextFieldForIndex:(NSInteger)index;
- (void)keyboardShown:(NSNotification *)notification;
- (void)keyboardHidden:(NSNotification *)notification;

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
  CGRect frame = CGRectMake((320.0 - TEXT_BOX_WIDTH) / 2.0, innerTop, TEXT_BOX_WIDTH, innerHeight);
  
  self.innerContainer = [[UIView alloc] initWithFrame:frame];
  self.contentArea.contentSize = CGSizeMake(320, MAX(self.contentArea.frame.size.height, frame.size.height));
  
  for (NSInteger i = 0; i < count; i++) {
    [self.innerContainer addSubview:[self generateTextFieldForIndex:i]];
  }
  [self.textFields.lastObject setReturnKeyType:UIReturnKeyDone];
  
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
  // set up the text field
  BLTextField *textField = [[BLTextField alloc] initWithFrame:CGRectMake(0.0, (TEXT_BOX_HEIGHT + 2) * index, TEXT_BOX_WIDTH, TEXT_BOX_HEIGHT)];
  textField.borderStyle = UITextBorderStyleNone;
  textField.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:26];
  textField.backgroundColor = [[BLAppDelegate appDelegate] colorAtIndex:index + 1];;
  textField.textColor = [UIColor blackColor];
  textField.autocorrectionType = UITextAutocorrectionTypeNo;
  textField.keyboardAppearance = UIKeyboardAppearanceAlert;
  textField.returnKeyType = UIReturnKeyNext;
  textField.delegate = self;
  textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  textField.text = [[[BLAppDelegate appDelegate] nameAtIndex:index] uppercaseString];
  [self.textFields insertObject:textField atIndex:index];
  
  return textField;
}


- (void)keyboardShown:(NSNotification *)notification
{
  CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
  self.contentArea.contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
  self.contentArea.scrollIndicatorInsets = UIEdgeInsetsMake(20.0, 0.0, keyboardSize.height, 0.0);
  
  CGRect frame = self.contentArea.frame;
  frame.size.height -= keyboardSize.height;
  CGPoint translatedOrigin = [self.view convertPoint:self.activeField.frame.origin fromView:self.innerContainer];
  translatedOrigin.y += TEXT_BOX_HEIGHT + 10;
  if (!CGRectContainsPoint(frame, translatedOrigin) ) {
    CGPoint scrollPoint = CGPointMake(0.0, translatedOrigin.y - (self.view.frame.size.height - keyboardSize.height));
    [self.contentArea setContentOffset:scrollPoint animated:YES];
  }
}


- (void)keyboardHidden:(NSNotification *)notification
{
  [UIView animateWithDuration:0.3 animations:^{
    self.contentArea.contentInset = UIEdgeInsetsZero;
    self.contentArea.scrollIndicatorInsets = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
  }];
}


#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  self.activeField = textField;
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
  return NO;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
  NSInteger index = [self.textFields indexOfObject:textField];
  [[BLAppDelegate appDelegate] setName:textField.text atIndex:index];
}


#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  return !CGRectContainsPoint(self.innerContainer.frame, [touch locationInView:self.contentArea]);
}


#pragma mark - IBAction Methods

- (void)nextScreen:(id)sender
{
  BLCameraViewController *cameraController = [[BLCameraViewController alloc] init];
  [self.navigationController pushViewController:cameraController animated:YES];
}


- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)contentAreaTapped:(UITapGestureRecognizer *)recognizer
{
  [self.textFields enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
    [textField resignFirstResponder];
  }];
}

@end
