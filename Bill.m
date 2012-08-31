//
//  Bill.m
//  billy
//
//  Created by Ross Cooperman on 7/13/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "Bill.h"
#import "LineItem.h"
#import "Person.h"


@implementation Bill

@dynamic subtotal;
@dynamic tax;
@dynamic tip;
@dynamic total;
@dynamic splitCount;
@dynamic rawText;
@dynamic createdAt;
@dynamic people;
@dynamic lineItems;
@dynamic sendFeedback;
@dynamic feedbackSent;

@end
