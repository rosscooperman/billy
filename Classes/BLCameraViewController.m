//
//  BLCameraViewController.m
//  billy
//
//  Created by Ross Cooperman on 5/31/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLCameraViewController.h"


@implementation BLCameraViewController

@synthesize previewView;


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
  [UIApplication sharedApplication].statusBarHidden = YES;
}


- (void)viewWillDisappear:(BOOL)animated
{
  [UIApplication sharedApplication].statusBarHidden = NO;
}


#pragma mark - IBAction Methods

- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)takePicture:(id)sender
{
  
}

@end
