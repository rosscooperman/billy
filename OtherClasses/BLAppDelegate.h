//
//  BLAppDelegate.h
//  billy
//
//  Created by Ross Cooperman on 5/30/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BLViewController;

@interface BLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *viewController;
@property (assign, nonatomic) NSInteger splitCount;
@property (strong, nonatomic) NSString *rawText;


// class methods
+ (BLAppDelegate *)appDelegate;

// instance methods
- (UIColor *)colorAtIndex:(NSInteger)index;
- (NSString *)nameAtIndex:(NSInteger)index;
- (void)setName:(NSString *)name atIndex:(NSInteger)index;
- (NSArray *)lineItems;
- (void)setLineItems:(NSArray *)lineItems;

@end
