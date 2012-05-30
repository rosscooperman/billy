//
//  BLAppDelegate.m
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLAppDelegate.h"
#import "BLViewController.h"


@implementation BLAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;


#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];  
  self.viewController = [[BLViewController alloc] initWithNibName:@"BLViewController" bundle:nil];
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  return YES;
}

@end
