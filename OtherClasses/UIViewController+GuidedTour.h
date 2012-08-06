//
//  UIViewController+GuidedTour.h
//  billy
//
//  Created by Ross Cooperman on 8/3/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TOUR_TAG 54321
#define TOUR_ANIMATION_DURATION 0.25


@interface UIViewController (GuidedTour)

- (NSString *)tourKey;
- (BOOL)shouldShowTour;
- (void)markTourShown;
- (void)showTourText:(NSString *)text atPoint:(CGPoint)point animated:(BOOL)animated;
- (void)hideTourTextAnimated:(BOOL)animated complete:(void (^)(void))complete;

@end
