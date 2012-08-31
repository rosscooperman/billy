//
//  BLNamesViewController.m
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define TEXT_BOX_HEIGHT 50
#define TEXT_BOX_WIDTH 206


#import "UIViewController+GuidedTour.h"
#import "UIViewController+ButtonManagement.h"
#import "BLNamesViewController.h"
#import "BLCameraViewController.h"
#import "BLFixItemsViewController.h"
#import "BLTextField.h"
#import "Bill.h"
#import "Person.h"


@interface BLNamesViewController ()

@property (nonatomic, strong) NSMutableArray *textFields;
@property (nonatomic, unsafe_unretained) UITextField *activeField;
@property (nonatomic, strong) UIView *innerContainer;
@property (nonatomic, strong) Bill *bill;
@property (readonly, nonatomic, strong) NSArray *people;


- (UIView *)generateTextFieldForIndex:(NSInteger)index;
- (void)keyboardShown:(NSNotification *)notification;
- (void)keyboardHidden:(NSNotification *)notification;
- (NSArray *)nameDefaults;

@end


@implementation BLNamesViewController

@synthesize contentArea;
@synthesize nextScreenButton;
@synthesize textFields;
@synthesize activeField;
@synthesize innerContainer;
@synthesize bill;
@synthesize people = _people;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  [self showTourText:@"enter nicknames\ntap on a blank color. type. repeat. done." atPoint:CGPointMake(5.0, 5.0) animated:NO];
  if (self.shouldShowTour) [self disableButton:self.nextScreenButton];
  
  // fetch the current bill from the app delegate and allocate an array for the name views we're going to create
  self.bill = [BLAppDelegate appDelegate].currentBill;
  self.textFields = [NSMutableArray arrayWithCapacity:self.bill.splitCount];
  
  // fetch a list of names from the last bill
  NSArray *previousNames = [self nameDefaults];
  
  // make sure the associated bill has enough person objects created
  NSManagedObjectContext *context = [BLAppDelegate appDelegate].managedObjectContext;
  NSInteger shortfall = self.bill.splitCount - self.bill.people.count;
  for (NSInteger i = 0; i < shortfall; i++) {
    Person *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
    person.index = self.bill.people.count;
    if (previousNames.count > person.index) {
      person.name = [previousNames objectAtIndex:person.index];
    }
    [self.bill addPeopleObject:person];
  }
  [context save:nil];
  [context refreshObject:self.bill mergeChanges:NO];
  
  CGFloat innerHeight = ((TEXT_BOX_HEIGHT + 2) * self.bill.splitCount) + 2;
  CGFloat innerTop = ((self.contentArea.frame.size.height - innerHeight) / 2) + 15;
  CGRect frame = CGRectMake((320.0 - TEXT_BOX_WIDTH) / 2.0, innerTop, TEXT_BOX_WIDTH, innerHeight);
  
  self.innerContainer = [[UIView alloc] initWithFrame:frame];
  self.contentArea.contentSize = CGSizeMake(320, MAX(self.contentArea.frame.size.height, frame.size.height));
  
  for (NSInteger i = 0; i < self.bill.splitCount; i++) {
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


#pragma mark - Property Implementations

- (NSArray *)people
{
  if (!_people) {
    NSSortDescriptor *indexDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    _people = [self.bill.people sortedArrayUsingDescriptors:[NSArray arrayWithObject:indexDescriptor]];
  }
  return _people;
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
  textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
  textField.returnKeyType = UIReturnKeyNext;
  textField.delegate = self;
  textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  textField.text = [[self.people objectAtIndex:index] name];
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


- (NSArray *)nameDefaults
{
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Bill"];
  request.predicate = [NSPredicate predicateWithFormat:@"createdAt < %@", self.bill.createdAt];
  request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
  request.fetchLimit = 1;
  
  NSArray *results = [self.bill.managedObjectContext executeFetchRequest:request error:nil];
  if (results && results.count > 0) {
    Bill *previousBill = [results objectAtIndex:0];
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:previousBill.people.count];
    [previousBill.people enumerateObjectsUsingBlock:^(Person *person, BOOL *stop) {
      NSString *name = (person.name) ? person.name : @"";
      [names addObject:name];
    }];
    return names;
  }
  
  return [NSArray array];
}


#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  self.activeField = textField;
  
  if (self.nextScreenButton.enabled) return;
  [self enableButton:self.nextScreenButton type:BLButtonTypeForward];
  [self hideTourTextAnimated:YES complete:nil];
  [self markTourShown];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  UITextField *nextField = nil;
  NSInteger currentIndex = [self.textFields indexOfObject:textField];
  if (currentIndex == self.bill.splitCount - 1) {
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


- (void)textFieldDidEndEditing:(UITextField *)textField
{
  NSInteger index = [self.textFields indexOfObject:textField];
  Person *person = [self.people objectAtIndex:index];
  person.name = textField.text;
  [person.managedObjectContext save:nil];
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
