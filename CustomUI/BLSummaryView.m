//
//  BLSummaryView.m
//  billy
//
//  Created by Ross Cooperman on 4/15/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#import "BLSummaryView.h"
#import "BLPaddedLabel.h"


@interface BLSummaryView ()

@property (nonatomic, strong) UIView *leftPad;
@property (nonatomic, strong) BLPaddedLabel *labelView;
@property (nonatomic, strong) BLPaddedLabel *amountView;
@property (nonatomic, strong) NSNumberFormatter *priceFormatter;

@end


@implementation BLSummaryView


#pragma mark - View Lifecycle

- (void)layoutSubviews
{
  CGFloat border = 1.0f / [UIScreen mainScreen].scale;
  CGFloat subviewHeight = self.frame.size.height - border;
  self.backgroundColor = [UIColor colorWithRed:0.55294f green:0.78431f blue:0.65098f alpha:1.0f];
  
  if (!self.leftPad) {
    self.leftPad = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, subviewHeight)];
    self.leftPad.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.leftPad];
  }
  
  if (!self.labelView) {
    self.labelView = [[BLPaddedLabel alloc] initWithFrame:CGRectMake(40.0f + border, 0.0f, 190.0f, subviewHeight)];
    self.labelView.backgroundColor = [UIColor whiteColor];
    self.labelView.textColor = [UIColor lightGrayColor];
    self.labelView.textAlignment = UITextAlignmentRight;
    self.labelView.font = [UIFont fontWithName:@"Avenir" size:19.0f];
    [self addSubview:self.labelView];
    self.label = self.label;
  }
  
  if (!self.amountView) {
    CGFloat width = 320.0f - 230.0f + (border * 2.0f);
    self.amountView = [[BLPaddedLabel alloc] initWithFrame:CGRectMake(230.0f + (border * 2.0f), 0.0f, width, subviewHeight)];
    self.amountView.backgroundColor = [UIColor whiteColor];
    self.amountView.textColor = [UIColor lightGrayColor];
    self.amountView.textAlignment = UITextAlignmentRight;
    self.amountView.font = [UIFont fontWithName:@"Avenir" size:19.0f];
    self.amountView.padding = 10.0f;
    [self addSubview:self.amountView];
    self.amount = self.amount;
  }
}


#pragma mark - Property Implementations

- (void)setLabel:(NSString *)label
{
  _label = [NSString stringWithFormat:@"%@ ", label];
  if (self.labelView) self.labelView.text = self.label;
}


- (void)setAmount:(double)amount
{
  _amount = amount;
  if (self.amountView) self.amountView.text = [self.priceFormatter stringFromNumber:[NSNumber numberWithDouble:self.amount]];
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
