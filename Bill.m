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
#import "ASIFormDataRequest.h"


@interface Bill ()

@property (nonatomic, strong) NSData *originalData;
@property (nonatomic, strong) NSData *processedData;


- (void)storeImageFile:(NSString *)base data:(NSData *)data complete:(void (^)(NSString *filename))complete;

@end


@implementation Bill

@dynamic subtotal;
@dynamic tax;
@dynamic tip;
@dynamic total;
@dynamic splitCount;
@dynamic sendFeedback;
@dynamic feedbackSent;
@dynamic rawText;
@dynamic originalImage;
@dynamic processedImage;
@dynamic createdAt;
@dynamic people;
@dynamic lineItems;

@synthesize originalData;
@synthesize processedData;


#pragma mark - Class Methods

+ (void)processPendingFeedback
{
  NSManagedObjectContext *context = [BLAppDelegate appDelegate].managedObjectContext;
  
  // do all of this in another thread
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Bill"];
    request.predicate = [NSPredicate predicateWithFormat:@"sendFeedback == YES AND feedbackSent == NO"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    
    NSArray *results = [context executeFetchRequest:request error:nil];
    if (results && results.count > 0) {
      [results enumerateObjectsUsingBlock:^(Bill *bill, NSUInteger idx, BOOL *stop) {
        // shortcut actual upload because this bill has no useful data
        if (!bill.originalImage && !bill.processedImage && !bill.rawText) {
          bill.feedbackSent = YES;
          [context save:nil];
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
          
          [request setCompletionBlock:^{
            bill.feedbackSent = YES;
            [context save:nil];
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


#pragma mark - Instance Methods

- (void)storeOriginalImage:(NSData *)imageData
{
  self.originalData = imageData;
  [self storeImageFile:@"original" data:self.originalData complete:^(NSString *filename) {
    [BLAppDelegate appDelegate].currentBill.originalImage = filename;
    [[BLAppDelegate appDelegate].managedObjectContext save:nil];
    self.originalData = nil;
  }];  
}


- (void)storeProcessedImage:(NSData *)imageData
{
  self.processedData = imageData;
  [self storeImageFile:@"processed" data:self.processedData complete:^(NSString *filename) {
    [BLAppDelegate appDelegate].currentBill.processedImage = filename;
    [[BLAppDelegate appDelegate].managedObjectContext save:nil];
    self.processedData = nil;
  }];
}


- (void)storeImageFile:(NSString *)base data:(NSData *)data complete:(void (^)(NSString *filename))complete
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
