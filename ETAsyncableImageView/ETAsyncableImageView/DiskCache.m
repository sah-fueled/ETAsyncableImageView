//
//  DiskCache.m
//  ETAsyncableImageView
//
//  Created by sah-fueled on 04/06/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "DiskCache.h"
#import "NSString+MD5.h"

@implementation DiskCache

+(DiskCache*) sharedCache{
    static dispatch_once_t predicate;
    __strong static DiskCache *sharedCache = nil;
    
    dispatch_once(&predicate, ^{
        sharedCache = [[DiskCache alloc] init];
    });
    
	return sharedCache;
}

-(id)init {
    
    self = [super init];
    
    if (self) {
        [self createCacheDirectory];
    }
    
    return self;
}

-(void)createCacheDirectory{
    NSError *error;
    if(![[NSFileManager defaultManager]createDirectoryAtURL:[self asyncableCachesDirectory]
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&error]){
        NSLog(@"Create directory error: %@", error);
        
    }
}

-(void)setCache:(NSData*)data forKey:(NSString *)key {
    
    NSURL *cacheFileURL = [[self asyncableCachesDirectory] URLByAppendingPathComponent:[key MD5]];
    NSError *error = nil;
    [data writeToURL:cacheFileURL options:0 error:&error];
}

-(NSData *)getCacheForKey:(NSString *)key {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *urlHash = [key MD5];
    NSURL *cacheFileURL = [[self asyncableCachesDirectory] URLByAppendingPathComponent:urlHash];
    
    return [fileManager contentsAtPath:[cacheFileURL path]];
    
//    return [UIImage imageWithData:[fileManager contentsAtPath:[cacheFileURL path]]];
}

-(NSURL *)asyncableCachesDirectory {
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory
                                                           inDomains:NSUserDomainMask];
    if ([urls count] > 0) {
        return [[urls objectAtIndex:0] URLByAppendingPathComponent:@"Asyncable"];
        
    }
    else {
        return nil;
    }
}


@end
