//
//  BLAppDelegate.m
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLAppDelegate.h"
#import "BLStartViewController.h"
#import "BLFixItemsViewController.h"


@interface BLAppDelegate ()

@property (nonatomic, strong) NSArray *colors;


- (void)setDefaultNames;

@end


@implementation BLAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize splitCount = _splitCount;
@synthesize colors;
@synthesize taxAmount;
@synthesize tipAmount;


#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // get TestFlight going
  [TestFlight takeOff:@"134067a92dbd350b70e07b40809e70ce_OTUyMTcyMDEyLTA1LTMwIDE5OjI5OjUxLjIyNjkzNg"];
  
  // every app deserves a window
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  // initialize application data
  self.splitCount = 2;
    
  // construct the only navigation controller we'll ever need
  self.viewController = [[UINavigationController alloc] initWithRootViewController:[[BLStartViewController alloc] init]];
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
    NSMutableArray *_colors = [[NSMutableArray alloc] initWithCapacity:9];
    [_colors addObject:[UIColor colorWithRed:0.858823529 green:0.956862745 blue:0.917647059 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.996078431 green:0.270588235 blue:0.262745098 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:1.000000000 green:0.556862745 blue:0.247058824 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:1.000000000 green:0.694117647 blue:0.003921569 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.772549020 green:0.964705882 blue:0.117647059 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.000000000 green:0.800000000 blue:0.294117647 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.360784314 green:0.898039216 blue:0.717647059 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.792156863 green:0.000000000 blue:0.850980392 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:1.000000000 green:0.082352941 blue:0.403921569 alpha:1.0]];
    self.colors = [NSArray arrayWithArray:_colors];
  }
  
  return (index < self.colors.count) ? [self.colors objectAtIndex:index] : [self.colors objectAtIndex:0];
}


- (void)setDefaultNames
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *names = [defaults arrayForKey:@"names"];
  if (!names) {
    [defaults setObject:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", nil] forKey:@"names"];
    [defaults synchronize];
  }
}


- (void)setName:(NSString *)name atIndex:(NSInteger)index
{
  [self setDefaultNames];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *names = [NSMutableArray arrayWithArray:[defaults arrayForKey:@"names"]];
  if (names.count > index) {
    [names replaceObjectAtIndex:index withObject:name];
    [defaults setObject:[NSArray arrayWithArray:names] forKey:@"names"];
    [defaults synchronize];
  }
}


- (NSString *)nameAtIndex:(NSInteger)index
{
  [self setDefaultNames];
  NSArray *names = [[NSUserDefaults standardUserDefaults] arrayForKey:@"names"];
  if (names.count > index) {
    return [names objectAtIndex:index];
  }
  return @"";
}


- (void)setLineItems:(NSArray *)lineItems
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:lineItems forKey:@"lineItems"];
  [defaults synchronize];
}


- (NSArray *)lineItems
{
  return [[NSUserDefaults standardUserDefaults] arrayForKey:@"lineItems"];
}


#pragma mark - Property Implementations

- (void)setSplitCount:(NSInteger)splitCount
{
  if (splitCount >= 2 && splitCount <= 8) _splitCount = splitCount;
}


- (NSString *)rawText
{
  return [[NSUserDefaults standardUserDefaults] stringForKey:@"rawText"];
}


- (void)setRawText:(NSString *)rawText
{
  [[NSUserDefaults standardUserDefaults] setValue:rawText forKey:@"rawText"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
