//
//  BLPersonBreakdownView.h
//  billy
//
//  Created by Ross Cooperman on 5/3/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#import "BLView.h"


@class Person;

@interface BLPersonBreakdownView : BLView

@property (nonatomic, strong) Person *person;
@property (nonatomic, assign) BOOL showing;


- (id)initWithPerson:(Person *)person;

@end
