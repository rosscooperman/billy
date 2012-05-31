//
//  BLCameraViewController.m
//  billy
//
//  Created by Ross Cooperman on 5/31/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define CAMERA_BUTTON_COLOR [UIColor colorWithRed:0.443137255 green:0.921568627 blue:0.541176471 alpha:1.0]


#import "BLCameraViewController.h"
#import "BLCropViewController.h"


@interface BLCameraViewController ()

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *videoCaptureDevice;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillCapturer;


- (void)setupCaptureSession;
- (void)setupFlash;

@end


@implementation BLCameraViewController

@synthesize previewView;
@synthesize mask;
@synthesize cameraButton;
@synthesize captureSession;
@synthesize videoCaptureDevice;
@synthesize stillCapturer;


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
  [UIApplication sharedApplication].statusBarHidden = YES;
}


- (void)viewWillDisappear:(BOOL)animated
{
  [UIApplication sharedApplication].statusBarHidden = NO;
}


- (void)viewDidAppear:(BOOL)animated
{
  [self setupCaptureSession];
  [self.captureSession startRunning];
  [self setupFlash];
  
  [UIView animateWithDuration:0.3 animations:^{
    self.mask.alpha = 0.0;
  }];

  self.cameraButton.enabled = YES;
  self.cameraButton.backgroundColor = CAMERA_BUTTON_COLOR;
}


- (void)viewDidDisappear:(BOOL)animated
{
  self.mask.alpha = 1.0;
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
  if ([self.videoCaptureDevice lockForConfiguration:nil]) {
    if ([self.videoCaptureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
      self.videoCaptureDevice.flashMode = AVCaptureFlashModeAuto;
    }
    [self.videoCaptureDevice unlockForConfiguration];
  }
}


#pragma mark - IBAction Methods

- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)takePicture:(id)sender
{
  self.cameraButton.enabled = YES;
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
      }
    }
  ];
}

@end
