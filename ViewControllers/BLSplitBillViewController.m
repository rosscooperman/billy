//
//  BLSplitBillViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/2/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define TEXT_BOX_HEIGHT 45
#define QUANTITY_BOX_WIDTH 45
#define NAME_BOX_WIDTH 193
#define SPLIT_NAME_BOX_WIDTH 99
#define PRICE_BOX_WIDTH 72
#define BUTTON_WIDTH 45


#import "BLSplitBillViewController.h"


@interface BLSplitBillViewController ()

@property (nonatomic, assign) NSInteger totalQuantity;
@property (nonatomic, assign) NSInteger assignedQuantity;
@property (nonatomic, readonly) UIView *assignmentView;
@property (nonatomic, assign) NSInteger currentAssignmentIndex;


- (void)generateLineItems;
- (UIView *)generateViewForLineItem:(NSDictionary *)data atIndex:(NSInteger)index;
- (UILabel *)generateLineItemLabel;
- (void)lineItemTapped:(UITapGestureRecognizer *)recognizer;
- (void)showAssignmentViewAtIndex:(NSInteger)index;

@end


@implementation BLSplitBillViewController

@synthesize contentArea;
@synthesize nextScreenButton;
@synthesize totalQuantity;
@synthesize assignedQuantity;
@synthesize assignmentView = _assignmentView;
@synthesize currentAssignmentIndex;


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
  [self generateLineItems];
  self.currentAssignmentIndex = -1;
}


#pragma mark - Instance Methods

- (void)generateLineItems
{
  [self.contentArea.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
    [subview removeFromSuperview];
  }];
  
  NSArray *lineItems = [BLAppDelegate appDelegate].lineItems;
  [lineItems enumerateObjectsUsingBlock:^(NSDictionary *lineItem, NSUInteger idx, BOOL *stop) {
    [self.contentArea addSubview:[self generateViewForLineItem:lineItem atIndex:idx]];
    self.totalQuantity += [[lineItem objectForKey:@"quantity"] integerValue];
  }];
  
  self.contentArea.contentSize = CGSizeMake(320, ((TEXT_BOX_HEIGHT + 2) * lineItems.count) + 8);
  self.contentArea.contentInset = UIEdgeInsetsMake(0.0, 0.0, 75.0, 0.0);
}


- (UIView *)generateViewForLineItem:(NSDictionary *)lineItem atIndex:(NSInteger)index
{
  // create the wrapper that will surround all of the text fields
  CGRect frame = CGRectMake(5, 25 + ((TEXT_BOX_HEIGHT + 2) * index), 310, TEXT_BOX_HEIGHT);
  UIView *wrapper = [[UIView alloc] initWithFrame:frame];
  wrapper.tag = index;
  
  // generate the quantity text field
  UILabel *quantity = [self generateLineItemLabel];
  quantity.frame = CGRectMake(0, 0, QUANTITY_BOX_WIDTH, TEXT_BOX_HEIGHT);
  quantity.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
  quantity.text = [[lineItem objectForKey:@"quantity"] stringValue];
  [wrapper addSubview:quantity];
  
  // generate the name text field
  UILabel *name = [self generateLineItemLabel];
  name.frame = CGRectMake(QUANTITY_BOX_WIDTH, 0, NAME_BOX_WIDTH, TEXT_BOX_HEIGHT);
  name.text = [[lineItem objectForKey:@"name"] uppercaseString];
  name.textAlignment = UITextAlignmentLeft;
  [wrapper addSubview:name];
  
  // generate the price field
  UILabel *price = [self generateLineItemLabel];
  price.frame = CGRectMake(QUANTITY_BOX_WIDTH + NAME_BOX_WIDTH, 0, PRICE_BOX_WIDTH, TEXT_BOX_HEIGHT);
  price.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
  price.text = [NSString stringWithFormat:@"$%.2f", [[lineItem objectForKey:@"price"] floatValue]];
  [wrapper addSubview:price];
  
  // create and bind a tap gesture recognizer to the row
  UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lineItemTapped:)];
  tapRecognizer.numberOfTapsRequired = 1;
  tapRecognizer.numberOfTouchesRequired = 1;
  [wrapper addGestureRecognizer:tapRecognizer];
    
  return wrapper;
}


- (UILabel *)generateLineItemLabel
{
  UILabel *label = [[UILabel alloc] init];
  label.backgroundColor = [UIColor colorWithWhite:0.88627451 alpha:1.0];
  label.textColor = [UIColor blackColor];
  label.font = [UIFont fontWithName:@"Futura-Medium" size:16];
  label.textAlignment = UITextAlignmentCenter;
  return label;
}


- (void)showAssignmentViewAtIndex:(NSInteger)index
{  
  CGRect newFrame = self.assignmentView.frame;
  newFrame.origin = [[self.contentArea.subviews objectAtIndex:index] frame].origin;
  newFrame.origin.y += (TEXT_BOX_HEIGHT + 2) - newFrame.size.height;
  self.assignmentView.frame = newFrame;
  [self.contentArea insertSubview:self.assignmentView atIndex:0];
  
  UIView *mask = [[UIView alloc] initWithFrame:self.assignmentView.frame];
  mask.backgroundColor = self.view.backgroundColor;
  [self.contentArea insertSubview:mask atIndex:1];
  
  newFrame.origin.y += newFrame.size.height;
  [UIView animateWithDuration:0.3 animations:^{
    self.assignmentView.frame = newFrame;
    for (NSInteger i = index + 3; i < self.contentArea.subviews.count; i++) {
      CGRect frame = [[self.contentArea.subviews objectAtIndex:i] frame];
      [[self.contentArea.subviews objectAtIndex:i] setFrame:CGRectOffset(frame, 0, self.assignmentView.frame.size.height + 2)];
    }
  } completion:^(BOOL finished) {
    self.currentAssignmentIndex = index;
    self.contentArea.contentSize = CGSizeMake(320, self.contentArea.contentSize.height + self.assignmentView.frame.size.height + 2);
    
    // make sure the whole assignment view is visible    
    CGRect frame = self.contentArea.frame;
    CGPoint translatedOrigin = [self.view convertPoint:self.assignmentView.frame.origin fromView:self.contentArea];
    translatedOrigin.y += self.assignmentView.frame.size.height;
    if (!CGRectContainsPoint(frame, translatedOrigin) ) {
      CGPoint scrollPoint = CGPointMake(0.0, translatedOrigin.y - 405);
      [self.contentArea setContentOffset:scrollPoint animated:YES];
    }
  }];
}


- (void)lineItemTapped:(UITapGestureRecognizer *)recognizer
{
  if (currentAssignmentIndex >= 0) {
    // the upcoming adjustment 
    
    
    [UIView animateWithDuration:0.3 animations:^{
      self.assignmentView.frame = CGRectOffset(self.assignmentView.frame, 0, -self.assignmentView.frame.size.height);
      for (NSInteger i = self.currentAssignmentIndex + 3; i < self.contentArea.subviews.count; i++) {
        CGRect frame = [[self.contentArea.subviews objectAtIndex:i] frame];
        [[self.contentArea.subviews objectAtIndex:i] setFrame:CGRectOffset(frame, 0, -(self.assignmentView.frame.size.height + 2))];
      }
    } completion:^(BOOL finished) {
      [[self.contentArea.subviews objectAtIndex:0] removeFromSuperview];
      [[self.contentArea.subviews objectAtIndex:0] removeFromSuperview];
      [UIView animateWithDuration:0.3 animations:^{
        self.contentArea.contentSize = CGSizeMake(320, self.contentArea.contentSize.height - self.assignmentView.frame.size.height - 2);
      }];
      if (self.currentAssignmentIndex != recognizer.view.tag) {
        [self showAssignmentViewAtIndex:recognizer.view.tag];
      }
      else {
        self.currentAssignmentIndex = -1;
      }
    }];
  }
  else {
    [self showAssignmentViewAtIndex:recognizer.view.tag];
  }
}


#pragma mark - Property Implementations

- (UIView *)assignmentView
{
  if (!_assignmentView) {
    NSInteger splitCount = [BLAppDelegate appDelegate].splitCount;
    _assignmentView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 310, ((TEXT_BOX_HEIGHT + 2) * splitCount) - 2)];
    
    for (NSInteger i = 0; i < splitCount; i++) {
      UIView *wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, i * (TEXT_BOX_HEIGHT + 2), 310, TEXT_BOX_HEIGHT)];
      
      UILabel *quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, QUANTITY_BOX_WIDTH, TEXT_BOX_HEIGHT)];
      quantityLabel.backgroundColor = [[BLAppDelegate appDelegate] colorAtIndex:i + 1];
      quantityLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
      quantityLabel.textColor = [UIColor blackColor];
      quantityLabel.textAlignment = UITextAlignmentCenter;
      quantityLabel.text = @"0";
      [wrapper addSubview:quantityLabel];
      
      UIView *nameWrapper = [[UIView alloc] initWithFrame:CGRectMake(2 + QUANTITY_BOX_WIDTH, 0, SPLIT_NAME_BOX_WIDTH, TEXT_BOX_HEIGHT)];
      nameWrapper.backgroundColor = quantityLabel.backgroundColor;
      UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectInset(nameWrapper.bounds, 10, 0)];
      nameLabel.backgroundColor = [UIColor clearColor];
      nameLabel.textColor = [UIColor blackColor];
      nameLabel.font = [UIFont fontWithName:@"Futura-Medium" size:16];
      nameLabel.text = [[BLAppDelegate appDelegate] nameAtIndex:i];
      [nameWrapper addSubview:nameLabel];
      [wrapper addSubview:nameWrapper];
      
      CGRect frame = CGRectMake(4 + QUANTITY_BOX_WIDTH + SPLIT_NAME_BOX_WIDTH, 0, BUTTON_WIDTH, BUTTON_WIDTH);
      UIButton *minusButton = [[UIButton alloc] initWithFrame:frame];
      minusButton.backgroundColor = quantityLabel.backgroundColor;
      minusButton.titleLabel.font = [UIFont fontWithName:@"Futura-Medium" size:49];
      [minusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      [minusButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
      [minusButton setTitle:@"-" forState:UIControlStateNormal];
      minusButton.titleEdgeInsets = UIEdgeInsetsMake(0, 1, 10, 0);
      [wrapper addSubview:minusButton];
      
      frame = CGRectMake(6 + QUANTITY_BOX_WIDTH + SPLIT_NAME_BOX_WIDTH + BUTTON_WIDTH, 0, BUTTON_WIDTH, BUTTON_WIDTH);
      UIButton *plusButton = [[UIButton alloc] initWithFrame:frame];
      plusButton.backgroundColor = quantityLabel.backgroundColor;
      plusButton.titleLabel.font = [UIFont fontWithName:@"Futura-Medium" size:30];
      [plusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      [plusButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
      [plusButton setTitle:@"+" forState:UIControlStateNormal];
      plusButton.titleEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
      [wrapper addSubview:plusButton];
      
      frame = CGRectMake(8 + QUANTITY_BOX_WIDTH + SPLIT_NAME_BOX_WIDTH + (BUTTON_WIDTH * 2), 0, PRICE_BOX_WIDTH - 4, TEXT_BOX_HEIGHT);
      UILabel *priceLabel = [[UILabel alloc] initWithFrame:frame];
      priceLabel.backgroundColor = quantityLabel.backgroundColor;
      priceLabel.font = [UIFont fontWithName:@"Futura-Medium" size:14];
      priceLabel.textColor = [UIColor blackColor];
      priceLabel.textAlignment = UITextAlignmentCenter;
      priceLabel.text = @"$0.00";
      [wrapper addSubview:priceLabel];

      [_assignmentView addSubview:wrapper];
    }
  }
  return _assignmentView;
}


#pragma mark - IBAction Methods

- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)nextScreen:(id)sender
{

}

@end
