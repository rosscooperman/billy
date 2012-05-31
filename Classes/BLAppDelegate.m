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


- (void)setDefaultNames;

@end


@implementation BLAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize splitCount = _splitCount;
@synthesize colors;


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


#pragma mark - Property Implementations

- (void)setSplitCount:(NSInteger)splitCount
{
  if (splitCount >= 2 && splitCount <= 8) _splitCount = splitCount;
}

@end
