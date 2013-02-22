//
//  BLSplitAdjuster.h
//  billy
//
//  Created by Ross Cooperman on 2/22/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Bill.h"


@interface BLSplitAdjuster : UIView

@property (nonatomic, strong) Bill *bill;


- (id)initWithBill:(Bill *)theBill;

@end
