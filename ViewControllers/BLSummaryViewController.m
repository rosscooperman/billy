//
//  BLSummaryViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/17/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define BOX_HEIGHT 45
#define NAME_BOX_WIDTH 220
#define PRICE_BOX_WIDTH 88


#import "BLSummaryViewController.h"


@interface BLSummaryViewController ()

@property (nonatomic, assign) float totalAmount;
@property (nonatomic, strong) NSMutableArray *ratios;
@property (nonatomic, strong) NSMutableArray *detailViews;
@property (nonatomic, strong) NSMutableArray *nameViews;


- (UIView *)generateNameViewForIndex:(NSInteger)index;
- (UIView *)generateViewForIndex:(NSInteger)index name:(NSString *)name total:(NSInteger)total quantity:(NSInteger)quantity price:(float)price;
- (void)showLineItems:(id)sender;
- (void)hideLineItems:(id)sender;
- (IBAction)toggleLineItems:(id)sender;

@end


@implementation BLSummaryViewController

@synthesize contentArea;
@synthesize totalAmount;
@synthesize ratios;
@synthesize detailViews;
@synthesize nameViews;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{  
  BLAppDelegate *appDelegate = [BLAppDelegate appDelegate];
  
  self.totalAmount = 0.0;
  [appDelegate.lineItems enumerateObjectsUsingBlock:^(NSDictionary *lineItem, NSUInteger idx, BOOL *stop) {
    self.totalAmount += [[lineItem valueForKey:@"price"] floatValue];
  }];
  if (self.totalAmount <= 0.0) self.totalAmount = 0.0001; // avoid divide by zero errors
  
  self.ratios = [[NSMutableArray alloc] initWithCapacity:appDelegate.splitCount];
  self.nameViews = [[NSMutableArray alloc] initWithCapacity:appDelegate.splitCount];
  for (NSInteger i = 0; i < appDelegate.splitCount; i++) {
    UIView *view = [self generateNameViewForIndex:i];
    view.frame = CGRectOffset(view.frame, 0.0, 20.0 + ((BOX_HEIGHT + 5.0) * i));
    [self.nameViews addObject:view];
    [self.contentArea addSubview:view];
  }
  
  self.detailViews = [NSMutableArray arrayWithCapacity:appDelegate.splitCount];
  for (NSInteger i = 0; i < appDelegate.splitCount; i++) {
    [self.detailViews addObject:[NSNull null]];
  }
  self.contentArea.contentSize = CGSizeMake(320.0, (appDelegate.splitCount * (BOX_HEIGHT + 5.0)) + 75.0);
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
  [self.ratios addObject:[NSNumber numberWithFloat:totalRatio]];
  
  // construct and add the price view
  UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(NAME_BOX_WIDTH + 2.0, 0.0, PRICE_BOX_WIDTH, BOX_HEIGHT)];
  price.backgroundColor = [appDelegate colorAtIndex:index + 1];
  price.text = [NSString stringWithFormat:@"$%.2f", total];
  price.textAlignment = UITextAlignmentCenter;
  price.textColor = [UIColor blackColor];
  price.font = [UIFont fontWithName:@"Futura-Medium" size:16];
  [view addSubview:price];
  
  // construct and add the button that will toggle the line item view
  UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
  toggleButton.frame = view.bounds;
  [toggleButton addTarget:self action:@selector(toggleLineItems:) forControlEvents:UIControlEventTouchUpInside];
  [view addSubview:toggleButton];

  return view;
}


- (UIView *)generateViewForIndex:(NSInteger)index name:(NSString *)name total:(NSInteger)total quantity:(NSInteger)quantity price:(float)price
{
  CGFloat y = (2.0 + BOX_HEIGHT) * index;
  UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, y, 310.0, BOX_HEIGHT)];
  NSString *detailFont = (quantity <= 0) ? @"Futura-CondensedExtraBold" : @"Futura-Medium";
  
  UILabel *quantityView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, BOX_HEIGHT, BOX_HEIGHT)];
  quantityView.backgroundColor = [UIColor colorWithWhite:0.88627451 alpha:1.0];
  quantityView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
  quantityView.textColor = [UIColor blackColor];
  quantityView.textAlignment = UITextAlignmentCenter;
  quantityView.text = (quantity <= 0) ? @"-" : [NSString stringWithFormat:@"%d", quantity];
  [line addSubview:quantityView];
  
  UILabel *nameView = [[UILabel alloc] initWithFrame:CGRectMake(BOX_HEIGHT + 2.0, 0.0, 310.0 - BOX_HEIGHT - PRICE_BOX_WIDTH - 4.0, BOX_HEIGHT)];
  nameView.backgroundColor = [UIColor colorWithWhite:0.88627451 alpha:1.0];
  nameView.font = [UIFont fontWithName:detailFont size:16];
  nameView.textColor = [UIColor blackColor];
  nameView.textAlignment = UITextAlignmentLeft;
  nameView.text = [NSString stringWithFormat:@"  %@", [name uppercaseString]];
  [line addSubview:nameView];
  
  UILabel *priceView = [[UILabel alloc] initWithFrame:CGRectMake(310.0 - PRICE_BOX_WIDTH, 0.0, PRICE_BOX_WIDTH, BOX_HEIGHT)];
  priceView.backgroundColor = [UIColor colorWithWhite:0.88627451 alpha:1.0];
  priceView.font = [UIFont fontWithName:detailFont size:16];
  priceView.textColor = [UIColor blackColor];
  priceView.textAlignment = UITextAlignmentCenter;
  priceView.text = [NSString stringWithFormat:@"$%.2f", (quantity <= 0) ? price : ((float)quantity / (float)total) * price];
  [line addSubview:priceView];      
  
  return line;
}


- (void)showLineItems:(id)sender
{
  UIView *detailView = [[UIView alloc] init];
  
  UIView *view = [sender superview];
  NSInteger index = [self.nameViews indexOfObject:view];
  [[BLAppDelegate appDelegate].lineItems enumerateObjectsUsingBlock:^(NSDictionary *lineItem, NSUInteger idx, BOOL *stop) {
    NSDictionary *split = [[lineItem objectForKey:@"splits"] objectAtIndex:index];
    NSInteger quantity = [[split objectForKey:@"quantity"] integerValue];
    if (quantity > 0) {
      NSString *name = [lineItem objectForKey:@"name"];
      NSInteger total = [[lineItem objectForKey:@"quantity"] integerValue];
      float price = [[lineItem objectForKey:@"price"] floatValue];
      
      UIView *line = [self generateViewForIndex:detailView.subviews.count name:name total:total quantity:quantity price:price];
      [detailView addSubview:line];
    }
  }];
  
  if (detailView.subviews.count > 0) {
    float tax = [[self.ratios objectAtIndex:index] floatValue] * [BLAppDelegate appDelegate].taxAmount;
    float tip = [[self.ratios objectAtIndex:index] floatValue] * [BLAppDelegate appDelegate].tipAmount;
    float subtotal = ([[self.ratios objectAtIndex:index] floatValue] * self.totalAmount) + tax;

    UIView *taxView = [self generateViewForIndex:detailView.subviews.count name:@"TAX" total:0 quantity:0 price:tax];
    [detailView addSubview:taxView];

    UIView *subtotalView = [self generateViewForIndex:detailView.subviews.count name:@"SUBTOTAL" total:0 quantity:0 price:subtotal];
    [detailView addSubview:subtotalView];
    
    UIView *tipView = [self generateViewForIndex:detailView.subviews.count name:@"TIP" total:0 quantity:0 price:tip];
    [detailView addSubview:tipView];
    
    detailView.frame = CGRectMake(5.0, view.frame.origin.y + BOX_HEIGHT + 2.0, 310.0, detailView.subviews.count * (BOX_HEIGHT + 2.0));
    [self.contentArea insertSubview:detailView atIndex:0];
    [self.detailViews replaceObjectAtIndex:index withObject:detailView];
    
    UIView *shadeView = [[UIView alloc] initWithFrame:detailView.frame];
    shadeView.backgroundColor = self.view.backgroundColor;
    [self.contentArea insertSubview:shadeView aboveSubview:detailView];
        
    [UIView animateWithDuration:0.3 animations:^{
      shadeView.frame = CGRectOffset(shadeView.frame, 0.0, shadeView.frame.size.height);
      for (NSInteger i = index + 1; i < self.nameViews.count; i++) {
        UIView *nameView = [self.nameViews objectAtIndex:i];
        nameView.frame = CGRectOffset(nameView.frame, 0.0, shadeView.frame.size.height);
        
        UIView *detailView = [self.detailViews objectAtIndex:i];
        if (![detailView isEqual:[NSNull null]]) {
          detailView.frame = CGRectOffset(detailView.frame, 0.0, shadeView.frame.size.height);
        }
      }
      
      CGSize newSize = self.contentArea.contentSize;
      newSize.height += shadeView.frame.size.height;
      self.contentArea.contentSize = newSize;
      
      CGFloat bottomPoint = detailView.frame.origin.y + detailView.frame.size.height;
      if (self.contentArea.contentOffset.y + self.contentArea.frame.size.height - 55.0 < bottomPoint) {
        CGPoint newOffset = CGPointMake(0.0, bottomPoint - self.contentArea.bounds.size.height + 55.0);
        self.contentArea.contentOffset = newOffset;
      }
    } completion:^(BOOL finished) {      
      [shadeView removeFromSuperview];
    }];
  }
}


- (void)hideLineItems:(id)sender
{
  UIView *view = [sender superview];
  NSInteger index = [self.nameViews indexOfObject:view];
  UIView *detailView = [self.detailViews objectAtIndex:index];
  [self.detailViews replaceObjectAtIndex:index withObject:[NSNull null]];
  [detailView.superview sendSubviewToBack:detailView];
  
  UIView *shadeView = [[UIView alloc] initWithFrame:CGRectOffset(detailView.frame, 0.0, -detailView.frame.size.height)];
  shadeView.backgroundColor = [UIColor blackColor];
  [self.contentArea insertSubview:shadeView aboveSubview:detailView];
  
  [UIView animateWithDuration:0.3 animations:^{
    detailView.frame = shadeView.frame;
    for (NSInteger i = index + 1; i < self.nameViews.count; i++) {
      UIView *nameView = [self.nameViews objectAtIndex:i];
      nameView.frame = CGRectOffset(nameView.frame, 0.0, -shadeView.frame.size.height);
      
      UIView *detailView = [self.detailViews objectAtIndex:i];
      if (![detailView isEqual:[NSNull null]]) {
        detailView.frame = CGRectOffset(detailView.frame, 0.0, -shadeView.frame.size.height);
      }
    }
    CGSize newSize = self.contentArea.contentSize;
    newSize.height -= shadeView.frame.size.height;
    self.contentArea.contentSize = newSize;
  } completion:^(BOOL finished) {    
    [detailView removeFromSuperview];
    [shadeView removeFromSuperview];
  }];
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


- (void)toggleLineItems:(id)sender
{
  UIView *view = [sender superview];
  NSInteger index = [self.nameViews indexOfObject:view];
  if ([[self.detailViews objectAtIndex:index] isEqual:[NSNull null]]) {
    [self showLineItems:sender];
  }
  else {
    [self hideLineItems:sender];
  }
}


#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex > 0) {
    [self.navigationController popToRootViewControllerAnimated:YES];
  }
}

@end
