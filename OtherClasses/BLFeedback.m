//
//  BLFeedback.m
//  billy
//
//  Created by Ross Cooperman on 11/9/12.
//  Copyright (c) 2012 Eastmedia. All rights reserved.
//

#import "BLFeedback.h"
#import "ASIFormDataRequest.h"
#import "Bill.h"


@implementation BLFeedback


#pragma mark - Class Methods

+ (void)processPendingFeedback
{
  // A BRIEF NOTE ABOUT WHAT'S GOING ON HERE
  //
  // Core Data is not 100% threadsafe so all actual Core Data operations need to happen on the main thread.
  // The more expensive image processing and uploading code should be on a low priority background thread, though.
  // The solution is to fetch feedback items that need to be sent, iterate over them in the background, and then
  // mark them as submitted on the main thread.
  
  NSManagedObjectContext *context = [BLAppDelegate appDelegate].managedObjectContext;
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Bill"];
  request.predicate = [NSPredicate predicateWithFormat:@"sendFeedback == YES AND feedbackSent == NO"];
  request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
  NSArray *results = [context executeFetchRequest:request error:nil];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    if (results && results.count > 0) {
      [results enumerateObjectsUsingBlock:^(Bill *bill, NSUInteger idx, BOOL *stop) {
        // shortcut actual upload because this bill has no useful data
        if (!bill.originalImage && !bill.processedImage && !bill.rawText) {
          dispatch_async(dispatch_get_main_queue(), ^{
            bill.feedbackSent = YES;
            [context save:nil];
          });
        }
        else {
          ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://feedback.billyup.com/feedback"]];
          
          if (bill.rawText) {
            [request setPostValue:bill.rawText forKey:@"feedback[raw_text]"];
          }
          if (bill.originalImage) {
            [request addFile:bill.originalImage withFileName:@"original.jpg" andContentType:@"image/jpeg" forKey:@"feedback[original]"];
          }
          if (bill.processedImage) {
            [request addFile:bill.processedImage withFileName:@"processed.jpg" andContentType:@"image/jpeg" forKey:@"feedback[processed]"];
          }
          
          // mark the beginning of a background task (uploading feedback)
          __block UIBackgroundTaskIdentifier bgTask = UIBackgroundTaskInvalid;
          bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [request cancel];
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
          }];
          
          [request setCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
              bill.feedbackSent = YES;
              [context save:nil];
              
              if (bgTask != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
              }
            });
          }];
          
          [request startAsynchronous];
        }
      }];
    }
    else if (results) {
      // since there are no bills to process feedback for, clear out any/all cached images
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
      if (paths.count > 0) {
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[paths objectAtIndex:0] error:nil];
        if (files) {
          [files enumerateObjectsUsingBlock:^(NSString *file, NSUInteger idx, BOOL *stop) {
            if ([file hasPrefix:@"original."] || [file hasPrefix:@"processed."]) {
              NSString *absoluteFilename = [[paths objectAtIndex:0] stringByAppendingPathComponent:file];
              [[NSFileManager defaultManager] removeItemAtPath:absoluteFilename error:nil];
            }
          }];
        }
      }
    }
  });
}


+ (void)storeImageFile:(NSString *)base data:(NSData *)data complete:(void (^)(NSString *filename))complete
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  if (paths.count > 0) {
    NSString *filenameComponent = [NSString stringWithFormat:@"%@.XXXXXX", base];
    NSString *filenameTemplate = [[paths objectAtIndex:0] stringByAppendingPathComponent:filenameComponent];
    
    char *filename = (char *)malloc(strlen(filenameTemplate.fileSystemRepresentation) + 1);
    strcpy(filename, filenameTemplate.fileSystemRepresentation);
    
    if (mkstemp(filename) != -1) {
      NSString *imagePath = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:filename length:strlen(filename)];
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if ([data writeToFile:imagePath atomically:YES] && complete) complete(imagePath);
      });
    }
  }
}

@end
