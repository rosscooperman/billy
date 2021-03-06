//
//  Bill.h
//  billy
//
//  Created by Ross Cooperman on 7/13/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class LineItem, Person;

@interface Bill : NSManagedObject

@property (nonatomic) double tax;
@property (nonatomic) double tip;
@property (nonatomic) int64_t splitCount;
@property (nonatomic) BOOL sendFeedback;
@property (nonatomic) BOOL feedbackSent;
@property (nonatomic, retain) NSString *rawText;
@property (nonatomic, retain) NSString *originalImage;
@property (nonatomic, retain) NSString *processedImage;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSSet *people;
@property (nonatomic, retain) NSSet *lineItems;

@property (readonly) double subtotal;
@property (readonly) double total;
@property (nonatomic, assign) double taxPercentage;
@property (nonatomic, assign) double tipPercentage;


- (void)storeOriginalImage:(NSData *)imageData;
- (void)storeProcessedImage:(NSData *)imageData;
- (NSArray *)sortedPeople;
- (BOOL)validateLineItems;

@end


@interface Bill (CoreDataGeneratedAccessors)

- (void)addPeopleObject:(Person *)value;
- (void)removePeopleObject:(Person *)value;
- (void)addPeople:(NSSet *)values;
- (void)removePeople:(NSSet *)values;

- (void)addLineItemsObject:(LineItem *)value;
- (void)removeLineItemsObject:(LineItem *)value;
- (void)addLineItems:(NSSet *)values;
- (void)removeLineItems:(NSSet *)values;

@end
