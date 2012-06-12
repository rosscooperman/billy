//
//  BLTaxViewController.h
//  billy
//
//  Created by Ross Cooperman on 6/11/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLTextField.h"


@interface BLTaxViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UILabel *percentLabel;
@property (nonatomic, strong) IBOutlet BLTextField *amountField;
@property (nonatomic, strong) IBOutlet UIButton *minusButton;
@property (nonatomic, strong) IBOutlet UIButton *plusButton;


- (IBAction)incrementPercentage:(id)sender;
- (IBAction)decrementPercentage:(id)sender;
- (IBAction)nextScreen:(id)sender;
- (IBAction)previousScreen:(id)sender;

@end
