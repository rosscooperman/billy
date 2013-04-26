//
//  Bill.m
//  billy
//
//  Created by Ross Cooperman on 7/13/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "Bill.h"
#import "LineItem.h"
#import "Person.h"
#import "Assignment.h"
#import "BLFeedback.h"


@interface Bill ()

@property (nonatomic, strong) NSData *originalData;
@property (nonatomic, strong) NSData *processedData;
@property (readonly) NSArray *mostCommonNames;

@end


@implementation Bill
{
  int64_t _splitCount;
  NSString *_rawText;
}

@dynamic tax;
@dynamic tip;
@dynamic sendFeedback;
@dynamic feedbackSent;
@dynamic originalImage;
@dynamic processedImage;
@dynamic createdAt;
@dynamic people;
@dynamic lineItems;

@synthesize originalData;
@synthesize processedData;
@synthesize taxPercentage = _taxPercentage;
@synthesize tipPercentage = _tipPercentage;


#pragma mark - Core Data Lifecycle

- (void)awakeFromInsert
{
  if (self.lineItems.count == 0) {
    LineItem *lineItem = [NSEntityDescription insertNewObjectForEntityForName:@"LineItem" inManagedObjectContext:self.managedObjectContext];
    lineItem.index = 0;
    [self addLineItemsObject:lineItem];
    [self.managedObjectContext save:nil];
  }
  
  [super awakeFromInsert];
}


#pragma mark - Property Implementations

- (void)setSplitCount:(int64_t)splitCount
{
  [self willChangeValueForKey:@"splitCount"];
  
  _splitCount = splitCount;
  NSArray *commonNames = nil;
  if (self.people.count < splitCount) commonNames = [self mostCommonNames];
  
  // create people to compensate for any shortfall in people objects
  for (NSInteger i = self.people.count; i < splitCount; i++) {
    Person *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
    if (commonNames.count > i) person.name = [[[commonNames objectAtIndex:i] objectForKey:@"name"] capitalizedString];
    person.index = i;
    [self addPeopleObject:person];
  }
  
  // remove people to compensate for any overage in people objects
  for (NSInteger i = splitCount + 1; i <= self.people.count; i++) {
    Person *toRemove = [self.sortedPeople objectAtIndex:i - 1];
    [self removePeopleObject:toRemove];
    [self.managedObjectContext deleteObject:toRemove];
  }
  
  [self.managedObjectContext save:nil];
  [self didChangeValueForKey:@"splitCount"];
}


- (int64_t)splitCount
{
  [self willAccessValueForKey:@"splitCount"];
  int64_t response = _splitCount;
  [self didAccessValueForKey:@"splitCount"];
  return response;
}


- (void)setRawText:(NSString *)rawText
{
  [self willChangeValueForKey:@"rawText"];
  
  _rawText = [NSString stringWithString:rawText];
  
  if (_rawText.length > 0) {
    NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines;
    NSString *pattern = @"^\\s*([\\dlIOS]+)\\s+(.*)?\\s+\\$?([\\dlIOS]+[-.·][\\dlIOS]{2})\\s*$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:nil];
    NSRange range = [_rawText rangeOfString:_rawText];
      
    if ([regex numberOfMatchesInString:_rawText options:0 range:range] > 0) {
      [self.lineItems enumerateObjectsUsingBlock:^(LineItem *lineItem, BOOL *stop) {
        [self.managedObjectContext deleteObject:lineItem];
      }];
    }
        
    __block NSUInteger count = 0;
    [regex enumerateMatchesInString:_rawText options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
      // create a new line item with a description
      LineItem *lineItem = [NSEntityDescription insertNewObjectForEntityForName:@"LineItem" inManagedObjectContext:self.managedObjectContext];
      lineItem.index = count++;
      lineItem.desc = [_rawText substringWithRange:[result rangeAtIndex:2]];
      
      // tweak and set the new line item's quantity
      NSString *quantity = [[_rawText substringWithRange:[result rangeAtIndex:1]] stringByReplacingOccurrencesOfString:@"l" withString:@"1"];
      quantity = [quantity uppercaseString];
      quantity = [quantity stringByReplacingOccurrencesOfString:@"I" withString:@"1"];
      quantity = [quantity stringByReplacingOccurrencesOfString:@"O" withString:@"0"];
      quantity = [quantity stringByReplacingOccurrencesOfString:@"S" withString:@"5"];
      lineItem.quantity = quantity.longLongValue;
      
      // tweak and set the line item's price
      NSString *price = [[_rawText substringWithRange:[result rangeAtIndex:3]] stringByReplacingOccurrencesOfString:@"l" withString:@"1"];
      price = [price uppercaseString];
      price = [price stringByReplacingOccurrencesOfString:@"I" withString:@"1"];
      price = [price stringByReplacingOccurrencesOfString:@"O" withString:@"0"];
      price = [price stringByReplacingOccurrencesOfString:@"S" withString:@"5"];
      price = [price stringByReplacingOccurrencesOfString:@"-" withString:@"."];
      price = [price stringByReplacingOccurrencesOfString:@"·" withString:@"."];
      lineItem.price = price.doubleValue;
      
      [self addLineItemsObject:lineItem];
    }];
    
    [self.managedObjectContext save:nil];
  }
  
  [self didChangeValueForKey:@"rawText"];
}


- (NSString *)rawText
{
  [self willAccessValueForKey:@"rawText"];
  NSString *response = (_rawText) ? [NSString stringWithString:_rawText] : nil;
  [self didAccessValueForKey:@"rawText"];
  return response;
}


- (double)subtotal
{
  __block double subtotal = 0.0f;
  [self.lineItems enumerateObjectsUsingBlock:^(LineItem *lineItem, BOOL *stop) {
    subtotal += lineItem.price;
  }];
  return subtotal;
}


- (double)total
{
  return self.subtotal + self.tax + self.tip;
}


- (double)taxPercentage
{
  if (_taxPercentage) return _taxPercentage;
  
  if (self.tax) {
    _taxPercentage = self.tax / self.subtotal;
  }
  else if (self.rawText.length > 0) {
    NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines;
    
    NSString *pattern = @"[1tl]ax.+\\$?(\\d+\\.\\d{2})";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:nil];
    
    NSTextCheckingResult *result = nil;
    NSRange range = [self.rawText rangeOfString:self.rawText];
    result = [regex firstMatchInString:self.rawText options:0 range:range];
    
    if (result && result.range.length > 0) {
      double amount = [[self.rawText substringWithRange:[result rangeAtIndex:1]] floatValue];
      if (amount > 0.0) {
        self.tax = amount;
        _taxPercentage = self.tax / self.subtotal;
        [self.managedObjectContext save:nil];
      }
    }
  }
  
  // 6% just seems to be about the average sales tax nationwide...if we get here without finding a tax percentage default to that
  if (!_taxPercentage) self.taxPercentage = 0.06;
  return _taxPercentage;
}


- (double)tipPercentage
{
  if (_tipPercentage) return _tipPercentage;
  
  if (self.tip) {
    _tipPercentage = self.tip / (self.subtotal + self.tax);
  }
  
  // encourage people to leave 20% ;)
  if (!_tipPercentage) self.tipPercentage = 0.2;
  return _tipPercentage;
}


- (void)setTaxPercentage:(double)taxPercentage
{
  _taxPercentage = taxPercentage;
  self.tax = self.subtotal * _taxPercentage;
  self.tip = (self.subtotal + self.tax) * _tipPercentage;
  [self.managedObjectContext save:nil];
}


- (void)setTipPercentage:(double)tipPercentage
{
  _tipPercentage = tipPercentage;
  self.tip = (self.subtotal + self.tax) * _tipPercentage;
  [self.managedObjectContext save:nil];
}


#pragma mark - Instance Methods

- (void)storeOriginalImage:(NSData *)imageData
{
  self.originalData = imageData;
  [BLFeedback storeImageFile:@"original" data:self.originalData complete:^(NSString *filename) {
    [BLAppDelegate appDelegate].currentBill.originalImage = filename;
    [[BLAppDelegate appDelegate].managedObjectContext save:nil];
    self.originalData = nil;
  }];  
}


- (void)storeProcessedImage:(NSData *)imageData
{
  self.processedData = imageData;
  [BLFeedback storeImageFile:@"processed" data:self.processedData complete:^(NSString *filename) {
    [BLAppDelegate appDelegate].currentBill.processedImage = filename;
    [[BLAppDelegate appDelegate].managedObjectContext save:nil];
    self.processedData = nil;
  }];
}


- (NSArray *)sortedPeople
{
  NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
  return [self.people sortedArrayUsingDescriptors:descriptors];
}


- (NSArray *)mostCommonNames
{
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
  NSEntityDescription *personEntity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
  NSAttributeDescription *nameAttribute = [personEntity.attributesByName objectForKey:@"name"];

  NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"index"];
  NSExpression *countExpression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:keyPathExpression]];
  
  NSExpressionDescription *countExpressionDescription = [[NSExpressionDescription alloc] init];
  [countExpressionDescription setName:@"count"];
  [countExpressionDescription setExpression:countExpression];
  [countExpressionDescription setExpressionResultType:NSInteger64AttributeType];
  
  [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:nameAttribute, countExpressionDescription, nil]];
  [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:nameAttribute]];
  [fetchRequest setResultType:NSDictionaryResultType];
  
  NSError *error = nil;
  NSArray *names = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  NSArray *filteredNames = [names filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name.length > 0"]];
  return [filteredNames sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]];
}


- (BOOL)validateLineItems
{
  __block BOOL validated = YES;
  [self.lineItems enumerateObjectsUsingBlock:^(LineItem *lineItem, BOOL *stop) {
    __block NSUInteger totalAssigned = 0;
    [lineItem.assignments enumerateObjectsUsingBlock:^(Assignment *assignment, BOOL *stop) {
      totalAssigned += assignment.quantity;
    }];
    
    if (lineItem.price > 0 && totalAssigned < lineItem.quantity) {
      validated = NO;
      *stop = YES;
    }
  }];
  return validated;
}

@end
