//
//  BLNamesViewController.m
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define TEXT_BOX_HEIGHT 46
#define TEXT_BOX_WIDTH 230


#import "BLNamesViewController.h"


@interface BLNamesViewController ()

- (UIView *)generateTextFieldForIndex:(NSInteger)index;

@end


@implementation BLNamesViewController

@synthesize contentArea;


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
  NSInteger count = [BLAppDelegate appDelegate].splitCount;
  
  CGFloat innerHeight = ((TEXT_BOX_HEIGHT + 2) * count) + 2;
  CGFloat innerTop = ((self.contentArea.frame.size.height - innerHeight) / 2) + 15;
  CGRect frame = CGRectMake(0, innerTop, TEXT_BOX_WIDTH, innerHeight);
  
  UIView *innerContainer = [[UIView alloc] initWithFrame:frame];
  self.contentArea.contentSize = CGSizeMake(320, frame.size.height);
  
  for (NSInteger i = 0; i < count; i++) {
    [innerContainer addSubview:[self generateTextFieldForIndex:i]];
  }
  
  [self.contentArea addSubview:innerContainer];
}


#pragma mark - Instance Methods

- (UIView *)generateTextFieldForIndex:(NSInteger)index
{
  // set up the wrapper view
  CGRect frame = CGRectMake((320 - TEXT_BOX_WIDTH) / 2, (TEXT_BOX_HEIGHT + 2) * index, TEXT_BOX_WIDTH, TEXT_BOX_HEIGHT);
  UIView *wrapper = [[UIView alloc] initWithFrame:frame];
  wrapper.backgroundColor = [[BLAppDelegate appDelegate] colorAtIndex:index + 1];
  
  
  // set up the text filed
  UITextField *textField = [[UITextField alloc] initWithFrame:CGRectInset(wrapper.bounds, 10, 0)];
  textField.borderStyle = UITextBorderStyleNone;
  textField.font = [UIFont fontWithName:@"Futura-Medium" size:16];
  textField.backgroundColor = [UIColor clearColor];
  textField.textColor = [UIColor blackColor];
  textField.autocorrectionType = UITextAutocorrectionTypeNo;
  textField.keyboardAppearance = UIKeyboardAppearanceAlert;
  textField.delegate = self;
  textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  [wrapper addSubview:textField];
  
  return wrapper;
}


#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  NSString *newText = [[textField.text stringByReplacingCharactersInRange:range withString:string] uppercaseString];
  textField.text = newText;
  return NO;
}


#pragma mark - IBAction Methods

- (void)nextScreen:(id)sender
{
  
}


- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

@end
