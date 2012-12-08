//
//  BLPaddedTextView.m
//  billy
//
//  Created by Ross Cooperman on 11/9/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLPaddedTextField.h"
#import "Person.h"


#define TEXT_BOX_HEIGHT 50.0f
#define TEXT_BOX_WIDTH 230.0f
#define PADDING_WIDTH 45.0f


@interface BLPaddedTextField ()

@property (nonatomic, strong) Person *person;


- (void)createSubviews;

@end


@implementation BLPaddedTextField

@synthesize person;


#pragma mark - Object Lifecycle

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) [self createSubviews];
  return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) [self createSubviews];
  return self;
}


- (id)initWithPerson:(Person *)aPerson
{
  CGRect frame = CGRectMake(0.0f, 0.0f, 320.f, TEXT_BOX_HEIGHT);
  self = [self initWithFrame:frame];
  if (self) {
    self.person = aPerson;
  }
  return self;
}


#pragma mark - Overridden Methods

- (CGRect)textRectForBounds:(CGRect)bounds
{
  return CGRectMake((320.0f - TEXT_BOX_WIDTH) / 2.0f, 10.0f, 320.0f, 20.0f);
}


- (CGRect)editingRectForBounds:(CGRect)bounds
{
  return [self textRectForBounds:bounds];
}


- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
  return [self textRectForBounds:bounds];
}


#pragma mark - Instance Methods

- (void)createSubviews
{
  self.font = [UIFont fontWithName:@"Avenir" size:17.0f];
}

@end
