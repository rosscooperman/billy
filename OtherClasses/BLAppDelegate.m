//
//  BLAppDelegate.m
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLAppDelegate.h"
//#import "BLStartViewController.h"
#import "BLSplitCountViewController.h"
#import "Bill.h"


@interface BLAppDelegate ()

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *secondaryColors;
@property (nonatomic, strong) NSArray *tertiaryColors;

@end

@implementation BLAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize currentBill = _currentBill;
@synthesize colors;
@synthesize secondaryColors;
@synthesize tertiaryColors;


#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // get TestFlight going
  [TestFlight takeOff:@"134067a92dbd350b70e07b40809e70ce_OTUyMTcyMDEyLTA1LTMwIDE5OjI5OjUxLjIyNjkzNg"];
  
  // every app deserves a window
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  // construct the only navigation controller we'll ever need
  self.viewController = [[UINavigationController alloc] initWithRootViewController:[[BLSplitCountViewController alloc] init]];
  [self.viewController.navigationBar setBackgroundImage:[UIImage imageNamed:@"stdHead"] forBarMetrics:UIBarMetricsDefault];
  
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  return YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // don't care about the answer, just want to ask the user as early as possible
  [self shouldSendFeedback];
  [Bill processPendingFeedback];
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
    [_colors addObject:[UIColor lightGrayColor]];
    [_colors addObject:[UIColor colorWithRed:0.90588 green:0.92941 blue:0.95294 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.89020 green:0.87843 blue:0.93725 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.94902 green:0.89804 blue:0.94902 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.93333 green:0.87059 blue:0.87843 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.94902 green:0.91765 blue:0.89804 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.93333 green:0.90980 blue:0.86667 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.94510 green:0.94118 blue:0.89020 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.90980 green:0.92941 blue:0.86275 alpha:1.0]];
    self.colors = [NSArray arrayWithArray:_colors];
  }
  
  return (index < self.colors.count) ? [self.colors objectAtIndex:index] : [self.colors objectAtIndex:0];
}


- (UIColor *)secondaryColorAtIndex:(NSInteger)index
{
  if (!self.secondaryColors) {
    NSMutableArray *_colors = [[NSMutableArray alloc] initWithCapacity:9];
    [_colors addObject:[UIColor lightGrayColor]];
    [_colors addObject:[UIColor colorWithRed:0.85490 green:0.89020 blue:0.92549 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.84706 green:0.82745 blue:0.91373 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.92549 green:0.85098 blue:0.92549 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.90980 green:0.81961 blue:0.82745 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.92157 green:0.87451 blue:0.84314 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.90588 green:0.87451 blue:0.81569 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.91765 green:0.91373 blue:0.83922 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.87451 green:0.90196 blue:0.80784 alpha:1.0]];
    self.secondaryColors = [NSArray arrayWithArray:_colors];
  }
  
  return (index < self.secondaryColors.count) ? [self.secondaryColors objectAtIndex:index] : [self.secondaryColors objectAtIndex:0];
}


- (UIColor *)tertiaryColorAtIndex:(NSInteger)index
{
  if (!self.tertiaryColors) {
    NSMutableArray *_colors = [[NSMutableArray alloc] initWithCapacity:9];
    [_colors addObject:[UIColor lightGrayColor]];
    [_colors addObject:[UIColor colorWithRed:0.80784 green:0.85490 blue:0.90196 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.80000 green:0.78039 blue:0.89020 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.89804 green:0.80000 blue:0.89804 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.87059 green:0.74510 blue:0.75686 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.89804 green:0.83529 blue:0.79216 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.87843 green:0.83922 blue:0.76471 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.89020 green:0.88235 blue:0.78431 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:0.83922 green:0.87451 blue:0.75294 alpha:1.0]];
    self.tertiaryColors = [NSArray arrayWithArray:_colors];
  }
  
  return (index < self.tertiaryColors.count) ? [self.tertiaryColors objectAtIndex:index] : [self.tertiaryColors objectAtIndex:0];
}


- (void)startOver
{
  _currentBill = nil;
  [self.viewController popToRootViewControllerAnimated:YES];
}


- (void)askForRating
{
  // don't ask if we've already asked
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"askedForRating"]) return;
  
  // don't ask if the user has fewer than 3 bills with totals
  NSManagedObjectContext *context = [BLAppDelegate appDelegate].managedObjectContext;
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Bill"];
  request.predicate = [NSPredicate predicateWithFormat:@"total > 0.0"];
  request.includesSubentities = NO;
  NSUInteger completedBills = [context countForFetchRequest:request error:nil];
  if (completedBills < 3) return;
  
  // if we get here, time to ask for a rating
  NSString *message = @"Hey, seems like you've used Billy a few times. Mind giving it a rating in the App Store?";
  NSString *title = @"Rate Billy";
  
  UIAlertView *alert = nil;
  alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"No, Thanks" otherButtonTitles:@"Sure!", nil];
  alert.tag = 200;
  
  [alert show];
}


#pragma mark - Core Data Property Implementations

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
  if (_persistentStoreCoordinator == nil) {
    NSURL *directory = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [directory URLByAppendingPathComponent:@"billy.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:2];
    [options setValue:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setValue:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
      TFLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
  }
  
  return _persistentStoreCoordinator;
}


- (NSManagedObjectModel *)managedObjectModel
{
  if (_managedObjectModel == nil) {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"billy" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  }
  
  return _managedObjectModel;
}


- (NSManagedObjectContext *)managedObjectContext
{
  if (_managedObjectContext == nil) {
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
      _managedObjectContext = [[NSManagedObjectContext alloc] init];
      [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
  }

  return _managedObjectContext;
}


#pragma mark - Property Implementations

- (Bill *)currentBill
{
  if (!_currentBill) {
    _currentBill = [NSEntityDescription insertNewObjectForEntityForName:@"Bill" inManagedObjectContext:self.managedObjectContext];
    _currentBill.createdAt = [NSDate date];
    _currentBill.sendFeedback = NO;
    _currentBill.feedbackSent = NO;
    [self.managedObjectContext save:nil];
  }
  return _currentBill;
}


- (BOOL)shouldSendFeedback
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults objectForKey:@"shouldSendFeedback"] == nil) {
    NSString *message = @"Would you like to send anonymous usage data to help us improve Billy?";
    [[[UIAlertView alloc] initWithTitle:@"Feedback" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
  }
  
  return [defaults boolForKey:@"shouldSendFeedback"];
}


#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (alertView.tag == 200) {
    if (buttonIndex > 0) {
      NSString *reviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=538940070";
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"askedForRating"];
  }
  else {
    BOOL value = (buttonIndex > 0);
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:@"shouldSendFeedback"];    
    self.currentBill.sendFeedback = value;
    [self.managedObjectContext save:nil];
  }
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
