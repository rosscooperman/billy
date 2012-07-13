//
//  Assignment.h
//  billy
//
//  Created by Ross Cooperman on 7/13/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class LineItem, Person;

@interface Assignment : NSManagedObject

@property (nonatomic) int64_t quantity;
@property (nonatomic, retain) LineItem *lineItem;
@property (nonatomic, retain) Person *person;

@end
