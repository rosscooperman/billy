//
//  BLStartViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/22/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLStartViewController.h"
#import "BLSplitCountViewController.h"


//#import "BLSummaryViewController.h"
//#import "Bill.h"
//#import "LineItem.h"
//#import "Person.h"
//#import "Assignment.h"

@implementation BLStartViewController


#pragma mark - View Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
  BLSplitCountViewController *countController = [[BLSplitCountViewController alloc] init];
  [self.navigationController pushViewController:countController animated:YES];
}


- (void)viewDidDisappear:(BOOL)animated
{
  self.navigationController.viewControllers = [self.navigationController.viewControllers subarrayWithRange:NSMakeRange(1, 1)];
}

@end
