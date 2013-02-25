//
//  LineItem.m
//  billy
//
//  Created by Ross Cooperman on 7/13/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "LineItem.h"
#import "Assignment.h"
#import "Bill.h"
#import "Person.h"


@interface LineItem ()

- (Assignment *)assignmentFor:(Person *)person;

@end


@implementation LineItem

@dynamic quantity;
@dynamic desc;
@dynamic price;
@dynamic bill;
@dynamic assignments;
@dynamic index;
@dynamic deleted;


#pragma mark - Property Implementations

- (BOOL)isFullyAssigned
{
  return (self.totalAssignedQuantity >= self.quantity);
}


#pragma mark - Instance Methods

- (void)assignQuantity:(NSUInteger)quantity forPerson:(Person *)person
{
  Assignment *assignment = [self assignmentFor:person];
  assignment.quantity = quantity;
  [self.managedObjectContext save:nil];
}


- (NSUInteger)totalAssignedQuantity
{
  __block NSUInteger assignedCount = 0;
  [self.assignments enumerateObjectsUsingBlock:^(Assignment *assignment, BOOL *stop) {
    assignedCount += assignment.quantity;
  }];
  return assignedCount;
}


- (Assignment *)assignmentFor:(Person *)person
{
  __block Assignment *theAssignment = nil;
  [self.assignments enumerateObjectsUsingBlock:^(Assignment *assignment, BOOL *stop) {
    if (assignment.person == person) {
      theAssignment = assignment;
      *stop = YES;
    }
  }];
  
  if (!theAssignment) {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Assignment" inManagedObjectContext:self.managedObjectContext];
    theAssignment = [[Assignment alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    theAssignment.person = person;
    
    [self addAssignmentsObject:theAssignment];
  }
  
  return theAssignment;
}

@end
