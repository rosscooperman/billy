//
//  BLFixItemsViewController.h
//  billy
//
//  Created by Ross Cooperman on 6/1/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLViewController.h"


@class BLScrollView;

@interface BLFixItemsViewController : BLViewController

@property (nonatomic, strong) IBOutlet BLScrollView *contentArea;
@property (nonatomic, strong) IBOutlet UIButton *addLineItemButton;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapRecognizer;


- (IBAction)contentAreaTapped:(UITapGestureRecognizer *)recognizer;
- (IBAction)previousScreen:(id)sender;
- (IBAction)acceptChanges:(id)sender;
- (IBAction)addRow:(id)sender;

@end
