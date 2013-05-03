//
//  BLSummaryViewController.m
//  billy
//
//  Created by Ross Cooperman on 6/17/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#define BOX_HEIGHT 45
#define NAME_BOX_WIDTH 220
#define PRICE_BOX_WIDTH 88


#import "BLSummaryViewController.h"
#import "BLPersonSummaryView.h"
#import "BLPersonBreakdownView.h"
#import "Bill.h"
#import "Person.h"

@interface BLSummaryViewController ()

@property (nonatomic, strong) Bill *bill;
@property (nonatomic, strong) NSMutableDictionary *summaryViews;
@property (nonatomic, strong) NSMutableDictionary *breakdownViews;


- (void)personViewTapped:(UITapGestureRecognizer *)recognizer;

@end


@implementation BLSummaryViewController

@synthesize contentArea;
@synthesize bill;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{  
  self.bill = [BLAppDelegate appDelegate].currentBill;
  [self.bill.sortedPeople enumerateObjectsUsingBlock:^(Person *person, NSUInteger idx, BOOL *stop) {
    BLPersonSummaryView *summaryView = [[BLPersonSummaryView alloc] initWithPerson:person];
    [self.contentArea addSubview:summaryView];
    [self.summaryViews setObject:summaryView forKey:person.objectID];
    
    BLPersonBreakdownView *breakdownView = [[BLPersonBreakdownView alloc] initWithPerson:person];
    [self.contentArea insertSubview:breakdownView atIndex:0];
    [self.breakdownViews setObject:breakdownView forKey:person.objectID];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(personViewTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [summaryView addGestureRecognizer:tapRecognizer];
    
    self.contentArea.contentSize = CGSizeMake(320.0f, CGRectGetMaxY(summaryView.frame));
  }];
}


#pragma mark - Property Implementations

- (NSMutableDictionary *)breakdownViews
{
  if (!_breakdownViews) {
    _breakdownViews = [NSMutableDictionary dictionaryWithCapacity:self.bill.people.count];
  }
  return _breakdownViews;
}


- (NSMutableDictionary *)summaryViews
{
  if (!_summaryViews) {
    _summaryViews = [NSMutableDictionary dictionaryWithCapacity:self.bill.people.count];
  }
  return _summaryViews;
}


#pragma mark - Action Methods

- (void)previousScreen:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)startOver:(id)sender
{
  NSString *message = @"Are you sure you want to start over?";
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
  [alert show];
}


- (void)personViewTapped:(UITapGestureRecognizer *)recognizer
{
  BLPersonSummaryView *summaryView = (BLPersonSummaryView *)recognizer.view;
  BLPersonBreakdownView *breakdownView = [self.breakdownViews objectForKey:summaryView.person.objectID];
  
  [UIView animateWithDuration:0.3 animations:^{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // if the breakdown view is already showing, set up a transform to hide it.  otherwise, show it.
    if (breakdownView.showing) {
      transform = CGAffineTransformMakeTranslation(0.0f, -breakdownView.frame.size.height);
      self.contentArea.contentSize = CGSizeMake(320.0f, self.contentArea.contentSize.height - breakdownView.frame.size.height);
      breakdownView.showing = NO;
    }
    else {
      transform = CGAffineTransformMakeTranslation(0.0f, breakdownView.frame.size.height);
      self.contentArea.contentSize = CGSizeMake(320.0f, self.contentArea.contentSize.height + breakdownView.frame.size.height);
      breakdownView.showing = YES;
    }
    
    // show/hide everything below the breakdown view as well
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index > %d", summaryView.person.index];
    [[self.bill.people filteredSetUsingPredicate:predicate] enumerateObjectsUsingBlock:^(Person *person, BOOL *stop) {
      BLPersonSummaryView *otherSummaryView = [self.summaryViews objectForKey:person.objectID];
      otherSummaryView.transform = CGAffineTransformConcat(otherSummaryView.transform, transform);

      BLPersonBreakdownView *otherBreakdownView = [self.breakdownViews objectForKey:person.objectID];
      otherBreakdownView.transform = CGAffineTransformConcat(otherBreakdownView.transform, transform);
    }];
    
    breakdownView.transform = CGAffineTransformConcat(breakdownView.transform, transform);
  }];
}


#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex > 0) [[BLAppDelegate appDelegate] startOver];
}

@end
