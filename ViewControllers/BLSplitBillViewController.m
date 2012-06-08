//
//  BLSplitBillViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/2/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define TEXT_BOX_HEIGHT 45
#define QUANTITY_BOX_WIDTH 45
#define NAME_BOX_WIDTH 189
#define SPLIT_NAME_BOX_WIDTH 95
#define PRICE_BOX_WIDTH 72
#define BUTTON_WIDTH 45


#import "BLSplitBillViewController.h"


@interface BLSplitBillViewController ()

@property (nonatomic, assign) NSInteger totalQuantity;
@property (nonatomic, assign) NSInteger assignedQuantity;
@property (nonatomic, readonly) UIView *assignmentView;
@property (nonatomic, assign) NSInteger currentAssignmentIndex;
@property (nonatomic, strong) UIView *currentLineItem;
@property (nonatomic, strong) NSMutableArray *lineItems;


- (void)generateLineItems;
- (UIView *)generateViewForLineItem:(NSDictionary *)data atIndex:(NSInteger)index;
- (UILabel *)generateLineItemLabel;
- (void)lineItemTapped:(UITapGestureRecognizer *)recognizer;
- (void)showAssignmentViewAtIndex:(NSInteger)index;
- (void)updateAssignmentView;
- (void)minusButtonPressed:(id)sender;
- (void)plusButtonPressed:(id)sender;
- (void)add:(NSInteger)amount toAssignmentAtIndex:(NSInteger)index;

@end


@implementation BLSplitBillViewController

@synthesize contentArea;
@synthesize nextScreenButton;
@synthesize totalQuantity = _totalQuantity;
@synthesize assignedQuantity;
@synthesize assignmentView = _assignmentView;
@synthesize currentAssignmentIndex;
@synthesize currentLineItem;
@synthesize lineItems;


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
  NSArray *_lineItems = [BLAppDelegate appDelegate].lineItems;
  
  // if the first line item already has a splits key, no need to continue
  self.lineItems = [NSMutableArray arrayWithCapacity:_lineItems.count];
  [_lineItems enumerateObjectsUsingBlock:^(NSDictionary *lineItem, NSUInteger idx, BOOL *stop) {
    NSMutableDictionary *_lineItem = [NSMutableDictionary dictionaryWithDictionary:lineItem];
    NSMutableArray *splits = [NSMutableArray arrayWithCapacity:[BLAppDelegate appDelegate].splitCount];
    for (NSInteger i = 0; i < [BLAppDelegate appDelegate].splitCount; i++) {
      NSMutableDictionary *split = [NSMutableDictionary dictionaryWithCapacity:2];
      [split setValue:[[BLAppDelegate appDelegate] nameAtIndex:i] forKey:@"name"];
      [split setValue:[NSNumber numberWithInt:0] forKey:@"quantity"];
      [splits addObject:split];
    }
    [_lineItem setValue:splits forKey:@"splits"];
    [self.lineItems insertObject:_lineItem atIndex:idx];
  }];
  
  [self generateLineItems];
  self.currentAssignmentIndex = -1;
  self.currentLineItem = nil;
}


- (void)viewWillDisappear:(BOOL)animated
{
  [[BLAppDelegate appDelegate] setLineItems:self.lineItems];
}


#pragma mark - Instance Methods

- (void)generateLineItems
{
  [self.contentArea.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
    [subview removeFromSuperview];
  }];
  
  [self.lineItems enumerateObjectsUsingBlock:^(NSDictionary *lineItem, NSUInteger idx, BOOL *stop) {
    [self.contentArea addSubview:[self generateViewForLineItem:lineItem atIndex:idx]];
    self.totalQuantity += [[lineItem objectForKey:@"quantity"] integerValue];
  }];
  
  self.contentArea.contentSize = CGSizeMake(320, ((TEXT_BOX_HEIGHT + 2) * self.lineItems.count) + 8);
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
  name.frame = CGRectMake(2 + QUANTITY_BOX_WIDTH, 0, NAME_BOX_WIDTH, TEXT_BOX_HEIGHT);
  name.text = [NSString stringWithFormat:@"  %@", [[lineItem objectForKey:@"name"] uppercaseString]];
  name.textAlignment = UITextAlignmentLeft;
  [wrapper addSubview:name];
  
  // generate the progress view
  UIView *progress = [[UIView alloc] initWithFrame:CGRectMake(0, 0, NAME_BOX_WIDTH, 8)];
  [name addSubview:progress];
  
  // generate the price field
  UILabel *price = [self generateLineItemLabel];
  price.frame = CGRectMake(4 + QUANTITY_BOX_WIDTH + NAME_BOX_WIDTH, 0, PRICE_BOX_WIDTH, TEXT_BOX_HEIGHT);
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
  self.currentAssignmentIndex = index;
  self.currentLineItem = [self.contentArea.subviews objectAtIndex:index];
  [self updateAssignmentView];
  
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
        self.currentLineItem = nil;
      }
    }];
  }
  else {
    [self showAssignmentViewAtIndex:recognizer.view.tag];
  }
}


- (void)updateAssignmentView
{
  NSMutableDictionary *lineItem = [self.lineItems objectAtIndex:currentAssignmentIndex];
  NSMutableArray *splits = [lineItem objectForKey:@"splits"];
  float perItemPrice = [[lineItem objectForKey:@"price"] floatValue] / [[lineItem objectForKey:@"quantity"] floatValue];
  __block NSInteger lineQuantity = 0;
  
  // update each person's quantity, price, and enabled state of the minus button
  // also calculate how much total quantity has been allocated
  [splits enumerateObjectsUsingBlock:^(NSMutableDictionary *split, NSUInteger idx, BOOL *stop) {
    UIView *individual = [self.assignmentView.subviews objectAtIndex:idx];

    UILabel *quantityLabel = [individual.subviews objectAtIndex:0];
    quantityLabel.text = [[split objectForKey:@"quantity"] stringValue];

    UIButton *minusButton = [individual.subviews objectAtIndex:1];
    minusButton.enabled = ([[split objectForKey:@"quantity"] integerValue] > 0);

    UILabel *priceLabel = [individual.subviews objectAtIndex:4];
    priceLabel.text = [NSString stringWithFormat:@"$%.2f", [[split objectForKey:@"quantity"] floatValue] * perItemPrice];
    
    lineQuantity += [[split objectForKey:@"quantity"] integerValue];
  }];
  
  // enable/disable the + button as needed (is there any more left to allocate)
  [self.assignmentView.subviews enumerateObjectsUsingBlock:^(UIView *wrapper, NSUInteger idx, BOOL *stop) {
    UIButton *plusButton = [wrapper.subviews objectAtIndex:2];
    plusButton.enabled = (lineQuantity < [[lineItem objectForKey:@"quantity"] integerValue]);
  }];
  
  // update the 'progress' view showing what portion each user is responsible for
  UILabel *nameLabel = [self.currentLineItem.subviews objectAtIndex:1];
  UIView *progressView = [nameLabel.subviews objectAtIndex:0];
  
  [progressView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
    [subview removeFromSuperview];
  }];
  
  __block NSInteger allocated = 0;
  __block CGFloat x = 0;
  [splits enumerateObjectsUsingBlock:^(NSMutableDictionary *split, NSUInteger idx, BOOL *stop) {
    CGFloat quantity = [[split objectForKey:@"quantity"] floatValue];
    CGFloat totalQuantity = [[lineItem objectForKey:@"quantity"] floatValue];
    if (quantity <= 0.0) return;
    
    allocated += quantity;
    CGFloat percentage = quantity / totalQuantity;
    CGFloat width = (allocated >= totalQuantity) ? progressView.frame.size.width - x : progressView.frame.size.width * percentage;
    
    CGRect frame = CGRectMake(x, 0, width, progressView.frame.size.height);
    UIView *progressSegment = [[UIView alloc] initWithFrame:CGRectIntegral(frame)];
    progressSegment.backgroundColor = [[BLAppDelegate appDelegate] colorAtIndex:idx + 1];
    [progressView addSubview:progressSegment];
    x += progressSegment.frame.size.width;
  }];
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
      
      CGRect frame = CGRectMake(2 + QUANTITY_BOX_WIDTH, 0, BUTTON_WIDTH, BUTTON_WIDTH);
      UIButton *minusButton = [[UIButton alloc] initWithFrame:frame];
      minusButton.backgroundColor = quantityLabel.backgroundColor;
      minusButton.titleLabel.font = [UIFont fontWithName:@"Futura-Medium" size:49];
      [minusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      [minusButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
      [minusButton setTitle:@"-" forState:UIControlStateNormal];
      minusButton.titleEdgeInsets = UIEdgeInsetsMake(0, 1, 10, 0);
      [minusButton addTarget:self action:@selector(minusButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
      [wrapper addSubview:minusButton];
      
      frame = CGRectMake(4 + QUANTITY_BOX_WIDTH + BUTTON_WIDTH, 0, BUTTON_WIDTH, BUTTON_WIDTH);
      UIButton *plusButton = [[UIButton alloc] initWithFrame:frame];
      plusButton.backgroundColor = quantityLabel.backgroundColor;
      plusButton.titleLabel.font = [UIFont fontWithName:@"Futura-Medium" size:30];
      [plusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      [plusButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
      [plusButton setTitle:@"+" forState:UIControlStateNormal];
      plusButton.titleEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
      [plusButton addTarget:self action:@selector(plusButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
      [wrapper addSubview:plusButton];
      
      frame = CGRectMake(6 + QUANTITY_BOX_WIDTH + (BUTTON_WIDTH * 2), 0, SPLIT_NAME_BOX_WIDTH, TEXT_BOX_HEIGHT);
      UIView *nameWrapper = [[UIView alloc] initWithFrame:frame];
      nameWrapper.backgroundColor = quantityLabel.backgroundColor;
      UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectInset(nameWrapper.bounds, 10, 0)];
      nameLabel.backgroundColor = [UIColor clearColor];
      nameLabel.textColor = [UIColor blackColor];
      nameLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:16];
      nameLabel.minimumFontSize = 12;
      nameLabel.text = [[BLAppDelegate appDelegate] nameAtIndex:i];
      [nameWrapper addSubview:nameLabel];
      [wrapper addSubview:nameWrapper];
      
      frame = CGRectMake(8 + QUANTITY_BOX_WIDTH + SPLIT_NAME_BOX_WIDTH + (BUTTON_WIDTH * 2), 0, PRICE_BOX_WIDTH, TEXT_BOX_HEIGHT);
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


- (void)add:(NSInteger)amount toAssignmentAtIndex:(NSInteger)index
{
  NSMutableDictionary *lineItem = [self.lineItems objectAtIndex:self.currentAssignmentIndex];
  NSMutableArray *splits = [lineItem objectForKey:@"splits"];
  NSMutableDictionary *split = [splits objectAtIndex:index];
  NSInteger newValue = [[split objectForKey:@"quantity"] integerValue] + amount;
  [split setValue:[NSNumber numberWithInteger:newValue] forKey:@"quantity"];
  [self updateAssignmentView];
  
  self.assignedQuantity += amount;
  if (self.assignedQuantity >= self.totalQuantity) {
    self.nextScreenButton.enabled = YES;
  }
  else {
    self.nextScreenButton.enabled = NO;
  }
}


#pragma mark - IBAction Methods

- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)nextScreen:(id)sender
{

}


- (void)minusButtonPressed:(id)sender
{
  NSInteger index = [self.assignmentView.subviews indexOfObject:[sender superview]];
  [self add:-1 toAssignmentAtIndex:index];
}


- (void)plusButtonPressed:(id)sender
{
  NSInteger index = [self.assignmentView.subviews indexOfObject:[sender superview]];
  [self add:1 toAssignmentAtIndex:index];
}

@end
