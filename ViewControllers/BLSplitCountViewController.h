//
//  BLSplitCountViewController.h
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLViewController.h"


@interface BLSplitCountViewController : BLViewController

@property (nonatomic, strong) IBOutlet UILabel *countLabel;
@property (nonatomic, strong) IBOutlet UIView *controlView;
@property (nonatomic, strong) IBOutlet UIButton *minusButton;
@property (nonatomic, strong) IBOutlet UIButton *plusButton;
@property (nonatomic, strong) IBOutlet UIButton *nextScreenButton;
@property (nonatomic, strong) IBOutlet UIView *realView;


- (IBAction)incrementCount:(id)sender;
- (IBAction)decrementCount:(id)sender;
- (IBAction)nextScreen:(id)sender;

@end
