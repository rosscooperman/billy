//
//  BLSplitBillViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/2/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define TEXT_BOX_HEIGHT 45
#define QUANTITY_BOX_WIDTH 45
#define NAME_BOX_WIDTH 193
#define PRICE_BOX_WIDTH 72


#import "BLSplitBillViewController.h"


@interface BLSplitBillViewController ()

@property (nonatomic, assign) NSInteger totalQuantity;
@property (nonatomic, assign) NSInteger assignedQuantity;


- (void)generateLineItems;
- (UIView *)generateViewForLineItem:(NSDictionary *)data atIndex:(NSInteger)index;
- (UILabel *)generateLineItemLabel;

@end


@implementation BLSplitBillViewController

@synthesize contentArea;
@synthesize nextScreenButton;
@synthesize totalQuantity;
@synthesize assignedQuantity;


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
  [self generateLineItems];
}


#pragma mark - Instance Methods

- (void)generateLineItems
{
  [self.contentArea.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
    [subview removeFromSuperview];
  }];
  
  NSArray *lineItems = [BLAppDelegate appDelegate].lineItems;
  [lineItems enumerateObjectsUsingBlock:^(NSDictionary *lineItem, NSUInteger idx, BOOL *stop) {
    [self.contentArea addSubview:[self generateViewForLineItem:lineItem atIndex:idx]];
    self.totalQuantity += [[lineItem objectForKey:@"quantity"] integerValue];
  }];
  
  self.contentArea.contentSize = CGSizeMake(320, ((TEXT_BOX_HEIGHT + 2) * lineItems.count) + 8);
  self.contentArea.contentInset = UIEdgeInsetsMake(0.0, 0.0, 75.0, 0.0);
}


- (UIView *)generateViewForLineItem:(NSDictionary *)lineItem atIndex:(NSInteger)index
{
  // create the wrapper that will surround all of the text fields
  CGRect frame = CGRectMake(5, 25 + ((TEXT_BOX_HEIGHT + 2) * index), 310, TEXT_BOX_HEIGHT);
  UIView *wrapper = [[UIView alloc] initWithFrame:frame];
  wrapper.tag = index;
  
  // generate the quantity text field
  UILabel *quantity = [self generateLineItemLabel];
  quantity.frame = CGRectMake(5, 0, QUANTITY_BOX_WIDTH, TEXT_BOX_HEIGHT);
  quantity.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
  quantity.text = [[lineItem objectForKey:@"quantity"] stringValue];
  [wrapper addSubview:quantity];
  
  // generate the name text field
  UILabel *name = [self generateLineItemLabel];
  name.frame = CGRectMake(5 + QUANTITY_BOX_WIDTH, 0, NAME_BOX_WIDTH, TEXT_BOX_HEIGHT);
  name.text = [[lineItem objectForKey:@"name"] uppercaseString];
  name.textAlignment = UITextAlignmentLeft;
  [wrapper addSubview:name];
  
  // generate the price field
  UILabel *price = [self generateLineItemLabel];
  price.frame = CGRectMake(5 + QUANTITY_BOX_WIDTH + NAME_BOX_WIDTH, 0, PRICE_BOX_WIDTH, TEXT_BOX_HEIGHT);
  price.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
  price.text = [NSString stringWithFormat:@"$%.2f", [[lineItem objectForKey:@"price"] floatValue]];
  [wrapper addSubview:price];
    
  return wrapper;
}


- (UILabel *)generateLineItemLabel
{
  UILabel *label = [[UILabel alloc] init];
  label.backgroundColor = [UIColor colorWithWhite:0.88627451 alpha:1.0];
  label.textColor = [UIColor blackColor];
  label.font = [UIFont fontWithName:@"Futura-Medium" size:16];
  label.textAlignment = UITextAlignmentCenter;
  return label;
}


#pragma mark - IBAction Methods

- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)nextScreen:(id)sender
{

}

@end
