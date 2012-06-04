//
//  BLSplitCountViewController.h
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLSplitCountViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *countLabel;
@property (nonatomic, strong) IBOutlet UIButton *minusButton;
@property (nonatomic, strong) IBOutlet UIButton *plusButton;


- (IBAction)incrementCount:(id)sender;
- (IBAction)decrementCount:(id)sender;
- (IBAction)nextScreen:(id)sender;

@end
