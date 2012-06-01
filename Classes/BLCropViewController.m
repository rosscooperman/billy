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
- (UIImage *)cropImage:(UIImage *)image;
- (UIImage *)reorientImage:(UIImage *)image;
- (UIImage *)grayscaleizeImage:(UIImage *)image;

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


- (UIImage *)cropImage:(UIImage *)image
{
  // figure out where the black bars appear on the image and calculate the scaling factor applied to the image
  CGFloat realAspectRatio = image.size.width / image.size.height;
  CGFloat previewAspectRatio = self.cropBoundary.bounds.size.width / self.cropBoundary.bounds.size.height;
  CGFloat scaleFactor = 0.0, reverseScaleFactor = 0.0;
  if (realAspectRatio > previewAspectRatio) {
    scaleFactor = self.cropBoundary.bounds.size.width / image.size.width;
    reverseScaleFactor = image.size.width / self.cropBoundary.bounds.size.width;
  }
  else {
    scaleFactor = self.cropBoundary.bounds.size.height / image.size.height;
    reverseScaleFactor = image.size.height / self.cropBoundary.bounds.size.height;
  }
  
  // figure out the scaled size of the image (on screen)
  CGSize scaledSize = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor);
  
  // generate the *real* cropping rectangle
  CGRect cropRect = self.cropBoundary.bounds;
  cropRect.origin.x += (self.cropBoundary.bounds.size.width - scaledSize.width) / 2.0;
  cropRect.origin.y += (self.cropBoundary.bounds.size.height - scaledSize.height) / 2.0;
  cropRect.size.width -= self.cropBoundary.bounds.size.width - scaledSize.width;
  cropRect.size.height -= self.cropBoundary.bounds.size.height - scaledSize.height;
  
  // adjust the crop offsets based on the new cropping rectangle
  self.cropLeft -= cropRect.origin.x;
  self.cropRight -= cropRect.origin.x;
  self.cropTop -= cropRect.origin.y;
  self.cropBottom -= cropRect.origin.y;
  
  // adjust the cropping rectangle based on the crop points
  cropRect.origin.x = self.cropLeft;
  cropRect.origin.y = self.cropTop;
  cropRect.size.width = self.cropRight - self.cropLeft;
  cropRect.size.height = self.cropBottom - self.cropTop;
  
  // expand the cropping rectangle using the reverse scaling factor
  cropRect.origin.x *= reverseScaleFactor;
  cropRect.origin.y *= reverseScaleFactor;
  cropRect.size.width *= reverseScaleFactor;
  cropRect.size.height *= reverseScaleFactor;
  
  // crop!
  CGImageRef croppedImageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
  UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef];
  CGImageRelease(croppedImageRef);
  return croppedImage;
}


- (UIImage *)reorientImage:(UIImage *)image
{
  CGAffineTransform transform = CGAffineTransformIdentity;
  switch (image.imageOrientation) {
    case UIImageOrientationDown:
      transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
      transform = CGAffineTransformRotate(transform, M_PI);;
      break;
      
    case UIImageOrientationLeft:
      transform = CGAffineTransformTranslate(transform, image.size.width, 0);
      transform = CGAffineTransformRotate(transform, M_PI_2);
      break;
    
    case UIImageOrientationRight:
      transform = CGAffineTransformTranslate(transform, 0, image.size.height);
      transform = CGAffineTransformRotate(transform, -M_PI_2);
      break;

    default:
      // no need to handle any other cases
      return image;
  }
  
  CGContextRef context = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                               CGImageGetBitsPerComponent(image.CGImage), 0,
                                               CGImageGetColorSpace(image.CGImage),
                                               CGImageGetBitmapInfo(image.CGImage));
  
  CGContextConcatCTM(context, transform);
  if (image.imageOrientation == UIImageOrientationLeft || image.imageOrientation == UIImageOrientationRight) {
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.height, image.size.width), image.CGImage);
  }
  else {
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
  }
  
  CGImageRef rotatedImageRef = CGBitmapContextCreateImage(context);
  UIImage *rotatedImage = [UIImage imageWithCGImage:rotatedImageRef];
  CGContextRelease(context);
  CGImageRelease(rotatedImageRef);
  return rotatedImage;  
}


- (UIImage *)grayscaleizeImage:(UIImage *)image
{
  
  int kRed = 1;
  int kGreen = 2;
  int kBlue = 4;
  
  int colors = kGreen;
  int width = image.size.width;
  int height = image.size.height;
  
  uint32_t *rgbImage = (uint32_t *)malloc(width * height * sizeof(uint32_t));
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  int flags = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast;
  CGContextRef context = CGBitmapContextCreate(rgbImage, width, height, 8, width * 4, colorSpace, flags);
  CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
  CGContextSetShouldAntialias(context, NO);
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  
  // now convert to grayscale
  uint8_t *imageData = (uint8_t *)malloc(width * height);
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
			uint32_t rgbPixel = rgbImage[y * width + x];
			uint32_t sum = 0, count = 0;
			if (colors & kRed)   { sum += (rgbPixel >> 24) & 255; count++; }
			if (colors & kGreen) { sum += (rgbPixel >> 16) & 255; count++; }
			if (colors & kBlue)  { sum += (rgbPixel >> 8)  & 255; count++; }
			imageData[y * width + x] = sum / count;
    }
  }
  free(rgbImage);
  
  // convert from a gray scale image back into a UIImage
  uint8_t *result = (uint8_t *)calloc(width * height * sizeof(uint32_t), 1);
  
  // process the image back to rgb
  for(int i = 0; i < height * width; i++) {
    result[i * 4] = 0;
    int val = imageData[i];
    result[i * 4 + 1] = val;
    result[i * 4 + 2] = val;
    result[i * 4 + 3] = val;
  }
  
  // create a UIImage
  colorSpace = CGColorSpaceCreateDeviceRGB();
  context = CGBitmapContextCreate(result, width, height, 8, width * sizeof(uint32_t), colorSpace, flags);
  CGImageRef grayImageRef = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  UIImage *grayImage = [UIImage imageWithCGImage:grayImageRef];
  CGImageRelease(grayImageRef);
  
  // make sure the data will be released by giving it to an autoreleased NSData
  [NSData dataWithBytesNoCopy:result length:width * height];
  
  return grayImage;
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
  [CATransaction commit];
  
  UIImage *reoriented = [self reorientImage:self.previewView.image];
  UIImage *cropped = [self cropImage:reoriented];
  UIImage *gray = [self grayscaleizeImage:cropped];
  
  // this is just some stub code to visualize the change
  self.previewView.image = gray;
  self.cropBoundary.alpha = 0.0;
  self.processImageButton.hidden = YES;
}

@end
