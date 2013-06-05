//
//  DiskCache.m
//  ETAsyncableImageView
//
//  Created by sah-fueled on 04/06/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "DiskCache.h"
#import "NSString+MD5.h"

#ifdef DEBUG
#define CACHE_LONGEVITY 86400
#else
#define CACHE_LONGEVITY 86400  // DO NOT EDIT
#endif

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
        [self clearStaleCaches];
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
    NSLog(@"urlhash => %@", urlHash);
    NSURL *cacheFileURL = [[self asyncableCachesDirectory] URLByAppendingPathComponent:urlHash];
    
    return [fileManager contentsAtPath:[cacheFileURL path]];
    
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

-(void)clearStaleCaches {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSArray *caches = [fileManager contentsOfDirectoryAtURL:[self asyncableCachesDirectory]
                                 includingPropertiesForKeys:[NSArray arrayWithObject:NSURLContentModificationDateKey]
                                                    options:0
                                                      error:&error];
    
    // remove any cache file older than CACHE_LONGEVITY
    NSLog(@"ASYNCABLE: Purging Asyncable cache. Cached files before purge: %i", [caches count]);
    for (NSURL *cacheURL in caches) {
        if (fabs([[[fileManager attributesOfItemAtPath:[cacheURL path] error:&error] fileModificationDate] timeIntervalSinceNow]) > CACHE_LONGEVITY) {
            [fileManager removeItemAtURL:cacheURL error:&error];
        }
    }
    
    caches = [fileManager contentsOfDirectoryAtURL:[self asyncableCachesDirectory]
                        includingPropertiesForKeys:[NSArray arrayWithObject:NSURLContentModificationDateKey]
                                           options:0
                                             error:&error];
    
    // remove any cache file older than CACHE_LONGEVITY
    NSLog(@"ASYNCABLE: Cached files after purge: %d", [caches count]);
}
 
- (unsigned long long int) diskCacheFolderSize {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [[cachePaths objectAtIndex:0] stringByAppendingString:@"/Asyncable"];
    NSArray *cacheFileList;
    NSEnumerator *cacheEnumerator;
    NSString *cacheFilePath;
    NSError *error;
    unsigned long long int cacheFolderSize = 0;
    
    cacheFileList = [manager subpathsAtPath:cacheDirectory];
    cacheEnumerator = [cacheFileList objectEnumerator];
    while (cacheFilePath = [cacheEnumerator nextObject]) {
        NSDictionary *cacheFileAttributes = [manager attributesOfItemAtPath:[cacheDirectory stringByAppendingPathComponent:cacheFilePath] error:&error];
        cacheFolderSize += [cacheFileAttributes fileSize];
    }
    
    return cacheFolderSize;
}

@end
