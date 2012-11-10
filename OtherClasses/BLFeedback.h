//
//  BLFeedback.h
//  billy
//
//  Created by Ross Cooperman on 11/9/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BLFeedback : NSObject

+ (void)processPendingFeedback;
+ (void)storeImageFile:(NSString *)base data:(NSData *)data complete:(void (^)(NSString *filename))complete;

@end
