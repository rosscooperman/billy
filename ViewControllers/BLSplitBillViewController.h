//
//  BLSplitBillViewController.h
//  billy
//
//  Created by Ross Cooperman on 6/2/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLViewController.h"

@interface BLSplitBillViewController : BLViewController

@property (nonatomic, strong) IBOutlet UIScrollView *contentArea;
@property (nonatomic, strong) IBOutlet UIButton *nextScreenButton;


- (IBAction)nextScreen:(id)sender;
- (IBAction)previousScreen:(id)sender;

@end
