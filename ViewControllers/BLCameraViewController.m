//
//  BLCameraViewController.m
//  billy
//
//  Created by Ross Cooperman on 5/31/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define CAMERA_BUTTON_COLOR [UIColor colorWithRed:0.42353 green:0.69804 blue:0.55294 alpha:1.0]


#import <ImageIO/CGImageProperties.h>

#import "UIViewController+ButtonManagement.h"
#import "BLCameraViewController.h"
#import "BLCropViewController.h"
#import "BLFixItemsViewController.h"
#import "Bill.h"


@interface BLCameraViewController ()

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *videoCaptureDevice;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillCapturer;
@property (nonatomic, strong) UIImageView *focusArea;


- (void)setupCaptureSession;
- (void)setupFlash;
- (void)viewDidFullyAppear:(BOOL)animated;
- (void)setFocalPoint:(CGPoint)point;
- (void)setFlashMode:(AVCaptureFlashMode)mode;

@end


@implementation BLCameraViewController

@synthesize previewView;
@synthesize mask;
@synthesize previousScreenButton;
@synthesize cameraButton;
@synthesize skipCameraButton;
@synthesize flashButton;
@synthesize captureSession;
@synthesize videoCaptureDevice;
@synthesize stillCapturer;
@synthesize focusArea;


#pragma mark - View Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
  if (!self.navigationController.navigationBarHidden) {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self performSelector:@selector(viewDidFullyAppear:) withObject:nil afterDelay:UINavigationControllerHideShowBarDuration + 0.1];
  }
  else {
    [self viewDidFullyAppear:YES];
  }
}


- (void)viewDidFullyAppear:(BOOL)animated
{
  [self setupCaptureSession];
  [self.captureSession startRunning];
  [self setupFlash];
  
  [UIView animateWithDuration:0.3 animations:^{
    self.mask.alpha = 0.0;
  }];
  
  self.skipCameraButton.enabled = YES;
  self.previousScreenButton.enabled = YES;
  self.cameraButton.enabled = YES;
  self.cameraButton.backgroundColor = CAMERA_BUTTON_COLOR;
}


- (void)viewDidDisappear:(BOOL)animated
{
  self.mask.alpha = 1.0;
  self.cameraButton.backgroundColor = [UIColor lightGrayColor];
  [self.captureSession stopRunning];
}


#pragma mark - Instance Methods

- (void)setupCaptureSession
{
  if (!self.captureSession) {
    NSError *error = nil;
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // add the default video capture device to the session
    self.videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:self.videoCaptureDevice error:&error];
    if (videoInputDevice) [self.captureSession addInput:videoInputDevice];
    else {
      TFLog(@"Could not fetch the default video device: %@", error);
    }
    
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    self.stillCapturer = [[AVCaptureStillImageOutput alloc] init];
    if ([self.captureSession canAddOutput:self.stillCapturer]) {
      self.stillCapturer.outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
      [self.captureSession addOutput:self.stillCapturer];
    }
    else {
      self.stillCapturer = nil;
    }
        
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = self.previewView.bounds;
    [self.previewView.layer addSublayer:previewLayer];    
  }  
}


- (void)setupFlash
{
  if (!self.videoCaptureDevice.hasFlash) {
    self.flashButton.hidden = YES;
    return;
  }
  
  [self setFlashMode:self.videoCaptureDevice.flashMode];
}


- (void)setFocalPoint:(CGPoint)point
{
  // translate the point that was tapped to the coordinate system 
  CGPoint translatedPoint;
  translatedPoint.x = point.y / self.previewView.frame.size.height;
  translatedPoint.y = 1.0 - (point.x / self.previewView.frame.size.width);
  
  if ([self.videoCaptureDevice lockForConfiguration:nil] && [self.videoCaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
    self.videoCaptureDevice.focusPointOfInterest = translatedPoint;
    self.videoCaptureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    [self.videoCaptureDevice unlockForConfiguration];
  }
}


- (void)setFlashMode:(AVCaptureFlashMode)mode
{
  if (mode != self.videoCaptureDevice.flashMode && [self.videoCaptureDevice lockForConfiguration:nil]) {
    if ([self.videoCaptureDevice isFlashModeSupported:mode]) {
      self.videoCaptureDevice.flashMode = mode;
    }
    [self.videoCaptureDevice unlockForConfiguration];
  }
  
  UIImage *buttonImage = nil;
  switch (self.videoCaptureDevice.flashMode) {
    case AVCaptureFlashModeAuto:
      buttonImage = [UIImage imageNamed:@"cameraFlashAuto"];
      break;
      
    case AVCaptureFlashModeOff:
      buttonImage = [UIImage imageNamed:@"cameraFlashOff"];
      break;
      
    case AVCaptureFlashModeOn:
      buttonImage = [UIImage imageNamed:@"cameraFlashOn"];
      break;
  }
  [self.flashButton setImage:buttonImage forState:UIControlStateNormal];
}


#pragma mark - IBAction Methods

- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)takePicture:(id)sender
{
  self.cameraButton.enabled = NO;
  self.skipCameraButton.enabled = NO;
  self.previousScreenButton.enabled = NO;
  
  self.cameraButton.backgroundColor = [UIColor lightGrayColor];
  [UIView animateWithDuration:0.3 animations:^{
    self.mask.alpha = 1.0;
  }];

  AVCaptureConnection *captureConnection = [self.stillCapturer.connections objectAtIndex:0];
  [self.stillCapturer captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:
    ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
      [self.captureSession stopRunning];
      if (error) {
        TFLog(@"Error getting a still capture: %@", error);
      }
      else {
        BLCropViewController *cropController = [[BLCropViewController alloc] init];
        cropController.photoData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        [self.navigationController pushViewController:cropController animated:YES];
        
        if ([BLAppDelegate appDelegate].shouldSendFeedback) {
          [[BLAppDelegate appDelegate].currentBill storeOriginalImage:cropController.photoData];
        }
      }
    }
  ];
}


- (void)skipCamera:(id)sender
{
  [BLAppDelegate appDelegate].currentBill.rawText = @"";
  [[BLAppDelegate appDelegate].managedObjectContext save:nil];
  BLFixItemsViewController *fixItemsController = [[BLFixItemsViewController alloc] init];
  [self.navigationController pushViewController:fixItemsController animated:YES];
}


- (void)setFocus:(UITapGestureRecognizer *)sender
{
  // don't do any of this if point of interest focus is not supported
  if (!self.videoCaptureDevice.focusPointOfInterestSupported) return;
  
  CGPoint point = [sender locationInView:self.previewView];
  
  if (self.focusArea && CGRectContainsPoint(self.focusArea.frame, point)) {
    [self.focusArea removeFromSuperview];
    self.focusArea = nil;
    [self setFocalPoint:self.previewView.center];
    return;
  }
  
  if (!self.focusArea) {
    self.focusArea = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraFocus"]];
    [self.previewView addSubview:self.focusArea];
  }

  self.focusArea.center = point;
  self.focusArea.transform = CGAffineTransformIdentity;
  [self setFocalPoint:point];
  
  [UIView animateWithDuration:0.3 animations:^{
    self.focusArea.transform = CGAffineTransformMakeScale(0.6, 0.6);
  }];
}


- (void)toggleFlash:(id)sender
{
  AVCaptureFlashMode currentMode, nextMode;
  currentMode = nextMode = self.videoCaptureDevice.flashMode;
  
  while (self.videoCaptureDevice.flashMode == currentMode) {
    if (++nextMode > AVCaptureFlashModeAuto) nextMode = AVCaptureFlashModeOff;
    [self setFlashMode:nextMode];
    
    // if we cycle all the way back around avoid an infinite loop
    if (nextMode == currentMode) return;
  }
}

@end
