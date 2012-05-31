//
//  BLCropViewController.m
//  billy
//
//  Created by Ross Cooperman on 5/31/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BLCropViewController.h"


@interface BLCropViewController ()

@property (nonatomic, strong) CAShapeLayer *cropBox;
@property (nonatomic, strong) CAShapeLayer *leftMask;
@property (nonatomic, strong) CAShapeLayer *topMask;
@property (nonatomic, strong) CAShapeLayer *rightMask;
@property (nonatomic, strong) CAShapeLayer *bottomMask;
@property (nonatomic, assign) CGPoint startOfPan;
@property (nonatomic, assign) CGPoint lastPanPoint;
@property (nonatomic, assign) CGFloat cropLeft;
@property (nonatomic, assign) CGFloat cropTop;
@property (nonatomic, assign) CGFloat cropRight;
@property (nonatomic, assign) CGFloat cropBottom;


- (CAShapeLayer *)initializeMaskLayer;
- (void)initializeCropRectangle;
- (void)adjustCropRectangle;

@end


@implementation BLCropViewController

@synthesize photoData;
@synthesize previewView;
@synthesize loadingIndicator;
@synthesize cropBoundary;
@synthesize leftHandle;
@synthesize topHandle;
@synthesize rightHandle;
@synthesize bottomHandle;
@synthesize cropBox;
@synthesize leftMask;
@synthesize topMask;
@synthesize rightMask;
@synthesize bottomMask;
@synthesize startOfPan;
@synthesize lastPanPoint;
@synthesize cropLeft;
@synthesize cropTop;
@synthesize cropRight;
@synthesize cropBottom;
@synthesize processImageButton;
@synthesize processingImageIndicator;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  [self initializeCropRectangle];
}


- (void)viewDidAppear:(BOOL)animated
{
  if (self.photoData) {
    self.previewView.alpha = 0.0;
    self.previewView.image = [UIImage imageWithData:self.photoData];
    [UIView animateWithDuration:0.3 animations:^{
      self.previewView.alpha = 1.0;
      self.cropBoundary.alpha = 1.0;
    } completion:^(BOOL finished) {
      [self.loadingIndicator stopAnimating];
    }];
  }
}


#pragma mark - Instance Methods

- (CAShapeLayer *)initializeMaskLayer
{
  CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
  maskLayer.frame = self.cropBoundary.bounds;
  maskLayer.fillColor = [UIColor blackColor].CGColor;
  maskLayer.strokeColor = [UIColor clearColor].CGColor;
  maskLayer.opacity = 0.5;
  return maskLayer;
}


- (void)initializeCropRectangle
{
  // create the crop box itself
  self.cropBox = [[CAShapeLayer alloc] init];
  self.cropBox.frame = self.cropBoundary.bounds;
  self.cropBox.fillColor = [UIColor clearColor].CGColor;
  self.cropBox.strokeColor = [UIColor blackColor].CGColor;
  self.cropBox.lineWidth = 2.0;
  [self.cropBoundary.layer insertSublayer:self.cropBox atIndex:0];
  
  // create the various masking segments
  self.leftMask = [self initializeMaskLayer];
  self.topMask = [self initializeMaskLayer];
  self.rightMask = [self initializeMaskLayer];
  self.bottomMask = [self initializeMaskLayer];
  
  // add the masking segments to the base layer
  [self.cropBoundary.layer insertSublayer:self.leftMask atIndex:0];
  [self.cropBoundary.layer insertSublayer:self.topMask atIndex:0];
  [self.cropBoundary.layer insertSublayer:self.rightMask atIndex:0];
  [self.cropBoundary.layer insertSublayer:self.bottomMask atIndex:0];
  
  // set the starting positions of the crop area
  self.cropLeft = self.leftHandle.center.x;
  self.cropTop = self.topHandle.center.y;
  self.cropRight = self.rightHandle.center.x;
  self.cropBottom = self.bottomHandle.center.y;
  
  // set up the paths of the various pieces
  [self adjustCropRectangle];
}


- (void)adjustCropRectangle
{
  // calculate dimensions of and draw the crop box
  CGRect box = CGRectMake(self.cropLeft, self.cropTop, self.cropRight - self.cropLeft, self.cropBottom - self.cropTop);
  self.cropBox.path = [UIBezierPath bezierPathWithRect:box].CGPath;
  
  // calculate the dimensions of and draw the left masking segment
  box = CGRectMake(0.0, 0.0, self.cropLeft, self.leftMask.bounds.size.height);
  self.leftMask.path = [UIBezierPath bezierPathWithRect:box].CGPath;
  
  // ...the top masking segment
  box = CGRectMake(self.cropLeft, 0.0, self.cropRight - self.cropLeft, self.cropTop);
  self.topMask.path = [UIBezierPath bezierPathWithRect:box].CGPath;

  // ...the right masking segment
  box = CGRectMake(self.cropRight, 0.0, self.leftMask.bounds.size.width - self.cropLeft, self.leftMask.bounds.size.height);
  self.rightMask.path = [UIBezierPath bezierPathWithRect:box].CGPath;
  
  // ...the bottom masking segment
  box = CGRectMake(self.cropLeft, self.cropBottom, self.cropRight - self.cropLeft, self.leftMask.bounds.size.height - self.cropBottom);
  self.bottomMask.path = [UIBezierPath bezierPathWithRect:box].CGPath;
  
  // reposition the handles
  CGFloat cropHeight = self.cropBottom - self.cropTop;
  CGFloat cropWidth = self.cropRight - self.cropLeft;
  self.leftHandle.center = CGPointMake(self.cropLeft, self.cropTop + (cropHeight / 2.0));
  self.topHandle.center = CGPointMake(self.cropLeft + (cropWidth / 2.0), self.cropTop);
  self.rightHandle.center = CGPointMake(self.cropRight, self.leftHandle.center.y);
  self.bottomHandle.center = CGPointMake(self.topHandle.center.x, self.cropBottom);
}


#pragma mark - IBAction Methods

- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)dragHandle:(UIPanGestureRecognizer *)recognizer
{
  switch(recognizer.state) {
    case UIGestureRecognizerStateBegan: {
      self.startOfPan = [recognizer translationInView:self.view];
      self.lastPanPoint = self.startOfPan;
      break;
    }
      
    case UIGestureRecognizerStateChanged: {
      CGPoint newPanPoint = [recognizer translationInView:self.view];
      if (recognizer.view == self.leftHandle) {
        CGFloat newX = self.cropLeft + (newPanPoint.x - self.lastPanPoint.x);
        if (newX > 20 && newX < self.cropRight - 100) {
          self.cropLeft = newX;
        }        
      }
      else if (recognizer.view == self.topHandle) {
        CGFloat newY = self.cropTop + (newPanPoint.y - self.lastPanPoint.y);
        if (newY > 20 && newY < self.cropBottom - 100) {
          self.cropTop = newY;
        }
      }
      else if (recognizer.view == self.rightHandle) {
        CGFloat newX = self.cropRight + (newPanPoint.x - self.lastPanPoint.x);
        if (newX < self.cropBoundary.frame.size.width - 20 && newX > self.cropLeft + 100) {
          self.cropRight = newX;
        }
      }
      else if (recognizer.view == self.bottomHandle) {
        CGFloat newY = self.cropBottom + (newPanPoint.y - self.lastPanPoint.y);
        if (newY < self.cropBoundary.frame.size.height - 55 && newY > self.cropTop + 100) {
          self.cropBottom = newY;
        }
      }
      [self adjustCropRectangle];
      self.lastPanPoint = newPanPoint;
      break;      
    }
                  
    default: {
      
    }
  }
}


- (void)processImage:(id)sender
{
  [self.processImageButton setImage:nil forState:UIControlStateNormal];
  [self.processingImageIndicator startAnimating];
}

@end
