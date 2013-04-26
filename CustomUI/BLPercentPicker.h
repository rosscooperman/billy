//
//  BLPercentPicker.h
//  billy
//
//  Created by Ross Cooperman on 4/25/13.
//  Copyright (c) 2013 Eastmedia. All rights reserved.
//

#import "BLView.h"


@class BLPercentPicker;


@protocol BLPercentPickerDelegate <NSObject>

@optional

- (void)percentageChanged:(BLPercentPicker *)picker;

@end


@interface BLPercentPicker : BLView

@property (nonatomic, strong) NSString *label;
@property (nonatomic, assign) double percentage;
@property (nonatomic, assign) double increment;
@property (nonatomic, weak) IBOutlet id<BLPercentPickerDelegate> delegate;

@end
