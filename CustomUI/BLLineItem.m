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



#pragma mark - Custom Left-padded UILabel

@interface PaddedLabel : UILabel

@end

@implementation PaddedLabel

- (void)drawTextInRect:(CGRect)rect
{
  CGRect inset = (self.textAlignment == UITextAlignmentCenter) ? rect : CGRectInset(rect, 6.0f, 0.0f);
  [super drawTextInRect:inset];
}

@end



@interface BLLineItem ()

@property (nonatomic, assign) CGFloat border;
@property (nonatomic, strong) PaddedLabel *quantity;
@property (nonatomic, strong) PaddedLabel *name;
@property (nonatomic, strong) PaddedLabel *price;


- (void)createSubviews;
- (PaddedLabel *)labelWithFrame:(CGRect)frame;

@end


@implementation BLLineItem

@synthesize border;
@synthesize quantity;
@synthesize name;
@synthesize price;


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
  self.quantity.text = (self.lineItem.quantity > 0) ? [NSString stringWithFormat:@"%lld", self.lineItem.quantity] : @"";
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


- (PaddedLabel *)labelWithFrame:(CGRect)frame
{
  PaddedLabel *label = [[PaddedLabel alloc] initWithFrame:frame];
  
  label.backgroundColor = [UIColor whiteColor];
  label.textColor = [UIColor blackColor];
  label.font = [UIFont fontWithName:@"Avenir" size:18.0f];
  label.textAlignment = UITextAlignmentCenter;
  
  return label;
}

@end
