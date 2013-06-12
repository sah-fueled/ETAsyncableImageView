//
//  MemoryCache.m
//  ETAsyncableImageView
//
//  Created by sah-fueled on 04/06/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "MemoryCache.h"

@interface MemoryCache()

@property (nonatomic,strong) NSCache *cache;

@end

@implementation MemoryCache

+(MemoryCache *) sharedCache {
  
  static dispatch_once_t predicate;
  __strong static MemoryCache *sharedCache = nil;
  
  dispatch_once(&predicate, ^{
    sharedCache = [[MemoryCache alloc] init];
  });
  
	return sharedCache;
}

-(id)init {
  
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)getImageForKey:(NSString *)key forView:(UIImageView *)imageView {
   imageView.image  = [UIImage imageWithData:[self getCacheForKey:key]];
}

-(id)getCacheForKey:(NSString *)key {
    return [self.cache objectForKey:key];
  }

- (void)setCache:(NSData *)data forKey:(NSString *)key{
    [self.cache setObject:data forKey:key];
}

@end
