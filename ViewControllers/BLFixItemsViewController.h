//
//  BLFixItemsViewController.h
//  billy
//
//  Created by Ross Cooperman on 6/1/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BLFixItemsViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *contentArea;
@property (nonatomic, strong) IBOutlet UIButton *nextScreenButton;
@property (nonatomic, strong) IBOutlet UIButton *previousScreenButton;
@property (nonatomic, strong) IBOutlet UIButton *addLineItemButton;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapRecognizer;


- (IBAction)contentAreaTapped:(UITapGestureRecognizer *)recognizer;
- (IBAction)previousScreen:(id)sender;
- (IBAction)acceptChanges:(id)sender;
- (IBAction)addRow:(id)sender;

@end
