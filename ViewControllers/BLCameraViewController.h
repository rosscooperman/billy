//
//  BLCameraViewController.h
//  billy
//
//  Created by Ross Cooperman on 5/31/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface BLCameraViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *previewView;
@property (nonatomic, strong) IBOutlet UIView *mask;
@property (nonatomic, strong) IBOutlet UIButton *cameraButton;


- (IBAction)previousScreen:(id)sender;
- (IBAction)takePicture:(id)sender;

@end
