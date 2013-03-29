//
//  BLSplitAdjuster.m
//  billy
//
//  Created by Ross Cooperman on 2/22/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#define HEIGHT 35.0f
#define BORDER (1.0f / [UIScreen mainScreen].scale)


#import "BLSplitAdjuster.h"
#import "Person.h"
#import "LineItem.h"


@interface BLSplitAdjuster ()

- (void)createSubviews;

@end


@implementation BLSplitAdjuster


#pragma mark - Property Methods

- (void)setLineItem:(LineItem *)lineItem
{
  _lineItem = lineItem;
  [self.subviews enumerateObjectsUsingBlock:^(BLSplitAdjusterPerson *personView, NSUInteger i, BOOL *stop) {
    [personView setQuantityFor:lineItem];
  }];
}


#pragma mark - Object Lifecycle

- (id)initWithBill:(Bill *)theBill
{
  self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, HEIGHT * theBill.people.count)];
  if (self) {
    self.bill = theBill;
  }
  return self;
}


#pragma mark - Instance Methods

- (void)createSubviews
{
  NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
  NSArray *people = [self.bill.people sortedArrayUsingDescriptors:descriptors];
  
  [people enumerateObjectsUsingBlock:^(Person *person, NSUInteger i, BOOL *stop) {
    BLSplitAdjusterPerson *personView = [[BLSplitAdjusterPerson alloc] initWithPerson:person];
    personView.delegate = self;
    [self addSubview:personView];
  }];
}


- (void)layoutSubviews
{
  if (self.subviews.count == 0) [self createSubviews];
  [super layoutSubviews];
}


#pragma mark - BLSplitAdjusterPersonDelegate Methods

- (void)quantityAdjustedFor:(Person *)person quantity:(NSUInteger)newQuantity
{
  [self.lineItem assignQuantity:newQuantity forPerson:person];
  [self.subviews enumerateObjectsUsingBlock:^(BLSplitAdjusterPerson *personView, NSUInteger i, BOOL *stop) {
    personView.allowIncrementing = !self.lineItem.isFullyAssigned;
  }];
}


- (float)unitPrice
{
  return (self.lineItem.price / self.lineItem.quantity);
}

@end
