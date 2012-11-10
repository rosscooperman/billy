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
  self = [super init];
  if (self) {
    self.person = aPerson;
    [self createSubviews];
  }
  return self;
}


#pragma mark - Instance Methods

- (void)createSubviews
{
  
}

@end
