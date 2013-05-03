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
  
  self.subviewsCreated = YES;
  
//  if (!self.leftPad) {
//    self.leftPad = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, subviewHeight)];
//    self.leftPad.backgroundColor = personColor;
//    [self addSubview:self.leftPad];
//  }
//  
//  if (!self.nameView) {
//    self.nameView = [[BLPaddedLabel alloc] init];
//    self.nameView.frame = CGRectMake(40.0f + self.borderSize, 0.0f, 190.0f, subviewHeight);
//    self.nameView.padding = 12.0f;
//    self.nameView.backgroundColor = personColor;
//    self.nameView.textColor = [UIColor blackColor];
//    self.nameView.font = [UIFont fontWithName:@"Avenir" size:17.0f];
//    self.nameView.text = self.person.name;
//    [self addSubview:self.nameView];
//  }
//  
//  if (!self.amountView) {
//    CGFloat width = 320.0f - 230.0f + (self.borderSize * 2.0f);
//    self.amountView = [[BLPaddedLabel alloc] init];
//    self.amountView.frame = CGRectMake(230.0f + (self.borderSize * 2.0f), 0.0f, width, subviewHeight);
//    self.amountView.padding = 12.0f;
//    self.amountView.backgroundColor = personColor;
//    self.amountView.textColor = [UIColor blackColor];
//    self.amountView.textAlignment = UITextAlignmentRight;
//    self.amountView.font = [UIFont fontWithName:@"Avenir" size:17.0f];
//    self.amountView.text = [self.priceFormatter stringFromNumber:[NSNumber numberWithDouble:self.person.amountOwed]];
//    [self addSubview:self.amountView];
//  }
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

@end
