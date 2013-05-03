//
//  Person.h
//  billy
//
//  Created by Ross Cooperman on 7/13/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class Assignment, Bill;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) Bill *bill;
@property (nonatomic, retain) NSSet *assignments;
@property (nonatomic) int64_t index;
@property (readonly) double amountOwed;

@end


@interface Person (CoreDataGeneratedAccessors)

- (void)addAssignmentsObject:(Assignment *)value;
- (void)removeAssignmentsObject:(Assignment *)value;
- (void)addAssignments:(NSSet *)values;
- (void)removeAssignments:(NSSet *)values;

@end
