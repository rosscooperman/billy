//
//  BLAppDelegate.h
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@class BLViewController, Bill;

@interface BLAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *viewController;
@property (readonly, strong, nonatomic) Bill *currentBill;
@property (readonly) BOOL shouldSendFeedback;

// core data properties
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


// class methods
+ (BLAppDelegate *)appDelegate;

// instance methods
- (UIColor *)colorAtIndex:(NSInteger)index;
- (void)startOver;

@end
