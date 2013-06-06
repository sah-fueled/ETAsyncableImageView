//
//  QueueManager.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/6/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "QueueManager.h"
#import "ImageDownloader.h"

@implementation QueueManager

+ (QueueManager *)sharedInstance {
  static QueueManager *sharedInstance = nil;
  static dispatch_once_t isDispatched;
  dispatch_once(&isDispatched, ^
                {
                sharedInstance = [[QueueManager alloc] init];
                });
  
  return sharedInstance;
}

- (id)init
{
  self = [super init];
  if (self)
    {
      _globalQueue = [[NSOperationQueue alloc] init];
      [_globalQueue setMaxConcurrentOperationCount:5];
       _downloadsInProgress = [[NSMutableArray alloc] init];
       _downloadsInWaiting = [[NSMutableArray alloc] init];
    }
  return self;
}

- (void)manageOperations {
  for (ImageDownloader *operation in self.downloadsInProgress) {
    if (!operation.imageView.window) {
      [operation cancel];
      [self.downloadsInWaiting addObject:operation];
    }
  }
  NSMutableArray *collecter = [[NSMutableArray alloc]initWithObjects:nil];
 
  
  NSLog(@"waiting count =========> %i", [self.downloadsInWaiting count]);
  for (ImageDownloader *waitingOperation in self.downloadsInWaiting) {
    if (waitingOperation.imageView.window) {
      for (ImageDownloader *opertion in self.globalQueue.operations) {
        if (waitingOperation == opertion) {
          [collecter addObject:waitingOperation];
        }
        else if (!waitingOperation.isExecuting && waitingOperation != opertion){
          [self.globalQueue addOperation:waitingOperation];
        }
      }
    }
  }
  [self.downloadsInWaiting removeObjectsInArray:collecter];
}

@end
