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
#import "UIViewController+ButtonManagement.h"
#import "BLTaxViewController.h"
#import "BLLineItem.h"
#import "BLSplitAdjuster.h"
#import "Bill.h"
#import "LineItem.h"
#import "Assignment.h"
#import "Person.h"


@interface BLSplitBillViewController ()

@property (nonatomic, assign) NSInteger totalQuantity;
@property (nonatomic, assign) NSInteger assignedQuantity;
@property (nonatomic, readonly) UIView *assignmentView;
@property (nonatomic, assign) NSInteger currentAssignmentIndex;
@property (nonatomic, strong) UIView *currentLineItem;
@property (nonatomic, strong) NSMutableArray *lineItems;
@property (nonatomic, strong) NSArray *people;
@property (nonatomic, strong) Bill *bill;
@property (nonatomic, assign) CGFloat borderWidth;

@property (nonatomic, strong) BLSplitAdjuster *adjusterView;
@property (nonatomic, weak) BLLineItem *activeLineItem;


- (void)lineItemTapped:(id)sender;
- (void)showAdjusterAt:(BLLineItem *)theLineItem;
- (void)hideAdjuster:(void(^)())complete;

- (void)updateAssignmentView;
- (void)updateNextScreenButton;
- (void)updateProgressView:(UIView *)progressView lineItem:(LineItem *)lineItem;
- (void)minusButtonPressed:(id)sender;
- (void)plusButtonPressed:(id)sender;
- (void)add:(NSInteger)amount toAssignmentAtIndex:(NSInteger)index;
- (Assignment *)assignmentForPerson:(Person *)person lineItem:(LineItem *)lineItem;

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
@synthesize bill;
@synthesize people;
@synthesize borderWidth;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  self.borderWidth = 1.0f / [UIScreen mainScreen].scale;
  self.bill = [BLAppDelegate appDelegate].currentBill;
  
  NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
  NSArray *sortedLineItems = [self.bill.lineItems sortedArrayUsingDescriptors:descriptors];
  
  __block NSUInteger currentIndex = 0;
  [sortedLineItems enumerateObjectsUsingBlock:^(LineItem *lineItem, NSUInteger i, BOOL *stop) {
    if (!lineItem.deleted && lineItem.quantity > 0.0 && lineItem.price > 0) {
      BLLineItem *lineItemView = [[BLLineItem alloc] initWithLineItem:lineItem atIndex:currentIndex++];
      [lineItemView addTarget:self action:@selector(lineItemTapped:) forControlEvents:UIControlEventTouchUpInside];
      [self.contentArea addSubview:lineItemView];
      self.contentArea.contentSize = CGSizeMake(320.0f, CGRectGetMaxY(lineItemView.frame) + (1.0f / [UIScreen mainScreen].scale));
    }
  }];
  
  self.adjusterView = [[BLSplitAdjuster alloc] initWithBill:self.bill];
  [self.contentArea insertSubview:self.adjusterView atIndex:0];
}


#pragma mark - Instance Methods

- (void)showAdjusterAt:(BLLineItem *)theLineItem
{
  void(^showBlock)() = ^{
    // set the starting transform of the adjuster view
    self.adjusterView.transform = CGAffineTransformMakeTranslation(0.0f, CGRectGetMaxY(theLineItem.frame) - self.adjusterView.frame.size.height);
    
    // set the transform of each lineItem, the ending transform for the adjuster, and the new contentSize for the contentArea
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0f, self.adjusterView.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
      [self.contentArea.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger i, BOOL *stop) {
        if ([subview isKindOfClass:[BLLineItem class]] && [(BLLineItem *)subview index] > theLineItem.index) {
          subview.transform = transform;
        }
      }];
      self.adjusterView.transform = CGAffineTransformMakeTranslation(0.0f, CGRectGetMaxY(theLineItem.frame));
      self.contentArea.contentSize = CGSizeMake(320.0f, self.contentArea.contentSize.height + self.adjusterView.frame.size.height);
    }];
  };
  
  if (self.activeLineItem) {
    [self hideAdjuster:showBlock];
  }
  else {
    showBlock();
  }

  self.activeLineItem = theLineItem;
}


- (void)hideAdjuster:(void(^)())complete
{
  [UIView animateWithDuration:0.3f animations:^{
    [self.contentArea.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger i, BOOL *stop) {
      if ([subview isKindOfClass:[BLLineItem class]]) subview.transform = CGAffineTransformIdentity;
    }];
    CGFloat transformY = CGRectGetMaxY(self.activeLineItem.frame) - self.adjusterView.frame.size.height;
    self.adjusterView.transform = CGAffineTransformMakeTranslation(0.0f, transformY);
    self.contentArea.contentSize = CGSizeMake(320.0f, self.contentArea.contentSize.height - self.adjusterView.frame.size.height);
  } completion:^(BOOL finished) {
    self.activeLineItem = nil;
    if (complete) complete();
  }];
}


- (Assignment *)assignmentForPerson:(Person *)person lineItem:(LineItem *)lineItem
{
  __block Assignment *found = nil;
  [lineItem.assignments enumerateObjectsUsingBlock:^(Assignment *assignment, BOOL *stop) {
    if (assignment.person == person) {
      *stop = YES;
      found = assignment;
    }
  }];
  return found;
}


- (void)updateAssignmentView
{
  LineItem *lineItem = [self.lineItems objectAtIndex:currentAssignmentIndex];
  double perItemPrice = lineItem.price / (double)lineItem.quantity;
  __block NSInteger lineQuantity = 0;
  
  // update each person's quantity, price, and enabled state of the minus button
  // also calculate how much total quantity has been allocated
  [people enumerateObjectsUsingBlock:^(Person *person, NSUInteger idx, BOOL *stop) {
    UIView *personView = [self.assignmentView.subviews objectAtIndex:idx];

    Assignment *assignment = [self assignmentForPerson:person lineItem:lineItem];
    int64_t currentQuantity = (assignment) ? assignment.quantity : 0;
    
    UILabel *quantityLabel = [personView.subviews objectAtIndex:0];
    quantityLabel.text = [NSString stringWithFormat:@"%lld", currentQuantity];

    UIButton *minusButton = [personView.subviews objectAtIndex:1];
    minusButton.enabled = (currentQuantity > 0);

    UILabel *priceLabel = [personView.subviews objectAtIndex:4];
    priceLabel.text = [NSString stringWithFormat:@"$%.2f", currentQuantity * perItemPrice];

    lineQuantity += currentQuantity;
  }];
  
  // enable/disable the + button as needed (is there any more left to allocate)
  [self.assignmentView.subviews enumerateObjectsUsingBlock:^(UIView *wrapper, NSUInteger idx, BOOL *stop) {
    UIButton *plusButton = [wrapper.subviews objectAtIndex:2];
    plusButton.enabled = (lineQuantity < lineItem.quantity);
  }];
  
  // update the 'progress' view showing what portion each user is responsible for
  UILabel *nameLabel = [self.currentLineItem.subviews objectAtIndex:1];
  UIView *progressView = [nameLabel.subviews objectAtIndex:0];
  [self updateProgressView:progressView lineItem:lineItem];
}


- (void)updateProgressView:(UIView *)progressView lineItem:(LineItem *)lineItem
{
  [progressView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
    [subview removeFromSuperview];
  }];
  
  __block NSInteger allocated = 0;
  __block CGFloat x = 0;
  NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"person.index" ascending:YES]];
  NSArray *sortedAssignments = [lineItem.assignments sortedArrayUsingDescriptors:descriptors];
  
  [sortedAssignments enumerateObjectsUsingBlock:^(Assignment *assignment, NSUInteger idx, BOOL *stop) {
    CGFloat quantity = assignment.quantity;
    CGFloat totalQuantity = lineItem.quantity;
    if (quantity <= 0.0) return;
    
    allocated += quantity;
    CGFloat percentage = quantity / totalQuantity;
    CGFloat width = (allocated >= totalQuantity) ? progressView.frame.size.width - x : progressView.frame.size.width * percentage;
    
    CGRect frame = CGRectMake(x, 0, width, progressView.frame.size.height);
    UIView *progressSegment = [[UIView alloc] initWithFrame:CGRectIntegral(frame)];
    progressSegment.backgroundColor = [[BLAppDelegate appDelegate] colorAtIndex:assignment.person.index + 1];
    [progressView addSubview:progressSegment];
    x += progressSegment.frame.size.width;
  }];
}


- (void)add:(NSInteger)amount toAssignmentAtIndex:(NSInteger)index
{
  LineItem *lineItem = [self.lineItems objectAtIndex:self.currentAssignmentIndex];
  Person *person = [self.people objectAtIndex:index];
  Assignment *assignment = [self assignmentForPerson:person lineItem:lineItem];
  
  if (!assignment) {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Assignment" inManagedObjectContext:lineItem.managedObjectContext];
    assignment = [[Assignment alloc] initWithEntity:entity insertIntoManagedObjectContext:lineItem.managedObjectContext];
    assignment.quantity = 0;
    assignment.person = person;
    assignment.lineItem = lineItem;
  }
  
  assignment.quantity += amount;
  [assignment.managedObjectContext save:nil];
  [self updateAssignmentView];
  
  self.assignedQuantity += amount;
  [self updateNextScreenButton];
}


- (void)updateNextScreenButton
{
  if (self.assignedQuantity >= self.totalQuantity) {
    self.nextScreenButton.enabled = YES;
    self.nextScreenButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.294117647 alpha:0.80];
  }
  else {
    self.nextScreenButton.enabled = NO;
    self.nextScreenButton.backgroundColor = [UIColor lightGrayColor];
  }
}


#pragma mark - Property Implementations

- (UIView *)assignmentView
{
  if (!_assignmentView) {
    NSInteger splitCount = self.bill.splitCount;
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
      minusButton.titleLabel.font = [UIFont fontWithName:@"Futura-Medium" size:30];
      [minusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      [minusButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
      [minusButton setTitle:@"–" forState:UIControlStateNormal];
      minusButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 4, 0);
      [minusButton addTarget:self action:@selector(minusButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
      [wrapper addSubview:minusButton];
      
      frame = CGRectMake(4 + QUANTITY_BOX_WIDTH + BUTTON_WIDTH, 0, BUTTON_WIDTH, BUTTON_WIDTH);
      UIButton *plusButton = [[UIButton alloc] initWithFrame:frame];
      plusButton.backgroundColor = quantityLabel.backgroundColor;
      plusButton.titleLabel.font = [UIFont fontWithName:@"Futura-Medium" size:30];
      [plusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      [plusButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
      [plusButton setTitle:@"+" forState:UIControlStateNormal];
      plusButton.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
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
      nameLabel.text = [[self.people objectAtIndex:i] name];
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


#pragma mark - IBAction Methods

- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)nextScreen:(id)sender
{
  BLTaxViewController *taxController = [[BLTaxViewController alloc] init];
  [self.navigationController pushViewController:taxController animated:YES];
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


- (void)lineItemTapped:(id)sender
{
  if (self.activeLineItem == sender) {
    [self hideAdjuster:nil];
  }
  else {
    [self showAdjusterAt:sender];
  }

  //  if (self.currentAssignmentIndex >= 0) {
  //    [UIView animateWithDuration:0.3 animations:^{
  //      self.assignmentView.frame = CGRectOffset(self.assignmentView.frame, 0, -self.assignmentView.frame.size.height);
  //      for (NSInteger i = self.currentAssignmentIndex + 3; i < self.contentArea.subviews.count; i++) {
  //        CGRect frame = [[self.contentArea.subviews objectAtIndex:i] frame];
  //        [[self.contentArea.subviews objectAtIndex:i] setFrame:CGRectOffset(frame, 0, -(self.assignmentView.frame.size.height + 2))];
  //      }
  //    } completion:^(BOOL finished) {
  //      [[self.contentArea.subviews objectAtIndex:0] removeFromSuperview];
  //      [[self.contentArea.subviews objectAtIndex:0] removeFromSuperview];
  //      [UIView animateWithDuration:0.3 animations:^{
  //        self.contentArea.contentSize = CGSizeMake(320, self.contentArea.contentSize.height - self.assignmentView.frame.size.height - 2);
  //      }];
  //      if (self.currentAssignmentIndex != recognizer.view.tag) {
  //        [self showAssignmentViewAtIndex:recognizer.view.tag];
  //      }
  //      else {
  //        self.currentAssignmentIndex = -1;
  //        self.currentLineItem = nil;
  //      }
  //    }];
  //  }
  //  else {
  //    [self showAssignmentViewAtIndex:recognizer.view.tag];
  //  }
}

@end
