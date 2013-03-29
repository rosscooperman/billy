//
//  BLSplitAdjuster.m
//  billy
//
//  Created by Ross Cooperman on 2/22/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#define HEIGHT 35.0f
#define BORDER (1.0f / [UIScreen mainScreen].scale)


#import "BLSplitAdjusterPerson.h"
#import "BLPaddedLabel.h"
#import "Person.h"
#import "LineItem.h"
#import "Assignment.h"


@interface BLSplitAdjusterPerson ()

@property (nonatomic, strong) NSNumberFormatter *priceFormatter;
@property (nonatomic, strong) NSNumberFormatter *quantityFormatter;
@property (nonatomic, weak) UIColor *labelColor;
@property (nonatomic, assign) NSUInteger quantity;
@property (nonatomic, strong) BLPaddedLabel *quantityLabel;
@property (nonatomic, strong) BLPaddedLabel *priceLabel;
@property (nonatomic, strong) UIButton *minusButton;
@property (nonatomic, strong) UIButton *plusButton;


- (void)createSubviews;
- (id)adjustView:(id)view width:(CGFloat)width font:(NSString *)font;
- (float)unitPrice;
- (void)resetLabels;

- (void)incrementQuantity:(id)sender;
- (void)decrementQuantity:(id)sender;

@end


@implementation BLSplitAdjusterPerson

@synthesize priceFormatter;
@synthesize quantityFormatter;
@synthesize labelColor;
@synthesize quantity;
@synthesize quantityLabel;
@synthesize priceLabel;
@synthesize minusButton;
@synthesize plusButton;


#pragma mark - Object Lifecycle

- (id)initWithPerson:(Person *)thePerson
{
  self = [super initWithFrame:CGRectMake(0.0f, thePerson.index * HEIGHT, 320.0f, HEIGHT)];
  if (self) {
    self.priceFormatter = [[NSNumberFormatter alloc] init];
    self.priceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;

    self.quantityFormatter = [[NSNumberFormatter alloc] init];
    self.quantityFormatter.numberStyle = NSNumberFormatterDecimalStyle;

    self.quantity = 0;
    self.person = thePerson;
  }
  return self;
}


#pragma mark - Property Implementations

- (BOOL)allowIncrementing
{
  return self.plusButton.enabled;
}


- (void)setAllowIncrementing:(BOOL)allowIncrementing
{
  self.plusButton.enabled = allowIncrementing;
}


#pragma mark - Instance Methods

- (void)createSubviews
{
  self.backgroundColor = [UIColor colorWithRed:0.54118f green:0.77255f blue:0.64706f alpha:1.0f];
  self.labelColor = [[BLAppDelegate appDelegate] colorAtIndex:self.person.index + 1];
  
  // set up the quantity label
  self.quantityLabel = [self adjustView:[[BLPaddedLabel alloc] init] width:(40.0f - BORDER) font:@"Avenir-Heavy"];
  [self addSubview:self.quantityLabel];

  // set up the minus button
  self.minusButton = [self adjustView:[UIButton buttonWithType:UIButtonTypeCustom] width:HEIGHT font:@"Avenir-Heavy"];
  [self.minusButton setTitle:@"‒" forState:UIControlStateNormal];
  [self.minusButton addTarget:self action:@selector(decrementQuantity:) forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:self.minusButton];
  
  // set up the plus button
  self.plusButton = [self adjustView:[UIButton buttonWithType:UIButtonTypeCustom] width:HEIGHT font:@"Avenir-Heavy"];
  [self.plusButton setTitle:@"+" forState:UIControlStateNormal];
  [self.plusButton addTarget:self action:@selector(incrementQuantity:) forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:self.plusButton];
  
  // set up the name label
  BLPaddedLabel *nameLabel = [self adjustView:[[BLPaddedLabel alloc] init] width:123.0f + BORDER font:@"Avenir"];
  nameLabel.textAlignment = UITextAlignmentLeft;
  nameLabel.text = self.person.name;
  [self addSubview:nameLabel];
  
  // set up the price label
  self.priceLabel = [self adjustView:[[BLPaddedLabel alloc] init] width:84.0f font:@"Avenir"];
  self.priceLabel.textAlignment = UITextAlignmentRight;
  self.priceLabel.text = [self.priceFormatter stringFromNumber:[NSNumber numberWithFloat:0.0f]];
  [self addSubview:self.priceLabel];
  
  // trigger an update of quantity (so labels are adjusted, etc)
  [self updateQuantityBy:0];
}


- (id)adjustView:(id)view width:(CGFloat)width font:(NSString *)font
{
  // figure out the X position of this new view based on the frame of the previous subview
  CGFloat newX = (self.subviews.count > 0) ? CGRectGetMaxX([[self.subviews lastObject] frame]) : 0.0f;
  
  // common properties
  [view setFrame:CGRectMake(newX + BORDER, BORDER, width, HEIGHT - BORDER)];
  [view setBackgroundColor:self.labelColor];
  UIFont *theFont = [UIFont fontWithName:font size:16];
  
  // for buttons
  if ([view respondsToSelector:@selector(titleLabel)]) {
    [view titleLabel].textAlignment = UITextAlignmentCenter;
    [view titleLabel].font = theFont;
    [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [view setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
  }
  // for labels
  else {
    [view setTextAlignment:UITextAlignmentCenter];
    [view setFont:theFont];
    [view setColor:[UIColor blackColor]];
  }
  
  // to allow init and customization to happen in one line
  return view;
}


- (void)layoutSubviews
{
  if (self.subviews.count == 0) [self createSubviews];
  [super layoutSubviews];
}


- (void)updateQuantityBy:(NSInteger)amount
{
  self.quantity += amount;
  [self resetLabels];
}


- (float)unitPrice
{
  return (self.delegate) ? [self.delegate unitPrice] : 0.0f;
}


- (void)setQuantityFor:(LineItem *)lineItem
{
  __block Assignment *theAssignment = nil;
  [lineItem.assignments enumerateObjectsUsingBlock:^(Assignment *assignment, BOOL *stop) {
    if (assignment.person == self.person) {
      theAssignment = assignment;
      *stop = YES;
    }
  }];

  self.quantity = (theAssignment) ? theAssignment.quantity : 0;
  [self resetLabels];
}


- (void)resetLabels
{
  float newPrice = (self.quantity) ? self.unitPrice * self.quantity : 0.0f;
  
  self.quantityLabel.text = [self.quantityFormatter stringFromNumber:[NSNumber numberWithUnsignedInteger:self.quantity]];
  self.priceLabel.text = [self.priceFormatter stringFromNumber:[NSNumber numberWithFloat:newPrice]];
  
  self.minusButton.enabled = (self.quantity > 0);
  if (self.delegate && [self.delegate respondsToSelector:@selector(quantityAdjustedFor:quantity:)]) {
    [self.delegate quantityAdjustedFor:self.person quantity:self.quantity];
  }
}


#pragma mark - Action Methods

- (void)incrementQuantity:(id)sender
{
  [self updateQuantityBy:1];
}


- (void)decrementQuantity:(id)sender
{
  [self updateQuantityBy:-1];
}

@end
