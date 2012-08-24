//
//  BLStartViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/22/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLStartViewController.h"
#import "BLSplitCountViewController.h"


//#import "BLSummaryViewController.h"
//#import "Bill.h"
//#import "LineItem.h"
//#import "Person.h"
//#import "Assignment.h"

@implementation BLStartViewController


#pragma mark - View Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
  BLSplitCountViewController *countController = [[BLSplitCountViewController alloc] init];
//  
//  Bill *bill = [BLAppDelegate appDelegate].currentBill;
//  
//  NSManagedObjectContext *context = [BLAppDelegate appDelegate].managedObjectContext;
//  NSEntityDescription *entity = [NSEntityDescription entityForName:@"LineItem" inManagedObjectContext:context];
//  NSMutableSet *lineItems = [[NSMutableSet alloc] initWithCapacity:2];
//  NSMutableSet *people = [[NSMutableSet alloc] initWithCapacity:bill.splitCount];
//  
//  LineItem *firstItem = [[LineItem alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
//  firstItem.quantity = 2;
//  firstItem.desc = @"FIRST ITEM";
//  firstItem.price = 10.50;
//  [lineItems addObject:firstItem];
//  
//  LineItem *secondItem = [[LineItem alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
//  secondItem.quantity = 2;
//  secondItem.desc = @"SECOND ITEM";
//  secondItem.price = 22.95;
//  [lineItems addObject:secondItem];
//  
//  NSEntityDescription *personEntity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context];
//  NSEntityDescription *assnEntity = [NSEntityDescription entityForName:@"Assignment" inManagedObjectContext:context];
//  NSArray *names = [NSArray arrayWithObjects:@"ROSS", @"BRETT", nil];
//  for (int i = 0; i < bill.splitCount; i++) {
//    Person *person = [[Person alloc] initWithEntity:personEntity insertIntoManagedObjectContext:context];
//    person.name = [names objectAtIndex:i];
//    person.index = i;
//    [people addObject:person];
//    
//    Assignment *assignment = [[Assignment alloc] initWithEntity:assnEntity insertIntoManagedObjectContext:context];
//    assignment.person = person;
//    assignment.quantity = 1;
//    assignment.lineItem = firstItem;
//    
//    assignment = [[Assignment alloc] initWithEntity:assnEntity insertIntoManagedObjectContext:context];
//    assignment.person = person;
//    assignment.quantity = 1;
//    assignment.lineItem = secondItem;
//  }
//  
//  [bill addLineItems:lineItems];
//  [bill addPeople:people];
//  bill.tip = 25.0;
//  bill.tax = 15.0;
//  bill.subtotal = 33.45;
//  bill.total = 73.45;
//  [context save:nil];
//  
//  BLSummaryViewController *countController = [[BLSummaryViewController alloc] init];
  
  [self.navigationController pushViewController:countController animated:YES];
}


- (void)viewDidDisappear:(BOOL)animated
{
  self.navigationController.viewControllers = [self.navigationController.viewControllers subarrayWithRange:NSMakeRange(1, 1)];
}

@end
