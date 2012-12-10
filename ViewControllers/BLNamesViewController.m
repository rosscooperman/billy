//
//  BLNamesViewController.m
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define TEXT_BOX_HEIGHT 50.0f
#define TEXT_BOX_WIDTH 230.0f
#define PADDING_WIDTH 45.0f


#import "UIViewController+GuidedTour.h"
#import "UIViewController+ButtonManagement.h"
#import "BLNamesViewController.h"
#import "BLCameraViewController.h"
#import "BLFixItemsViewController.h"
#import "BLPaddedTextField.h"
#import "Bill.h"
#import "Person.h"


@interface BLNamesViewController ()

@property (nonatomic, unsafe_unretained) UITextField *activeField;
@property (nonatomic, strong) UIView *innerContainer;
@property (nonatomic, strong) Bill *bill;


- (void)keyboardShown:(NSNotification *)notification;
- (void)keyboardHidden:(NSNotification *)notification;

@end


@implementation BLNamesViewController

@synthesize contentArea;
@synthesize nextScreenButton;
@synthesize activeField;
@synthesize innerContainer;
@synthesize bill;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{  
  // fetch the current bill from the app delegate and allocate an array for the name views we're going to create
  self.bill = [BLAppDelegate appDelegate].currentBill;
  
  CGFloat size = 1.0f / [UIScreen mainScreen].scale;
  CGFloat innerHeight = (TEXT_BOX_HEIGHT * self.bill.splitCount);
  CGRect frame = CGRectMake(0.0f, -size, 320.0f, innerHeight);
    
  self.innerContainer = [[UIView alloc] initWithFrame:frame];
  self.innerContainer.backgroundColor = [UIColor colorWithRed:0.54118 green:0.77255 blue:0.64706 alpha:1.0];
  self.contentArea.contentSize = CGSizeMake(320.0f, frame.size.height);
  
  NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
  NSArray *sortedPeople = [self.bill.people sortedArrayUsingDescriptors:descriptors];
  
  [sortedPeople enumerateObjectsUsingBlock:^(Person *person, NSUInteger idx, BOOL *stop) {
    BLPaddedTextField *personField = [[BLPaddedTextField alloc] initWithPerson:person];
    personField.delegate = self;
    [self.innerContainer addSubview:personField];
  }];
  
  [self.contentArea insertSubview:self.innerContainer atIndex:0];
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


#pragma mark - Instance Methods

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
  
  if (self.nextScreenButton.enabled) return;
  [self enableButton:self.nextScreenButton type:BLButtonTypeForward];
  [self markTourShown];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  NSPredicate *paddedTextPredicate = [NSPredicate predicateWithFormat: @"class == %@", [BLPaddedTextField class]];
  NSArray *paddedFields = [self.innerContainer.subviews filteredArrayUsingPredicate:paddedTextPredicate];
  NSUInteger nextIndex = [paddedFields indexOfObject:textField] + 1;

  @try {
    BLPaddedTextField *nextField = [paddedFields objectAtIndex:nextIndex];
    if (nextIndex == paddedFields.count - 1) nextField.returnKeyType = UIReturnKeyDone;
    [nextField becomeFirstResponder];
  }
  @catch (NSException *exception) {
    [textField resignFirstResponder];
  }
  
  return NO;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
  BLPaddedTextField *realField = (BLPaddedTextField *)textField;
  realField.person.name = textField.text;
  [realField.person.managedObjectContext save:nil];
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
  [self.innerContainer.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
    if (view.class == [BLPaddedTextField class]) [view resignFirstResponder];
  }];
}

@end
