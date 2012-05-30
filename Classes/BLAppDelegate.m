//
//  BLAppDelegate.m
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLAppDelegate.h"
#import "BLSplitCountViewController.h"


@interface BLAppDelegate ()

@property (nonatomic, strong) NSArray *colors;

@end


@implementation BLAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize splitCount;
@synthesize colors;


#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // every app deserves a window
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  // construct the only navigation controller we'll ever need
  self.viewController = [[UINavigationController alloc] initWithRootViewController:[[BLSplitCountViewController alloc] init]];
  self.viewController.navigationBarHidden = YES;
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  return YES;
}


#pragma mark - Class Methods

+ (BLAppDelegate *)appDelegate
{
  return (BLAppDelegate *)[UIApplication sharedApplication].delegate;
}


#pragma mark - Instance Methods

- (UIColor *)colorAtIndex:(NSInteger)index
{
  if (!self.colors) {
    self.colors = [NSArray arrayWithObjects:
                    [UIColor darkGrayColor],
                    [UIColor colorWithRed:1.0 green:0.0 blue:0.321568627 alpha:1.0],
                    [UIColor colorWithRed:1.0 green:0.125490196 blue:0.0 alpha:1.0],
                    [UIColor colorWithRed:1.0 green:0.462745098 blue:0.0 alpha:1.0],
                    [UIColor colorWithRed:1.0 green:0.662745098 blue:0.0 alpha:1.0],
                    [UIColor colorWithRed:1.0 green:0.901960784 blue:0.0 alpha:1.0],
                    [UIColor colorWithRed:0.0 green:0.803921569 blue:0.294117647 alpha:1.0],
                    [UIColor colorWithRed:0.0 green:0.517647059 blue:0.803921569 alpha:1.0],
                    [UIColor colorWithRed:0.792156863 green:0.0 blue:0.850980392 alpha:1.0],
                  nil];
  }
  
  return (index < self.colors.count) ? [self.colors objectAtIndex:index] : [self.colors objectAtIndex:0];
}

@end
