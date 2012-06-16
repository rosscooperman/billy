//
//  BLTipViewController.h
//  billy
//
//  Created by Ross Cooperman on 6/16/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BLTipViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *percentLabel;
@property (nonatomic, strong) IBOutlet UILabel *amountLabel;
@property (nonatomic, strong) IBOutlet UIButton *minusButton;
@property (nonatomic, strong) IBOutlet UIButton *plusButton;


- (IBAction)incrementPercentage:(id)sender;
- (IBAction)decrementPercentage:(id)sender;
- (IBAction)nextScreen:(id)sender;
- (IBAction)previousScreen:(id)sender;
- (IBAction)handleIncrementLongPress:(UILongPressGestureRecognizer *)recognizer;
- (IBAction)handleDecrementLongPress:(UILongPressGestureRecognizer *)recognizer;


@end
