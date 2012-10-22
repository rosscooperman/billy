//
//  BLStartViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/22/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLStartViewController.h"
#import "BLSplitCountViewController.h"


@interface BLStartViewController ()

@property (nonatomic, assign) BOOL coverShown;


- (void)curlPage;

@end


@implementation BLStartViewController

@synthesize coverShown;


#pragma mark - View Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
  // make sure we do one successful save of the managed object context before the app can proceed
  //while (![[BLAppDelegate appDelegate].managedObjectContext save:nil]) { }
  
  if (!self.coverShown) {
    self.coverShown = YES;
    
    BLSplitCountViewController *secondStart = [[BLSplitCountViewController alloc] init];
    secondStart.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self.navigationController presentViewController:secondStart animated:YES completion:^{
      //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
      //[self performSelector:@selector(curlPage) withObject:nil afterDelay:0.1];
    }];
  }
  
//  BLSplitCountViewController *countController = [[BLSplitCountViewController alloc] init];
//  [self.navigationController pushViewController:countController animated:YES];
}


- (void)viewDidDisappear:(BOOL)animated
{
  //self.navigationController.viewControllers = [self.navigationController.viewControllers subarrayWithRange:NSMakeRange(1, 1)];
  //[self.navigationController dismissModalViewControllerAnimated:YES];
}


#pragma mark - Instance Methods

- (void)curlPage
{
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
