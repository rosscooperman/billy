//
//  BLSplitAdjuster.h
//  billy
//
//  Created by Ross Cooperman on 2/22/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bill.h"
#import "BLSplitAdjusterPerson.h"


@interface BLSplitAdjuster : UIView <BLSplitAdjusterPersonDelegate>

@property (nonatomic, strong) Bill *bill;
@property (nonatomic, strong) LineItem *lineItem;


- (id)initWithBill:(Bill *)theBill;

@end
