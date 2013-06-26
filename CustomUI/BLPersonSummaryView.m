//
//  BLPersonSummaryView.m
//  billy
//
//  Created by Ross Cooperman on 5/3/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#import "BLPersonSummaryView.h"
#import "BLPaddedLabel.h"
#import "Person.h"


@interface BLPersonSummaryView ()

@property (nonatomic, strong) UIView *leftPad;
@property (nonatomic, strong) BLPaddedLabel *nameView;
@property (nonatomic, strong) BLPaddedLabel *amountView;
@property (nonatomic, strong) NSNumberFormatter *priceFormatter;
@property (readonly) CGFloat borderSize;

@end


@implementation BLPersonSummaryView


#pragma mark - View Lifecycle


- (id)initWithPerson:(Person *)person
{
  self = [super init];
  if (self) {
    self.frame = CGRectMake(0.0f, 50.0f * person.index, 320.0f, 50.0f);
    self.person = person;
  }
  return self;
}


- (void)layoutSubviews
{
  CGFloat subviewHeight = self.frame.size.height - self.borderSize;
  self.backgroundColor = [UIColor colorWithRed:0.55294f green:0.78431f blue:0.65098f alpha:1.0f];
  UIColor *personColor = [[BLAppDelegate appDelegate] colorAtIndex:self.person.index + 1];
  
  if (!self.leftPad) {
    self.leftPad = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, subviewHeight)];
    self.leftPad.backgroundColor = personColor;
    [self addSubview:self.leftPad];
  }
  
  if (!self.nameView) {
    self.nameView = [[BLPaddedLabel alloc] init];
    self.nameView.frame = CGRectMake(40.0f + self.borderSize, 0.0f, 190.0f, subviewHeight);
    self.nameView.padding = 12.0f;
    self.nameView.backgroundColor = personColor;
    self.nameView.textColor = [UIColor blackColor];
    self.nameView.font = [UIFont fontWithName:@"Avenir" size:17.0f];
    self.nameView.text = self.person.name;
    [self addSubview:self.nameView];
  }
  
  if (!self.amountView) {
    CGFloat width = 320.0f - 230.0f + (self.borderSize * 2.0f);
    self.amountView = [[BLPaddedLabel alloc] init];
    self.amountView.frame = CGRectMake(230.0f + (self.borderSize * 2.0f), 0.0f, width, subviewHeight);
    self.amountView.padding = 12.0f;
    self.amountView.backgroundColor = personColor;
    self.amountView.textColor = [UIColor blackColor];
    self.amountView.textAlignment = UITextAlignmentRight;
    self.amountView.font = [UIFont fontWithName:@"Avenir" size:17.0f];
    self.amountView.text = [self.priceFormatter stringFromNumber:[NSNumber numberWithDouble:self.person.amountOwed]];
    [self addSubview:self.amountView];
  }
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

@end
