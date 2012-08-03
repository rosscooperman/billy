//
//  UIViewController+GuidedTour.m
//  billy
//
//  Created by Ross Cooperman on 8/3/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "UIViewController+GuidedTour.h"


@interface UIViewController (GuidedTourPrivateMethods)

- (UILabel *)newTourLabelWithText:(NSString *)text;
- (void)showTourTextLeft:(NSString *)text atPoint:(CGPoint)point animated:(BOOL)animated;
- (void)showTourTextRight:(NSString *)text atPoint:(CGPoint)point animated:(BOOL)animated;

@end


@implementation UIViewController (GuidedTour)

#pragma mark - Instance Methods

- (NSString *)tourKey
{
  return [NSStringFromClass([self class]) stringByAppendingString:@"_Tour"];
}


- (BOOL)shouldShowTour
{
  return YES;
  //return ![[NSUserDefaults standardUserDefaults] boolForKey:self.tourKey];
}


- (void)markTourShown
{
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.tourKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)showTourText:(NSString *)text atPoint:(CGPoint)point animated:(BOOL)animated
{
  if (![self shouldShowTour]) return;
  
  if (point.x < 160.0) {
    [self showTourTextLeft:text atPoint:point animated:animated];
  }
  else {
    [self showTourTextRight:text atPoint:point animated:animated];
  }  
}


- (void)hideTourTextAnimated:(BOOL)animated complete:(void (^)(void))complete
{
  __block NSMutableArray *tourViews = [NSMutableArray arrayWithCapacity:3];
  CGFloat duration = (animated) ? TOUR_ANIMATION_DURATION : 0.0;
  
  [UIView animateWithDuration:duration animations:^{
    [self.view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
      if (subview.tag == TOUR_TAG) {
        subview.transform = CGAffineTransformMakeTranslation(-(subview.frame.size.width + subview.frame.origin.x), 0.0);
        [tourViews addObject:subview];
      }
    }];
  } completion:^(BOOL finished) {
    [tourViews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
      [subview removeFromSuperview];
    }];
    if (complete) complete();
  }];
}


#pragma mark - Private Instance Methods

- (UILabel *)newTourLabelWithText:(NSString *)text
{
  UILabel *tourLabel = [[UILabel alloc] init];
  tourLabel.tag = TOUR_TAG;
  tourLabel.lineBreakMode = UILineBreakModeWordWrap;
  tourLabel.numberOfLines = 0;
  tourLabel.textAlignment = UITextAlignmentCenter;
  tourLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:20.0];
  tourLabel.textColor = [UIColor blackColor];
  tourLabel.backgroundColor = [UIColor colorWithRed:0.79216 green:0.0 blue:0.85098 alpha:1.0];
  tourLabel.text = [text uppercaseString];
  [tourLabel sizeToFit];
  tourLabel.frame = CGRectInset(tourLabel.frame, -10.0, -6.0);
  return tourLabel;
}


- (void)showTourTextLeft:(NSString *)text atPoint:(CGPoint)point animated:(BOOL)animated
{
  UILabel *tourLabel = [self newTourLabelWithText:text];
  tourLabel.frame = (CGRect){point, tourLabel.frame.size};
  [self.view addSubview:tourLabel];
  
  if (animated) {
    tourLabel.transform = CGAffineTransformMakeTranslation(-(tourLabel.frame.size.width + tourLabel.frame.origin.x), 0.0);
    [UIView animateWithDuration:TOUR_ANIMATION_DURATION animations:^{
      tourLabel.transform = CGAffineTransformIdentity;
    }];
  }
}


- (void)showTourTextRight:(NSString *)text atPoint:(CGPoint)point animated:(BOOL)animated
{
  UILabel *tourLabel = [self newTourLabelWithText:text];
  tourLabel.frame = (CGRect){CGPointMake(point.x - tourLabel.frame.size.width, point.y), tourLabel.frame.size};
  [self.view addSubview:tourLabel];
  
  if (animated) {
    tourLabel.transform = CGAffineTransformMakeTranslation(tourLabel.frame.size.width + (320.0 - point.x), 0.0);
    [UIView animateWithDuration:TOUR_ANIMATION_DURATION animations:^{
      tourLabel.transform = CGAffineTransformIdentity;
    }];
  }}

@end
