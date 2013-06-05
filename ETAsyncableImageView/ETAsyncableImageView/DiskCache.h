//
//  DiskCache.h
//  ETAsyncableImageView
//
//  Created by sah-fueled on 04/06/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiskCache : NSObject

+(DiskCache *) sharedCache;

-(void)setCache:(NSData *)data forKey:(NSString *)key;

-(NSData *)getCacheForKey:(NSString *)key;

- (unsigned long long int) diskCacheFolderSize;

@end
