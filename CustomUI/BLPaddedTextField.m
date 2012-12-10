//
//  BLPaddedTextView.m
//  billy
//
//  Created by Ross Cooperman on 11/9/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "BLPaddedTextField.h"
#import "Person.h"


#define PADDING_WIDTH 45.0f
#define TEXT_BOX_HEIGHT 50.0f


@interface BLPaddedTextField ()

@property (nonatomic, assign) CGFloat lineWidth;

@end


@implementation BLPaddedTextField

@synthesize person = _person;
@synthesize lineWidth;


#pragma mark - Object Lifecycle

- (id)initWithPerson:(Person *)person
{
  self = [self init];
  if (self) {
    self.person = person;
  }
  return self;
}


#pragma mark - Property Implementations

- (void)setPerson:(Person *)person
{
  _person = person;
  
  // adjust some easy stuff
  self.lineWidth = 1.0f / [UIScreen mainScreen].scale;
  self.frame = CGRectMake(0.0f, lineWidth + (TEXT_BOX_HEIGHT * person.index), 320.f, TEXT_BOX_HEIGHT);
  self.font = [UIFont fontWithName:@"Avenir" size:17.0f];
  self.text = self.person.name;
  self.returnKeyType = UIReturnKeyNext;
  
  // create rectangles for each background path
  CGFloat rectHeight = TEXT_BOX_HEIGHT - lineWidth;
  CGRect leftRect = CGRectMake(lineWidth, 0.0f, PADDING_WIDTH, rectHeight);
  CGRect middleRect = CGRectMake(CGRectGetMaxX(leftRect) + lineWidth, 0.0f, 320.0f - (lineWidth * 4.0f) - (PADDING_WIDTH * 2.0f), rectHeight);
  CGRect rightRect = CGRectMake(CGRectGetMaxX(middleRect) + lineWidth, 0.0f, PADDING_WIDTH, rectHeight);
  
  // make the path for the background layer
  UIBezierPath *backgroundPath = [UIBezierPath bezierPath];
  [backgroundPath appendPath:[UIBezierPath bezierPathWithRect:leftRect]];
  [backgroundPath appendPath:[UIBezierPath bezierPathWithRect:middleRect]];
  [backgroundPath appendPath:[UIBezierPath bezierPathWithRect:rightRect]];
  
  // create and add the background layer
  CAShapeLayer *leftPadding = [CAShapeLayer layer];
  leftPadding.fillColor = [[BLAppDelegate appDelegate] colorAtIndex:self.person.index + 1].CGColor;
  leftPadding.path = backgroundPath.CGPath;
  
  [self.layer insertSublayer:leftPadding atIndex:0];
}


#pragma mark - Overridden Methods

- (CGRect)textRectForBounds:(CGRect)bounds
{
  return CGRectMake(PADDING_WIDTH + 12.0f, 14.0f, 320.0f - ((PADDING_WIDTH + 12.0f) * 2.0f), 20.0f);
}


- (CGRect)editingRectForBounds:(CGRect)bounds
{
  return [self textRectForBounds:bounds];
}


- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
  return [self textRectForBounds:bounds];
}

@end
