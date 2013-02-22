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
#import "BLPaddedLabel.h"
#import "Person.h"


@interface BLSplitAdjuster ()

- (void)createSubviews;
- (void)addPersonView:(Person *)person;

@end


@implementation BLSplitAdjuster


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
    [self addPersonView:person];
  }];
}


- (void)layoutSubviews
{
  if (self.subviews.count == 0) [self createSubviews];
  [super layoutSubviews];
}


- (void)addPersonView:(Person *)person
{
  UIView *personView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, HEIGHT * person.index, 320.0f, HEIGHT)];
  UIColor *labelColor = [[BLAppDelegate appDelegate] colorAtIndex:person.index + 1];
  personView.backgroundColor = [UIColor colorWithRed:0.54118f green:0.77255f blue:0.64706f alpha:1.0f];
  
  // set up the quantity view
  BLPaddedLabel *quantity = [[BLPaddedLabel alloc] initWithFrame:CGRectMake(BORDER, BORDER, 40.0f - BORDER, HEIGHT - BORDER)];
  quantity.backgroundColor = labelColor;
  quantity.font = [UIFont fontWithName:@"Avenir-Heavy" size:16];
  quantity.textAlignment = UITextAlignmentCenter;
  quantity.tag = 0;
  quantity.text = @"0";
  [personView addSubview:quantity];
  
  [self addSubview:personView];
}

@end
