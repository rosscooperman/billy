//
//  BLTaxViewController.h
//  billy
//
//  Created by Ross Cooperman on 6/11/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLViewController.h"
#import "BLTextField.h"
#import "BLScrollView.h"
#import "BLSummaryView.h"
#import "BLPercentPicker.h"


@interface BLTaxTipViewController : BLViewController <BLPercentPickerDelegate>

@property (nonatomic, strong) IBOutlet BLScrollView *mainContent;
@property (nonatomic, strong) IBOutlet BLSummaryView *subTotal;
@property (nonatomic, strong) IBOutlet BLSummaryView *taxAmount;
@property (nonatomic, strong) IBOutlet BLSummaryView *tipAmount;
@property (nonatomic, strong) IBOutlet BLSummaryView *totalAmount;
@property (nonatomic, strong) IBOutlet BLPercentPicker *taxPicker;
@property (nonatomic, strong) IBOutlet BLPercentPicker *tipPicker;

@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *closeKeyboardRecognizer;


- (IBAction)nextScreen:(id)sender;
- (IBAction)previousScreen:(id)sender;

@end
