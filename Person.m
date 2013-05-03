//
//  Person.m
//  billy
//
//  Created by Ross Cooperman on 7/13/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "Person.h"
#import "Assignment.h"
#import "Bill.h"
#import "LineItem.h"


@implementation Person

@dynamic name;
@dynamic bill;
@dynamic assignments;
@dynamic index;


#pragma mark - Property Implementations

- (double)amountOwed
{
  __block double amount = 0.0f;
  [self.assignments enumerateObjectsUsingBlock:^(Assignment *assignment, BOOL *stop) {
    amount += ((double)assignment.quantity / (double)assignment.lineItem.quantity) * assignment.lineItem.price;
  }];
  
  double ratio = amount / self.bill.subtotal;
  amount += ratio * self.bill.tip;
  amount += ratio * self.bill.tax;
  
  return amount;
}

@end
