//
//  BLEditableLineItem.h
//  billy
//
//  Created by Ross Cooperman on 12/21/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>


@class LineItem;

@interface BLEditableLineItem : UIView <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (readonly) BOOL isActive;


- (id)initWithLineItem:(LineItem *)lineItem;

@end
