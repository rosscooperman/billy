//
//  BLCropViewController.m
//  billy
//
//  Created by Ross Cooperman on 5/31/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLCropViewController.h"


@implementation BLCropViewController

@synthesize photoData;
@synthesize previewView;
@synthesize loadingIndicator;


#pragma mark - View Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
  if (self.photoData) {
    self.previewView.alpha = 0.0;
    self.previewView.image = [UIImage imageWithData:self.photoData];
    [UIView animateWithDuration:0.3 animations:^{
      self.previewView.alpha = 1.0;
    } completion:^(BOOL finished) {
      [self.loadingIndicator stopAnimating];
    }];
  }
}


#pragma mark - IBAction Methods

- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

@end
