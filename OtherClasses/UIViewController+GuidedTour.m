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
- (void)showTourTextLeft:(NSMutableArray *)text atPoint:(CGPoint)point animated:(BOOL)animated;
- (void)showTourTextRight:(NSMutableArray *)text atPoint:(CGPoint)point animated:(BOOL)animated;
- (void)animateShowComplete:(void (^)(void))complete;
- (void)animateHideComplete:(void (^)(void))complete;

@end


@implementation UIViewController (GuidedTour)

#pragma mark - Instance Methods

- (NSString *)tourKey
{
  return [NSStringFromClass([self class]) stringByAppendingString:@"_Tour"];
}


- (BOOL)shouldShowTour
{
  return false;
  //return ![[NSUserDefaults standardUserDefaults] boolForKey:self.tourKey];
}


- (void)markTourShown
{
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.tourKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)showTourText:(NSString *)text atPoint:(CGPoint)point animated:(BOOL)animated
{
  // temporarily? remove tour text entirely
  return;
  
  if (![self shouldShowTour]) return;
  NSMutableArray *splitText = [[text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
  
  if (point.x < 160.0) {
    [self showTourTextLeft:splitText atPoint:point animated:animated];
  }
  else {
    
    [self showTourTextRight:splitText atPoint:point animated:animated];
  }  
}


- (void)hideTourTextAnimated:(BOOL)animated complete:(void (^)(void))complete
{
  CGFloat duration = (animated) ? TOUR_ANIMATION_DURATION : 0.0;
  UIView *nextView = [self.view viewWithTag:TOUR_TAG];
  
  [UIView animateWithDuration:duration animations:^{
    nextView.transform = CGAffineTransformMakeTranslation(-(nextView.frame.size.width + nextView.frame.origin.x), 0.0);
  } completion:^(BOOL finished) {
    [nextView removeFromSuperview];
    if ([self.view viewWithTag:TOUR_TAG]) {
      [self hideTourTextAnimated:animated complete:complete];
    }
    else if (complete) {
      complete();
    }
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


- (void)showTourTextLeft:(NSMutableArray *)text atPoint:(CGPoint)point animated:(BOOL)animated
{
  if (text.count <= 0) return;
  
  NSString *nextString = [text objectAtIndex:0];
  [text removeObjectAtIndex:0];
  
  UILabel *tourLabel = [self newTourLabelWithText:nextString];
  tourLabel.frame = (CGRect){point, tourLabel.frame.size};
  CGPoint nextPoint = CGPointMake(point.x, point.y + tourLabel.bounds.size.height + 2.0);
  [self.view addSubview:tourLabel];
  
  if (animated) {
    tourLabel.transform = CGAffineTransformMakeTranslation(-(tourLabel.frame.size.width + tourLabel.frame.origin.x), 0.0);
    [UIView animateWithDuration:TOUR_ANIMATION_DURATION animations:^{
      tourLabel.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
      [self showTourTextLeft:text atPoint:nextPoint animated:animated];
    }];
  }
  else {
    [self showTourTextLeft:text atPoint:nextPoint animated:animated];
  }
}


- (void)showTourTextRight:(NSMutableArray *)text atPoint:(CGPoint)point animated:(BOOL)animated
{
  if (text.count <= 0) return;
  
  NSString *nextString = [text objectAtIndex:text.count - 1];
  [text removeObjectAtIndex:text.count - 1];
  
  UILabel *tourLabel = [self newTourLabelWithText:nextString];
  tourLabel.frame = (CGRect){CGPointMake(point.x - tourLabel.frame.size.width, point.y - tourLabel.frame.size.height), tourLabel.frame.size};
  CGPoint nextPoint = CGPointMake(point.x, point.y - tourLabel.bounds.size.height - 2.0);
  [self.view addSubview:tourLabel];
  
  if (animated) {
    tourLabel.transform = CGAffineTransformMakeTranslation(tourLabel.frame.size.width + (320.0 - point.x), 0.0);;
    [UIView animateWithDuration:TOUR_ANIMATION_DURATION animations:^{
      tourLabel.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
      [self showTourTextRight:text atPoint:nextPoint animated:animated];
    }];
  }
  else {
    [self showTourTextRight:text atPoint:nextPoint animated:animated];
  }
}

@end
