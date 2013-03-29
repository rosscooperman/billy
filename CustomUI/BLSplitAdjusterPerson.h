//
//  BLSplitAdjuster.h
//  billy
//
//  Created by Ross Cooperman on 2/22/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"


@protocol BLSplitAdjusterPersonDelegate <NSObject>

@required

// the person view needs to know the price of each unit quantity
- (float)unitPrice;

@optional

// expected to return YES when there is more quantity available, NO if not
- (void)quantityAdjustedFor:(Person *)person quantity:(NSUInteger)newQuantity;

@end


@class LineItem;


@interface BLSplitAdjusterPerson : UIView

@property (nonatomic, strong) Person *person;
@property (nonatomic, weak) id <BLSplitAdjusterPersonDelegate> delegate;
@property (nonatomic, assign) BOOL allowIncrementing;


- (id)initWithPerson:(Person *)thePerson;
- (void)updateQuantityBy:(NSInteger)amount;
- (void)setQuantityFor:(LineItem *)lineItem;

@end
