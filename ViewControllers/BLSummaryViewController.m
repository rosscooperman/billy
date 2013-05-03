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
#import "BLPersonSummaryView.h"
#import "Bill.h"

//#import "LineItem.h"
//#import "Assignment.h"
#import "Person.h"


@interface BLSummaryViewController ()

@property (nonatomic, strong) Bill *bill;


- (void)personViewTapped:(UITapGestureRecognizer *)recognizer;

@end


@implementation BLSummaryViewController

@synthesize contentArea;
@synthesize bill;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{  
  self.bill = [BLAppDelegate appDelegate].currentBill;
  [self.bill.sortedPeople enumerateObjectsUsingBlock:^(Person *person, NSUInteger idx, BOOL *stop) {
    BLPersonSummaryView *summaryView = [[BLPersonSummaryView alloc] initWithPerson:person];
    [self.contentArea addSubview:summaryView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(personViewTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [summaryView addGestureRecognizer:tapRecognizer];
    
    self.contentArea.contentSize = CGSizeMake(320.0f, CGRectGetMaxY(summaryView.frame));
  }];
  
//  self.ratios = [[NSMutableArray alloc] initWithCapacity:bill.splitCount];
//  self.nameViews = [[NSMutableArray alloc] initWithCapacity:bill.splitCount];
//  for (NSInteger i = 0; i < bill.splitCount; i++) {
//    UIView *view = [self generateNameViewForIndex:i];
//    view.frame = CGRectOffset(view.frame, 0.0, 20.0 + ((BOX_HEIGHT + 5.0) * i));
//    [self.nameViews addObject:view];
//    [self.contentArea addSubview:view];
//  }
//  
//  self.detailViews = [NSMutableArray arrayWithCapacity:bill.splitCount];
//  for (NSInteger i = 0; i < bill.splitCount; i++) {
//    [self.detailViews addObject:[NSNull null]];
//  }
//  self.contentArea.contentSize = CGSizeMake(320.0, (bill.splitCount * (BOX_HEIGHT + 5.0)) + 75.0);
}


#pragma mark - Instance Methods

//- (UIView *)generateNameViewForIndex:(NSInteger)index
//{
//  Person *person = [self.people objectAtIndex:index];
//  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(5.0, 0.0, 310.0, BOX_HEIGHT)];
//  
//  // construct and add the name view
//  UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, NAME_BOX_WIDTH, BOX_HEIGHT)];
//  name.backgroundColor = [[BLAppDelegate appDelegate] colorAtIndex:index + 1];
//  name.text = [NSString stringWithFormat:@"  %@", [person.name uppercaseString]];
//  name.textAlignment = UITextAlignmentLeft;
//  name.textColor = [UIColor blackColor];
//  name.font = [UIFont fontWithName:@"Futura-Medium" size:16];
//  [view addSubview:name];
//  
//  // calculate the total cost for the given user
//  __block float total = 0.0;
//  [person.assignments enumerateObjectsUsingBlock:^(Assignment *assignment, BOOL *stop) {
//    total += ((double)assignment.quantity / (double)assignment.lineItem.quantity) * assignment.lineItem.price;
//  }];
//  
//  // add the person's tax and tip into her total
//  float totalRatio = total / self.bill.subtotal;
//  total += self.bill.tax * totalRatio;
//  total += self.bill.tip * totalRatio;
//  [self.ratios addObject:[NSNumber numberWithFloat:totalRatio]];
//  
//  // construct and add the price view
//  UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(NAME_BOX_WIDTH + 2.0, 0.0, PRICE_BOX_WIDTH, BOX_HEIGHT)];
//  price.backgroundColor = [[BLAppDelegate appDelegate] colorAtIndex:index + 1];
//  price.text = [NSString stringWithFormat:@"$%.2f", total];
//  price.textAlignment = UITextAlignmentCenter;
//  price.textColor = [UIColor blackColor];
//  price.font = [UIFont fontWithName:@"Futura-Medium" size:16];
//  [view addSubview:price];
//  
//  // construct and add the button that will toggle the line item view
//  UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//  toggleButton.frame = view.bounds;
//  [toggleButton addTarget:self action:@selector(toggleLineItems:) forControlEvents:UIControlEventTouchUpInside];
//  [view addSubview:toggleButton];
//
//  return view;
//}


//- (UIView *)generateViewForIndex:(NSInteger)index name:(NSString *)name total:(NSInteger)total quantity:(NSInteger)quantity price:(float)price
//{
//  CGFloat y = (2.0 + BOX_HEIGHT) * index;
//  UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, y, 310.0, BOX_HEIGHT)];
//  NSString *detailFont = (quantity <= 0) ? @"Futura-CondensedExtraBold" : @"Futura-Medium";
//  
//  UILabel *quantityView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, BOX_HEIGHT, BOX_HEIGHT)];
//  quantityView.backgroundColor = [UIColor colorWithWhite:0.88627451 alpha:1.0];
//  quantityView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
//  quantityView.textColor = [UIColor blackColor];
//  quantityView.textAlignment = UITextAlignmentCenter;
//  quantityView.text = (quantity <= 0) ? @"-" : [NSString stringWithFormat:@"%d", quantity];
//  [line addSubview:quantityView];
//  
//  UILabel *nameView = [[UILabel alloc] initWithFrame:CGRectMake(BOX_HEIGHT + 2.0, 0.0, 310.0 - BOX_HEIGHT - PRICE_BOX_WIDTH - 4.0, BOX_HEIGHT)];
//  nameView.backgroundColor = [UIColor colorWithWhite:0.88627451 alpha:1.0];
//  nameView.font = [UIFont fontWithName:detailFont size:16];
//  nameView.textColor = [UIColor blackColor];
//  nameView.textAlignment = UITextAlignmentLeft;
//  nameView.text = [NSString stringWithFormat:@"  %@", [name uppercaseString]];
//  [line addSubview:nameView];
//  
//  UILabel *priceView = [[UILabel alloc] initWithFrame:CGRectMake(310.0 - PRICE_BOX_WIDTH, 0.0, PRICE_BOX_WIDTH, BOX_HEIGHT)];
//  priceView.backgroundColor = [UIColor colorWithWhite:0.88627451 alpha:1.0];
//  priceView.font = [UIFont fontWithName:detailFont size:16];
//  priceView.textColor = [UIColor blackColor];
//  priceView.textAlignment = UITextAlignmentCenter;
//  priceView.text = [NSString stringWithFormat:@"$%.2f", (quantity <= 0) ? price : ((float)quantity / (float)total) * price];
//  [line addSubview:priceView];      
//  
//  return line;
//}


//- (void)showLineItems:(id)sender
//{
//  UIView *view = [sender superview];
//  NSInteger index = [self.nameViews indexOfObject:view];
//  UIView *detailView = [[UIView alloc] init];
//  Person *person = [self.people objectAtIndex:index];
//  
//  NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lineItem.index" ascending:YES]];
//  NSArray *sortedAssignments = [person.assignments sortedArrayUsingDescriptors:descriptors];
//  
//  [sortedAssignments enumerateObjectsUsingBlock:^(Assignment *assignment, NSUInteger idx, BOOL *stop) {
//    NSString *name = assignment.lineItem.desc;
//    NSInteger total = assignment.lineItem.quantity;
//    NSInteger quantity = assignment.quantity;
//    float price = assignment.lineItem.price;
//    
//    UIView *line = [self generateViewForIndex:detailView.subviews.count name:name total:total quantity:quantity price:price];
//    [detailView addSubview:line];
//  }];
//  
//  if (detailView.subviews.count > 0) {
//    float ratio = [[self.ratios objectAtIndex:index] floatValue];
//    float subtotal = ratio * (self.bill.subtotal + self.bill.tax);
//
//    UIView *taxView = [self generateViewForIndex:detailView.subviews.count name:@"TAX" total:0 quantity:0 price:ratio * self.bill.tax];
//    [detailView addSubview:taxView];
//
//    UIView *subtotalView = [self generateViewForIndex:detailView.subviews.count name:@"SUBTOTAL" total:0 quantity:0 price:subtotal];
//    [detailView addSubview:subtotalView];
//    
//    UIView *tipView = [self generateViewForIndex:detailView.subviews.count name:@"TIP" total:0 quantity:0 price:ratio * self.bill.tip];
//    [detailView addSubview:tipView];
//    
//    detailView.frame = CGRectMake(5.0, view.frame.origin.y + BOX_HEIGHT + 2.0, 310.0, detailView.subviews.count * (BOX_HEIGHT + 2.0));
//    [self.contentArea insertSubview:detailView atIndex:0];
//    [self.detailViews replaceObjectAtIndex:index withObject:detailView];
//    
//    UIView *shadeView = [[UIView alloc] initWithFrame:detailView.frame];
//    shadeView.backgroundColor = self.view.backgroundColor;
//    [self.contentArea insertSubview:shadeView aboveSubview:detailView];
//        
//    [UIView animateWithDuration:0.3 animations:^{
//      shadeView.frame = CGRectOffset(shadeView.frame, 0.0, shadeView.frame.size.height);
//      for (NSInteger i = index + 1; i < self.nameViews.count; i++) {
//        UIView *nameView = [self.nameViews objectAtIndex:i];
//        nameView.frame = CGRectOffset(nameView.frame, 0.0, shadeView.frame.size.height);
//        
//        UIView *detailView = [self.detailViews objectAtIndex:i];
//        if (![detailView isEqual:[NSNull null]]) {
//          detailView.frame = CGRectOffset(detailView.frame, 0.0, shadeView.frame.size.height);
//        }
//      }
//      
//      CGSize newSize = self.contentArea.contentSize;
//      newSize.height += shadeView.frame.size.height;
//      self.contentArea.contentSize = newSize;
//      
//      CGFloat bottomPoint = detailView.frame.origin.y + detailView.frame.size.height;
//      if (self.contentArea.contentOffset.y + self.contentArea.frame.size.height - 55.0 < bottomPoint) {
//        CGPoint newOffset = CGPointMake(0.0, bottomPoint - self.contentArea.bounds.size.height + 55.0);
//        self.contentArea.contentOffset = newOffset;
//      }
//    } completion:^(BOOL finished) {      
//      [shadeView removeFromSuperview];
//    }];
//  }
//}


//- (void)hideLineItems:(id)sender
//{
//  UIView *view = [sender superview];
//  NSInteger index = [self.nameViews indexOfObject:view];
//  UIView *detailView = [self.detailViews objectAtIndex:index];
//  [self.detailViews replaceObjectAtIndex:index withObject:[NSNull null]];
//  [detailView.superview sendSubviewToBack:detailView];
//  
//  UIView *shadeView = [[UIView alloc] initWithFrame:CGRectOffset(detailView.frame, 0.0, -detailView.frame.size.height)];
//  shadeView.backgroundColor = [UIColor blackColor];
//  [self.contentArea insertSubview:shadeView aboveSubview:detailView];
//  
//  [UIView animateWithDuration:0.3 animations:^{
//    detailView.frame = shadeView.frame;
//    for (NSInteger i = index + 1; i < self.nameViews.count; i++) {
//      UIView *nameView = [self.nameViews objectAtIndex:i];
//      nameView.frame = CGRectOffset(nameView.frame, 0.0, -shadeView.frame.size.height);
//      
//      UIView *detailView = [self.detailViews objectAtIndex:i];
//      if (![detailView isEqual:[NSNull null]]) {
//        detailView.frame = CGRectOffset(detailView.frame, 0.0, -shadeView.frame.size.height);
//      }
//    }
//    CGSize newSize = self.contentArea.contentSize;
//    newSize.height -= shadeView.frame.size.height;
//    self.contentArea.contentSize = newSize;
//  } completion:^(BOOL finished) {    
//    [detailView removeFromSuperview];
//    [shadeView removeFromSuperview];
//  }];
//}


#pragma mark - Action Methods

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


- (void)personViewTapped:(UITapGestureRecognizer *)recognizer
{
  BLPersonSummaryView *summaryView = (BLPersonSummaryView *)recognizer.view;
  TFLog(@"%@ got tapped", summaryView.person.name);
}


#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex > 0) [[BLAppDelegate appDelegate] startOver];
}

@end
