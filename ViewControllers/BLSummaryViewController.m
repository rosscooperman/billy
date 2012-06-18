//
//  BLSummaryViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/17/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define BOX_HEIGHT 45
#define NAME_BOX_WIDTH 211
#define PRICE_BOX_WIDTH 100


#import "BLSummaryViewController.h"


@interface BLSummaryViewController ()

@property (nonatomic, assign) float totalAmount;


- (UIView *)generateNameViewForIndex:(NSInteger)index;

@end


@implementation BLSummaryViewController

@synthesize contentArea;
@synthesize totalAmount;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{  
  BLAppDelegate *appDelegate = [BLAppDelegate appDelegate];
  
  self.totalAmount = 0.0;
  [appDelegate.lineItems enumerateObjectsUsingBlock:^(NSDictionary *lineItem, NSUInteger idx, BOOL *stop) {
    self.totalAmount += [[lineItem valueForKey:@"price"] floatValue];
  }];
  if (self.totalAmount <= 0.0) self.totalAmount = 0.0001; // avoid divide by zero errors
  
  for (NSInteger i = 0; i < appDelegate.splitCount; i++) {
    UIView *view = [self generateNameViewForIndex:i];
    view.frame = CGRectOffset(view.frame, 0.0, 20.0 + ((BOX_HEIGHT + 5.0) * i));
    [self.contentArea addSubview:view];
  }
  
  self.contentArea.contentSize = CGSizeMake(320.0, ((appDelegate.splitCount + 5.0) * BOX_HEIGHT) + 25.0);
}


#pragma mark - Instance Methods

- (UIView *)generateNameViewForIndex:(NSInteger)index
{
  BLAppDelegate *appDelegate = [BLAppDelegate appDelegate];
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(5.0, 0.0, 310.0, BOX_HEIGHT)];
  
  // construct and add the name view
  UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, NAME_BOX_WIDTH, BOX_HEIGHT)];
  name.backgroundColor = [appDelegate colorAtIndex:index + 1];
  name.text = [NSString stringWithFormat:@"  %@", [[appDelegate nameAtIndex:index] uppercaseString]];
  name.textAlignment = UITextAlignmentLeft;
  name.textColor = [UIColor blackColor];
  name.font = [UIFont fontWithName:@"Futura-Medium" size:16];
  [view addSubview:name];
  
  // calculate the total cost for the given user
  __block float total = 0.0;
  [appDelegate.lineItems enumerateObjectsUsingBlock:^(NSDictionary *lineItem, NSUInteger idx, BOOL *stop) {
    NSArray *splits = [lineItem objectForKey:@"splits"];
    NSDictionary *split = [splits objectAtIndex:index];
    float ratio = [[split objectForKey:@"quantity"] floatValue] / [[lineItem objectForKey:@"quantity"] floatValue];
    total += [[lineItem objectForKey:@"price"] floatValue] * ratio;
  }];
  
  // add the person's tax and tip into her total
  float totalRatio = total / self.totalAmount;
  total += appDelegate.taxAmount * totalRatio;
  total += appDelegate.tipAmount * totalRatio;
  
  // construct and add the price view
  UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(NAME_BOX_WIDTH + 2.0, 0.0, PRICE_BOX_WIDTH, BOX_HEIGHT)];
  price.backgroundColor = [appDelegate colorAtIndex:index + 1];
  price.text = [NSString stringWithFormat:@"  $%.2f", total];
  price.textAlignment = UITextAlignmentCenter;
  price.textColor = [UIColor blackColor];
  price.font = [UIFont fontWithName:@"Futura-Medium" size:16];
  [view addSubview:price];

  return view;
}


#pragma mark - IBAction Methods

- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)startOver:(id)sender
{
  NSString *message = @"Are you sure you want to start over?";
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
  [alert show];
}


#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex > 0) {
    [self.navigationController popToRootViewControllerAnimated:YES];
  }
}

@end
