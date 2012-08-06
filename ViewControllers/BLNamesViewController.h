//
//  BLNamesViewController.h
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLNamesViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *contentArea;
@property (nonatomic, strong) IBOutlet UIButton *nextScreenButton;


- (IBAction)nextScreen:(id)sender;
- (IBAction)previousScreen:(id)sender;
- (IBAction)contentAreaTapped:(UITapGestureRecognizer *)recognizer;


@end
