//
//  DiskCache.m
//  ETAsyncableImageView
//
//  Created by sah-fueled on 04/06/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "DiskCache.h"
#import "MemoryCache.h"

#ifdef DEBUG
#define CACHE_LONGEVITY 86400
#else
#define CACHE_LONGEVITY 86400  // DO NOT EDIT
#endif

#define DISK_LIMIT 2*1024*1024 

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
        [self checkAndDumpDiskMemory];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarningNotification:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification object:[UIApplication sharedApplication]];
    }
    
    return self;
}

-(void)didReceiveMemoryWarningNotification:(NSNotification *)notification {
    
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
    
    NSURL *cacheFileURL = [[self asyncableCachesDirectory] URLByAppendingPathComponent:key];
    NSError *error = nil;
    [data writeToURL:cacheFileURL options:0 error:&error];
    [self checkAndDumpDiskMemory];
    if (data) {
        [[MemoryCache sharedCache] setCache:data forKey:key];
    }

}

-(NSData *)getCacheForKey:(NSString *)key {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSURL *cacheFileURL = [[self asyncableCachesDirectory] URLByAppendingPathComponent:key];
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
    
    
    NSLog(@"ASYNCABLE: Cached files after purge: %d", [caches count]);
}

#pragma mark - Memory dumping methods
 
- (unsigned long long int) diskCacheFolderSize {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [[cachePaths objectAtIndex:0] stringByAppendingString:@"/Asyncable"];
    
    NSString *cacheFilePath;
    NSError *error;
    unsigned long long int cacheFolderSize = 0;
    
    NSArray *cacheFileList = [manager subpathsAtPath:cacheDirectory];
    NSLog(@"Cached file list ----- %@", cacheFileList);
    NSEnumerator *cacheEnumerator = [cacheFileList objectEnumerator];
    while (cacheFilePath = [cacheEnumerator nextObject]) {
        NSDictionary *cacheFileAttributes = [manager attributesOfItemAtPath:
                                            [cacheDirectory stringByAppendingPathComponent:cacheFilePath] error:&error];
        cacheFolderSize += [cacheFileAttributes fileSize];
    }
    return cacheFolderSize;
}

- (void)checkAndDumpDiskMemory {
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [[cachePaths objectAtIndex:0] stringByAppendingString:@"/Asyncable"];
    if ([self diskCacheFolderSize] > DISK_LIMIT) {
        NSArray *cacheFileList = [manager subpathsAtPath:cacheDirectory];
        
        NSString *prefix = @"/";
        NSString *fileName = [prefix stringByAppendingString:[cacheFileList objectAtIndex:1]];
        NSString *filePath = [cacheDirectory stringByAppendingString:fileName];
        
        [manager removeItemAtPath:filePath error:&error];
        
        [self checkAndDumpDiskMemory];
    }
    else {
        return;
    }
}

@end
