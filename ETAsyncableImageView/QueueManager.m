//
//  QueueManager.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/6/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "QueueManager.h"

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
    self.globalQueue = [[NSOperationQueue alloc] init];
    }
  return self;
}

@end
