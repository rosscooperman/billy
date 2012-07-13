//
//  LineItem.h
//  billy
//
//  Created by Ross Cooperman on 7/13/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class Assignment, Bill;

@interface LineItem : NSManagedObject

@property (nonatomic) int64_t quantity;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic) double price;
@property (nonatomic, retain) Bill *bill;
@property (nonatomic, retain) NSSet *assignments;
@property (nonatomic) int64_t index;
@property (nonatomic) BOOL deleted;

@end


@interface LineItem (CoreDataGeneratedAccessors)

- (void)addAssignmentsObject:(Assignment *)value;
- (void)removeAssignmentsObject:(Assignment *)value;
- (void)addAssignments:(NSSet *)values;
- (void)removeAssignments:(NSSet *)values;

@end
