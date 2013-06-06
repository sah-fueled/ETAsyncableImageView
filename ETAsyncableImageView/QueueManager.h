//
//  QueueManager.h
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/6/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueueManager : NSObject

@property (nonatomic) NSOperationQueue *globalQueue;

+ (QueueManager *)sharedInstance;

@end
