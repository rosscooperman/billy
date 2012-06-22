//
//  BLSummaryViewController.h
//  billy
//
//  Created by Ross Cooperman on 6/17/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BLSummaryViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *contentArea;


- (IBAction)previousScreen:(id)sender;
- (IBAction)startOver:(id)sender;

@end