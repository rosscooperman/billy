//
//  BLLineItem.m
//  billy
//
//  Created by Ross Cooperman on 2/22/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#define HEIGHT 45.0f
#define QUANTITY_WIDTH 40.0f
#define NAME_WIDTH 195.0f
#define PRICE_WIDTH 85.0f


#import "BLLineItem.h"
#import "BLPaddedLabel.h"
#import "Assignment.h"


@interface BLLineItem ()

@property (nonatomic, assign) CGFloat border;
@property (nonatomic, strong) BLPaddedLabel *quantity;
@property (nonatomic, strong) BLPaddedLabel *name;
@property (nonatomic, strong) BLPaddedLabel *price;
@property (nonatomic, strong) UIView *tooFew;
@property (nonatomic, assign) CGAffineTransform tooFewRotation;
@property (nonatomic, assign) CGAffineTransform tooFewTranslation;


- (void)createSubviews;
- (BLPaddedLabel *)labelWithFrame:(CGRect)frame;

@end


@implementation BLLineItem

@synthesize border;
@synthesize quantity;
@synthesize name;
@synthesize price;
@synthesize tooFew;
@synthesize tooFewRotation;
@synthesize tooFewTranslation;


#pragma mark - Object Lifecycle

- (id)initWithLineItem:(LineItem *)lineItem atIndex:(NSUInteger)index
{
  self.border = 1.0f / [UIScreen mainScreen].scale;
  
  self = [super initWithFrame:CGRectMake(0.0f, (index * HEIGHT) - self.border, 320.0f, HEIGHT)];
  if (self) {
    self.lineItem = lineItem;
    self.index = index;
  }
  return self;
}


#pragma mark - Instance Methods

- (void)createSubviews
{
  self.backgroundColor = [UIColor colorWithRed:0.54118f green:0.77255f blue:0.64706f alpha:1.0f];
  
  // create the quantity label
  self.quantity = [self labelWithFrame:CGRectMake(self.border, self.border, QUANTITY_WIDTH - self.border, HEIGHT - self.border)];
  self.quantity.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];
  self.quantity.text = [NSString stringWithFormat:@"%lld", self.lineItem.quantity];
  self.quantity.clipsToBounds = YES;
  [self addSubview:quantity];
  
  // create the name label
  self.name = [self labelWithFrame:CGRectMake(self.border + QUANTITY_WIDTH, self.border, NAME_WIDTH - self.border, HEIGHT - self.border)];
  self.name.text = [NSString stringWithFormat:@" %@", self.lineItem.desc];
  self.name.textAlignment = UITextAlignmentLeft;
  [self addSubview:name];
  
  // create the price label
  CGRect priceFrame = CGRectMake(320.0f - PRICE_WIDTH + self.border, self.border, PRICE_WIDTH - (self.border * 2.0f), HEIGHT - self.border);
  self.price = [self labelWithFrame:priceFrame];
  self.price.textAlignment = UITextAlignmentRight;
  [self addSubview:self.price];
  
  // create the "too few" indicator
  self.tooFew = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
  self.tooFew.backgroundColor = [UIColor colorWithRed:0.89804f green:0.25882f blue:0.14118f alpha:1.0f];
  self.tooFewRotation = CGAffineTransformMakeRotation(M_PI * 0.25f);
  self.tooFewTranslation = CGAffineTransformMakeTranslation(-10.0f, -10.0f);
  self.tooFew.transform = CGAffineTransformConcat(self.tooFewRotation, self.tooFewTranslation);
  [self.quantity addSubview:self.tooFew];
  
  // use a number formatter to make sure that we use local currency
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
  self.price.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:self.lineItem.price]];
}


- (void)layoutSubviews
{
  if (!self.quantity) [self createSubviews];
  [super layoutSubviews];
}


- (BLPaddedLabel *)labelWithFrame:(CGRect)frame
{
  BLPaddedLabel *label = [[BLPaddedLabel alloc] initWithFrame:frame];
  
  label.backgroundColor = [UIColor whiteColor];
  label.textColor = [UIColor blackColor];
  label.font = [UIFont fontWithName:@"Avenir" size:18.0f];
  label.textAlignment = UITextAlignmentCenter;
  
  return label;
}


- (void)updateCompletionStatus
{
  __block NSUInteger totalAssigned = 0;
  [self.lineItem.assignments enumerateObjectsUsingBlock:^(Assignment *assignment, BOOL *stop) {
    totalAssigned += assignment.quantity;
  }];
  
  [UIView animateWithDuration:0.3f animations:^{
    CGFloat offset = (totalAssigned < self.lineItem.quantity) ? -5.0f : -10.0f;
    self.tooFewTranslation = CGAffineTransformMakeTranslation(offset, offset);
    self.tooFew.transform = CGAffineTransformConcat(self.tooFewRotation, self.tooFewTranslation);
  }];
}

@end
