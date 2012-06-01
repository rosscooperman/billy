//
//  BLCropViewController.h
//  billy
//
//  Created by Ross Cooperman on 5/31/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tesseract.h"


@interface BLCropViewController : UIViewController {
  TessBaseAPI *_tesseract;
}

@property (nonatomic, strong) NSData *photoData;
@property (nonatomic, strong) IBOutlet UIImageView *previewView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) IBOutlet UIView *cropBoundary;
@property (nonatomic, strong) IBOutlet UIButton *leftHandle;
@property (nonatomic, strong) IBOutlet UIButton *topHandle;
@property (nonatomic, strong) IBOutlet UIButton *rightHandle;
@property (nonatomic, strong) IBOutlet UIButton *bottomHandle;
@property (nonatomic, strong) IBOutlet UIButton *processImageButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *processingImageIndicator;


- (IBAction)previousScreen:(id)sender;
- (IBAction)dragHandle:(UIPanGestureRecognizer *)recognizer;
- (IBAction)processImage:(id)sender;

@end
