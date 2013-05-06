//
//  BLPersonBreakdownView.m
//  billy
//
//  Created by Ross Cooperman on 5/3/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#import "BLPersonBreakdownView.h"
#import "BLPaddedLabel.h"
#import "Bill.h"
#import "Person.h"
#import "Assignment.h"
#import "LineItem.h"


@interface BLPersonBreakdownView ()

@property (nonatomic, strong) UIView *leftPad;
@property (nonatomic, assign) BOOL subviewsCreated;
@property (nonatomic, strong) NSNumberFormatter *priceFormatter;
@property (readonly) CGFloat borderSize;
@property (readonly) double ratio;
@property (readonly) NSArray *assignments;


- (BLView *)viewForAssignment:(Assignment *)assignment atIndex:(NSUInteger)index;
- (BLView *)viewForTax;
- (BLView *)viewForSubtotal;
- (BLView *)viewForTip;

@end


@implementation BLPersonBreakdownView

@synthesize assignments = _assignments;
@synthesize ratio = _ratio;


#pragma mark - View Lifecycle


- (id)initWithPerson:(Person *)person
{
  self = [super init];
  if (self) {
    self.person = person;
    CGFloat height = (self.assignments.count + 3) * 40.0f;
    self.frame = CGRectMake(0.0f, (50.0f * (person.index + 1)) - height, 320.0f, height);
  }
  return self;
}


- (void)layoutSubviews
{
  if (self.subviewsCreated) return;
  
//  CGFloat subviewHeight = 40.0f - self.borderSize;
  self.backgroundColor = [UIColor colorWithRed:0.55294f green:0.78431f blue:0.65098f alpha:1.0f];
    
  [self.assignments enumerateObjectsUsingBlock:^(Assignment *assignment, NSUInteger i, BOOL *stop) {
    [self addSubview:[self viewForAssignment:assignment atIndex:i]];
  }];
  
  [self addSubview:[self viewForTax]];
  [self addSubview:[self viewForSubtotal]];
  [self addSubview:[self viewForTip]];
  
  self.subviewsCreated = YES;
}


#pragma mark - Property Implementations

- (CGFloat)borderSize
{
  return 1.0f / [UIScreen mainScreen].scale;
}


- (NSNumberFormatter *)priceFormatter
{
  if (!_priceFormatter) {
    self.priceFormatter = [[NSNumberFormatter alloc] init];
    self.priceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
  }
  return _priceFormatter;
}


- (NSArray *)assignments
{
  if (!_assignments) {
    NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lineItem.index" ascending:YES]];
    NSArray *sortedAssignments = [self.person.assignments sortedArrayUsingDescriptors:descriptors];
    
    NSPredicate *zeroPriceFilter = [NSPredicate predicateWithFormat:@"lineItem.price > %f", 0.0f];
    _assignments = [sortedAssignments filteredArrayUsingPredicate:zeroPriceFilter];
  }
  return _assignments;
}


- (void)setPerson:(Person *)person
{
  _person = person;
  _assignments = nil;
  
  __block double total = 0.0f;
  [self.assignments enumerateObjectsUsingBlock:^(Assignment *assigment, NSUInteger idx, BOOL *stop) {
    total += assigment.quantity * (assigment.lineItem.price / assigment.lineItem.quantity);
  }];
  _ratio = total / self.person.bill.subtotal;
}


#pragma mark - Instance Methods

- (BLView *)viewForAssignment:(Assignment *)assignment atIndex:(NSUInteger)index
{
  BLView *assignmentView = [[BLView alloc] initWithFrame:CGRectMake(0.0f, 40.0f * index, 320.0f, 40.0f - self.borderSize)];
  
  BLPaddedLabel *quantity = [[BLPaddedLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f - self.borderSize)];
  quantity.backgroundColor = [UIColor colorWithRed:0.8549f green:0.89804f blue:0.92941f alpha:1.0f];
  quantity.textAlignment = UITextAlignmentCenter;
  quantity.font = [UIFont fontWithName:@"Avenir" size:15.0f];
  quantity.text = [NSString stringWithFormat:@"%lld", assignment.quantity];
  [assignmentView addSubview:quantity];

  BLPaddedLabel *name = [[BLPaddedLabel alloc] initWithFrame:CGRectMake(40.0f + self.borderSize, 0.0f, 190.0f, 40.0f - self.borderSize)];
  name.backgroundColor = [UIColor colorWithRed:0.8549f green:0.89804f blue:0.92941f alpha:1.0f];
  name.padding = 15.0f;
  name.font = [UIFont fontWithName:@"Avenir" size:15.0f];
  name.text = assignment.lineItem.desc;
  [assignmentView addSubview:name];

  BLPaddedLabel *price = [[BLPaddedLabel alloc] init];
  price.frame = CGRectMake(230.0f + (self.borderSize * 2.0f), 0.0f, 90.0f - (self.borderSize * 2.0f), 40.0f - self.borderSize);
  price.backgroundColor = [UIColor colorWithRed:0.8549f green:0.89804f blue:0.92941f alpha:1.0f];
  price.textAlignment = UITextAlignmentRight;
  price.padding = 15.0f;
  price.font = [UIFont fontWithName:@"Avenir" size:15.0f];
  price.text = [self.priceFormatter stringFromNumber:[NSNumber numberWithDouble:self.ratio * assignment.lineItem.price]];
  [assignmentView addSubview:price];
  
  return assignmentView;
}


- (BLView *)viewForTax
{
  BLView *taxView = [[BLView alloc] initWithFrame:CGRectMake(0.0f, 40.0f * self.assignments.count, 320.0f, 40.0f - self.borderSize)];
  
  UIView *leftPad = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f - self.borderSize)];
  leftPad.backgroundColor = [UIColor colorWithRed:0.80784f green:0.85882f blue:0.90588f alpha:1.0f];
  [taxView addSubview:leftPad];
  
  BLPaddedLabel *name = [[BLPaddedLabel alloc] initWithFrame:CGRectMake(40.0f + self.borderSize, 0.0f, 190.0f, 40.0f - self.borderSize)];
  name.backgroundColor = [UIColor colorWithRed:0.80784f green:0.85882f blue:0.90588f alpha:1.0f];
  name.padding = 15.0f;
  name.font = [UIFont fontWithName:@"Avenir-Heavy" size:15.0f];
  name.text = @"Tax";
  [taxView addSubview:name];
  
  BLPaddedLabel *price = [[BLPaddedLabel alloc] init];
  price.frame = CGRectMake(230.0f + (self.borderSize * 2.0f), 0.0f, 90.0f - (self.borderSize * 2.0f), 40.0f - self.borderSize);
  price.backgroundColor = [UIColor colorWithRed:0.80784f green:0.85882f blue:0.90588f alpha:1.0f];
  price.textAlignment = UITextAlignmentRight;
  price.padding = 15.0f;
  price.font = [UIFont fontWithName:@"Avenir-Heavy" size:15.0f];
  price.text = [self.priceFormatter stringFromNumber:[NSNumber numberWithDouble:self.ratio * self.person.bill.tax]];
  [taxView addSubview:price];
  
  return taxView;
}


- (BLView *)viewForSubtotal
{
  BLView *subtotalView = [[BLView alloc] initWithFrame:CGRectMake(0.0f, 40.0f * (self.assignments.count + 1), 320.0f, 40.0f - self.borderSize)];
  
  UIView *leftPad = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f - self.borderSize)];
  leftPad.backgroundColor = [UIColor colorWithRed:0.80784f green:0.85882f blue:0.90588f alpha:1.0f];
  [subtotalView addSubview:leftPad];
  
  BLPaddedLabel *name = [[BLPaddedLabel alloc] initWithFrame:CGRectMake(40.0f + self.borderSize, 0.0f, 190.0f, 40.0f - self.borderSize)];
  name.backgroundColor = [UIColor colorWithRed:0.80784f green:0.85882f blue:0.90588f alpha:1.0f];
  name.padding = 15.0f;
  name.font = [UIFont fontWithName:@"Avenir-Heavy" size:15.0f];
  name.text = @"Subtotal";
  [subtotalView addSubview:name];
  
  BLPaddedLabel *price = [[BLPaddedLabel alloc] init];
  price.frame = CGRectMake(230.0f + (self.borderSize * 2.0f), 0.0f, 90.0f - (self.borderSize * 2.0f), 40.0f - self.borderSize);
  price.backgroundColor = [UIColor colorWithRed:0.80784f green:0.85882f blue:0.90588f alpha:1.0f];
  price.textAlignment = UITextAlignmentRight;
  price.padding = 15.0f;
  price.font = [UIFont fontWithName:@"Avenir-Heavy" size:15.0f];
  double subtotal = self.ratio * (self.person.bill.subtotal + self.person.bill.tax);
  price.text = [self.priceFormatter stringFromNumber:[NSNumber numberWithDouble:subtotal]];
  [subtotalView addSubview:price];

  return subtotalView;
}


- (BLView *)viewForTip
{
  BLView *tipView = [[BLView alloc] initWithFrame:CGRectMake(0.0f, 40.0f * (self.assignments.count + 2), 320.0f, 40.0f - self.borderSize)];
  
  UIView *leftPad = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f - self.borderSize)];
  leftPad.backgroundColor = [UIColor colorWithRed:0.80784f green:0.85882f blue:0.90588f alpha:1.0f];
  [tipView addSubview:leftPad];
  
  BLPaddedLabel *name = [[BLPaddedLabel alloc] initWithFrame:CGRectMake(40.0f + self.borderSize, 0.0f, 190.0f, 40.0f - self.borderSize)];
  name.backgroundColor = [UIColor colorWithRed:0.80784f green:0.85882f blue:0.90588f alpha:1.0f];
  name.padding = 15.0f;
  name.font = [UIFont fontWithName:@"Avenir-Heavy" size:15.0f];
  name.text = @"Tip";
  [tipView addSubview:name];
  
  BLPaddedLabel *price = [[BLPaddedLabel alloc] init];
  price.frame = CGRectMake(230.0f + (self.borderSize * 2.0f), 0.0f, 90.0f - (self.borderSize * 2.0f), 40.0f - self.borderSize);
  price.backgroundColor = [UIColor colorWithRed:0.80784f green:0.85882f blue:0.90588f alpha:1.0f];
  price.textAlignment = UITextAlignmentRight;
  price.padding = 15.0f;
  price.font = [UIFont fontWithName:@"Avenir-Heavy" size:15.0f];
  price.text = [self.priceFormatter stringFromNumber:[NSNumber numberWithDouble:self.ratio * self.person.bill.tip]];
  [tipView addSubview:price];
  
  return tipView;
}

@end
