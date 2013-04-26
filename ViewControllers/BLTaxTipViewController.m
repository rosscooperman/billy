//
//  BLTaxViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/11/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLTaxTipViewController.h"
#import "BLSummaryViewController.h"
#import "Bill.h"
#import "LineItem.h"
#import "Assignment.h"


@interface BLTaxTipViewController ()

@property (nonatomic, strong) Bill *bill;

@end


@implementation BLTaxTipViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  self.bill = [BLAppDelegate appDelegate].currentBill;
  
  self.taxPicker.increment = 0.00005f;
  self.subTotal.amount = self.bill.subtotal;
  self.taxPicker.percentage = self.bill.taxPercentage;
  self.tipPicker.percentage = self.bill.tipPercentage;
}


#pragma mark - IBAction Methods

- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)nextScreen:(id)sender
{
  BLSummaryViewController *summaryController = [[BLSummaryViewController alloc] init];
  [self.navigationController pushViewController:summaryController animated:YES];
}


#pragma mark - BLPercentPickerDelegate Methods

- (void)percentageChanged:(BLPercentPicker *)picker
{
  if (picker == self.taxPicker) {
    self.bill.taxPercentage = picker.percentage;
  }
  else if (picker == self.tipPicker) {
    self.bill.tipPercentage = picker.percentage;
  }
  self.taxAmount.amount = self.bill.tax;
  self.tipAmount.amount = self.bill.tip;
  self.totalAmount.amount = self.bill.total;
}

@end
