//
//  BLStartViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/22/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLStartViewController.h"
#import "BLSplitCountViewController.h"


#import "BLSplitBillViewController.h"
#import "Bill.h"
#import "LineItem.h"
#import "Person.h"

@implementation BLStartViewController


#pragma mark - View Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
  //BLSplitCountViewController *countController = [[BLSplitCountViewController alloc] init];
  
  Bill *bill = [BLAppDelegate appDelegate].currentBill;
  
  NSManagedObjectContext *context = [BLAppDelegate appDelegate].managedObjectContext;
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"LineItem" inManagedObjectContext:context];
  NSMutableSet *lineItems = [[NSMutableSet alloc] initWithCapacity:2];
  NSMutableSet *people = [[NSMutableSet alloc] initWithCapacity:bill.splitCount];
  
  LineItem *item = [[LineItem alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
  item.quantity = 1;
  item.desc = @"FIRST ITEM";
  item.price = 10.50;
  [lineItems addObject:item];
  
  item = [[LineItem alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
  item.quantity = 3;
  item.desc = @"SECOND ITEM";
  item.price = 22.95;
  [lineItems addObject:item];
  
  NSEntityDescription *personEntity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context];
  for (int i = 0; i < bill.splitCount; i++) {
    Person *person = [[Person alloc] initWithEntity:personEntity insertIntoManagedObjectContext:context];
    person.name = @"ROSS";
    person.index = i;
    [people addObject:person];
  }
  
  [bill addLineItems:lineItems];
  [bill addPeople:people];
  [context save:nil];
  
  BLSplitBillViewController *countController = [[BLSplitBillViewController alloc] init];
  
  [self.navigationController pushViewController:countController animated:YES];
}


- (void)viewDidDisappear:(BOOL)animated
{
  self.navigationController.viewControllers = [self.navigationController.viewControllers subarrayWithRange:NSMakeRange(1, 1)];
}

@end
