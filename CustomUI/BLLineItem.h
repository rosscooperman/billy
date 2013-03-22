//
//  BLLineItem.h
//  billy
//
//  Created by Ross Cooperman on 2/22/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LineItem.h"


@interface BLLineItem : UIControl

@property (nonatomic, strong) LineItem *lineItem;
@property (nonatomic, assign) NSUInteger index;


- (id)initWithLineItem:(LineItem *)lineItem atIndex:(NSUInteger)index;
- (void)updateCompletionStatus;

@end
