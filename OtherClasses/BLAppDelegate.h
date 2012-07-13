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

@interface BLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *viewController;
@property (assign, nonatomic) NSInteger splitCount;
@property (strong, nonatomic) NSString *rawText;
@property (assign, nonatomic) float taxAmount;
@property (assign, nonatomic) float tipAmount;
@property (readonly, strong, nonatomic) Bill *currentBill;

// core data properties
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


// class methods
+ (BLAppDelegate *)appDelegate;

// instance methods
- (UIColor *)colorAtIndex:(NSInteger)index;
- (NSString *)nameAtIndex:(NSInteger)index;
- (void)setName:(NSString *)name atIndex:(NSInteger)index;
- (NSArray *)lineItems;
- (void)setLineItems:(NSArray *)lineItems;

@end
