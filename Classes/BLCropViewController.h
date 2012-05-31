//
//  BLCropViewController.h
//  billy
//
//  Created by Ross Cooperman on 5/31/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BLCropViewController : UIViewController

@property (nonatomic, strong) NSData *photoData;
@property (nonatomic, strong) IBOutlet UIImageView *previewView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;


- (IBAction)previousScreen:(id)sender;

@end
