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
@property (nonatomic, retain) NSSet *bills;
@property (nonatomic, retain) NSSet *assignments;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addBillsObject:(Bill *)value;
- (void)removeBillsObject:(Bill *)value;
- (void)addBills:(NSSet *)values;
- (void)removeBills:(NSSet *)values;

- (void)addAssignmentsObject:(Assignment *)value;
- (void)removeAssignmentsObject:(Assignment *)value;
- (void)addAssignments:(NSSet *)values;
- (void)removeAssignments:(NSSet *)values;

@end
