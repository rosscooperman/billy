//
//  BLPercentPicker.m
//  billy
//
//  Created by Ross Cooperman on 4/25/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#import "BLPercentPicker.h"
#import "BLPaddedLabel.h"


#define BACKGROUND_COLOR [UIColor colorWithRed:0.98039f green:0.99608f blue:0.99216f alpha:1.0f]
#define LABEL_COLOR [UIColor colorWithRed:0.16863f green:0.32157f blue:0.23922f alpha:1.0f]
#define PERCENTAGE_COLOR [UIColor blackColor]
#define BUTTON_BG_COLOR [UIColor colorWithRed:0.87843f green:0.95294f blue:0.92549f alpha:1.0f]
#define BUTTON_FG_COLOR [UIColor colorWithRed:0.16471f green:0.32941f blue:0.23922f alpha:1.0f]
#define BUTTON_FG_DISABLED_COLOR [UIColor colorWithRed:0.16471f green:0.32941f blue:0.23922f alpha:0.65f]


@interface BLPercentPicker ()

@property (nonatomic, strong) UIButton *minusButton;
@property (nonatomic, strong) UIButton *plusButton;
@property (nonatomic, strong) BLPaddedLabel *labelView;
@property (nonatomic, strong) BLPaddedLabel *percentView;
@property (nonatomic, strong) NSNumberFormatter *percentageFormatter;
@property (nonatomic, strong) NSNumberFormatter *incrementTestFormatter;
@property (nonatomic, strong) UILongPressGestureRecognizer *minusLongPressRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *plusLongPressRecognizer;
@property (nonatomic, strong) NSTimer *longPressTimer;


- (UIButton *)setupButton;
- (void)incrementPercentage:(id)sender;
- (void)decrementPercentage:(id)sender;
- (void)handleDecrementLongPress:(UILongPressGestureRecognizer *)recognizer;
- (void)handleIncrementLongPress:(UILongPressGestureRecognizer *)recognizer;

@end


@implementation BLPercentPicker

@synthesize increment = _increment;


#pragma mark - View Lifecycle


- (void)layoutSubviews
{
  CGFloat border = 1.0f / [UIScreen mainScreen].scale;
  CGFloat subviewHeight = self.frame.size.height - border;
  self.backgroundColor = [UIColor colorWithRed:0.55294f green:0.78431f blue:0.65098f alpha:1.0f];
  
  if (!self.minusButton) {
    self.minusButton = [self setupButton];
    [self.minusButton setImage:[UIImage imageNamed:@"buttonSubtract"] forState:UIControlStateNormal];
    self.minusButton.imageEdgeInsets = UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f);
    self.minusButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, subviewHeight);
    [self.minusButton addTarget:self action:@selector(decrementPercentage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.minusButton];
    
    self.minusLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDecrementLongPress:)];
    self.minusLongPressRecognizer.numberOfTouchesRequired = 1;
    self.minusLongPressRecognizer.minimumPressDuration = 0.5;
    [self.minusButton addGestureRecognizer:self.minusLongPressRecognizer];
  }

  if (!self.plusButton) {
    self.plusButton = [self setupButton];
    [self.plusButton setImage:[UIImage imageNamed:@"buttonAdd"] forState:UIControlStateNormal];
    self.plusButton.frame = CGRectMake(border + 40.0f, 0.0f, 40.0f, subviewHeight);
    [self.plusButton addTarget:self action:@selector(incrementPercentage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.plusButton];

    self.plusLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleIncrementLongPress:)];
    self.plusLongPressRecognizer.numberOfTouchesRequired = 1;
    self.plusLongPressRecognizer.minimumPressDuration = 0.5;
    [self.plusButton addGestureRecognizer:self.plusLongPressRecognizer];
  }
  
  if (!self.labelView) {
    self.labelView = [[BLPaddedLabel alloc] initWithFrame:CGRectMake(80.0f + (2.0f * border), 0.0f, 130.0f - border, subviewHeight)];
    self.labelView.backgroundColor = BACKGROUND_COLOR;
    self.labelView.textColor = LABEL_COLOR;
    self.labelView.textAlignment = UITextAlignmentRight;
    self.labelView.font = [UIFont fontWithName:@"Avenir" size:17.0f];
    [self addSubview:self.labelView];
    self.label = self.label;
  }
  
  if (!self.percentView) {
    CGFloat width = 320.0f - 210.0f + (border * 2.0f);
    self.percentView = [[BLPaddedLabel alloc] initWithFrame:CGRectMake(210.0f + (border * 2.0f), 0.0f, width, subviewHeight)];
    self.percentView.backgroundColor = BACKGROUND_COLOR;
    self.percentView.textColor = PERCENTAGE_COLOR;
    self.percentView.textAlignment = UITextAlignmentRight;
    self.percentView.font = [UIFont fontWithName:@"Avenir" size:17.0f];
    [self addSubview:self.percentView];
    self.percentage = self.percentage;
  }
}


#pragma mark - Property Implementations

- (void)setLabel:(NSString *)label
{
  _label = [NSString stringWithFormat:@"%@ ", label];
  if (self.labelView) self.labelView.text = self.label;
}


- (void)setPercentage:(double)percentage
{
  self.plusButton.enabled = YES;
  self.minusButton.enabled = YES;
  
  // this is some very tricky rounding action.  basically it's looking for the modulus
  // of the percentage over the increment.  if that number is less than 1/2 of the increment
  // the percentage is rounded down.  otherwise, rounded up.  the rouding increment is the
  // increment itself.  this ensures that the percentage is *always* a multiple of the increment
  double modulus = fmod(percentage, self.increment);
  if (modulus > self.increment / 2.0f) {
    percentage += self.increment;
  }
  percentage -= modulus;
  
  if (percentage <= 0.0f) {
    _percentage = 0.0f;
    self.minusButton.enabled = NO;
  }
  else if (percentage >= 1.0f) {
    _percentage = 1.0f;
    self.plusButton.enabled = NO;
  }
  else {
    _percentage = percentage;
  }
  
  if (self.percentView) self.percentView.text = [self.percentageFormatter stringFromNumber:[NSNumber numberWithDouble:self.percentage]];
  
  // notify the delegate that our percentage has changed
  if (self.delegate && [self.delegate respondsToSelector:@selector(percentageChanged:)]) {
    [self.delegate percentageChanged:self];
  }
}


- (NSNumberFormatter *)percentageFormatter
{
  if (!_percentageFormatter) {
    self.percentageFormatter = [[NSNumberFormatter alloc] init];
    self.percentageFormatter.numberStyle = NSNumberFormatterPercentStyle;
    self.percentageFormatter.minimumFractionDigits = self.percentageFormatter.maximumFractionDigits = 0;
  }
  return _percentageFormatter;
}


- (NSNumberFormatter *)incrementTestFormatter
{
  if (!_incrementTestFormatter) {
    self.incrementTestFormatter = [[NSNumberFormatter alloc] init];
    self.incrementTestFormatter.maximumFractionDigits = 5;
  }
  return _incrementTestFormatter;
}


- (void)setIncrement:(double)increment
{
  _increment = increment;
  
  // this is a little crazy.  the idea is just that we always want to make sure that the rounded form of a percentage
  // has the same number of decimal digits as the increment value (otherwise as you increment you get a jittery behavior
  // as the resulting percentages have variable numbers of decimal digits).
  NSString *strIncrement = [self.incrementTestFormatter stringFromNumber:[NSNumber numberWithDouble:increment * 100.0f]];
  NSArray *pieces = [strIncrement componentsSeparatedByString:@"."];
  int digits = (pieces.count > 1) ? [[pieces objectAtIndex:1] length] : 0;
  self.percentageFormatter.minimumFractionDigits = self.percentageFormatter.maximumFractionDigits = digits;
}


- (double)increment
{
  if (!_increment) _increment = 0.01;
  return _increment;
}


#pragma mark - Instance Methods

- (UIButton *)setupButton
{
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.backgroundColor = BUTTON_BG_COLOR;
  [button setTitleColor:BUTTON_FG_COLOR forState:UIControlStateNormal];
  [button setTitleColor:BUTTON_FG_COLOR forState:UIControlStateDisabled];
  return button;
}


#pragma mark - Action Handlers

- (void)incrementPercentage:(id)sender
{
  self.percentage += self.increment;
}


- (void)decrementPercentage:(id)sender
{
  self.percentage -= self.increment;
}


- (void)handleDecrementLongPress:(UILongPressGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    double i = self.increment;
    self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:i target:self selector:@selector(decrementPercentage:) userInfo:nil repeats:YES];
  }
  else if (recognizer.state == UIGestureRecognizerStateEnded) {
    [self.longPressTimer invalidate];
    self.longPressTimer = nil;
  }
}


- (void)handleIncrementLongPress:(UILongPressGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    double i = self.increment;
    self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:i target:self selector:@selector(incrementPercentage:) userInfo:nil repeats:YES];
  }
  else if (recognizer.state == UIGestureRecognizerStateEnded) {
    [self.longPressTimer invalidate];
    self.longPressTimer = nil;
  }
}

@end
