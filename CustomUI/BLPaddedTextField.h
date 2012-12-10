//
//  BLPaddedTextView.h
//  billy
//
//  Created by Ross Cooperman on 11/9/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Person;


@interface BLPaddedTextField : UITextField

@property (nonatomic, strong) Person *person;


- (id)initWithPerson:(Person *)aPerson;

@end
