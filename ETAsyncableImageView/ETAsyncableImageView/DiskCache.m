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
#define CACHE_LONGEVITY 86400  
#endif

#define DISK_LIMIT 15*1024*1024 

@interface DiskCache ()

@property (nonatomic)FileDeletionType fileDeletionType;

@end

@implementation DiskCache

+(DiskCache *) sharedCache {
  
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
        [[NSNotificationCenter defaultCenter]
                            addObserver:self
                               selector:@selector(didReceiveMemoryWarningNotification:)
                                   name:UIApplicationDidReceiveMemoryWarningNotification
                                 object:[UIApplication sharedApplication]];
    }
    return self;
}

-(void)didReceiveMemoryWarningNotification:(NSNotification *)notification {
  NSError *error;
  NSFileManager *manager = [NSFileManager defaultManager];
  NSArray *cacheFileList = [manager subpathsAtPath:[self cacheDirectoryPath]];
  
  for (int i = 1; i < [cacheFileList count]; i++) {
    NSString *prefix = @"/";
    NSString *fileName = [prefix stringByAppendingString:[cacheFileList objectAtIndex:i]];
    NSString *filePath = [[self cacheDirectoryPath] stringByAppendingString:fileName];
    [manager removeItemAtPath:filePath error:&error];
  }
  
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

- (void)getImageForKey:(NSString *)key forView:(UIImageView *)imageView {
  imageView.image = [UIImage imageWithData:[self getCacheForKey:key]];
}


-(NSData *)getCacheForKey:(NSString *)key {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *cacheFileURL = [[self asyncableCachesDirectory] URLByAppendingPathComponent:key];
    NSData *data = [fileManager contentsAtPath:[cacheFileURL path]];
    if(data)
       [[MemoryCache sharedCache] setCache: data forKey:key];
    return data;
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

- (void)setFileDeletionType:(FileDeletionType) deletionType {
  _fileDeletionType = deletionType;
}

-(void)clearStaleCaches {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSArray *caches = [fileManager
                       contentsOfDirectoryAtURL:[self asyncableCachesDirectory]
                     includingPropertiesForKeys:[NSArray arrayWithObject:NSURLContentModificationDateKey]
                                        options:0
                                          error:&error];
    
  for (NSURL *cacheURL in caches) {
      if (fabs([[[fileManager attributesOfItemAtPath:[cacheURL path] error:&error]
                 fileModificationDate] timeIntervalSinceNow]) > CACHE_LONGEVITY) {
            [fileManager removeItemAtURL:cacheURL error:&error];
      }
    }
    caches = [fileManager contentsOfDirectoryAtURL:[self asyncableCachesDirectory]
                        includingPropertiesForKeys:[NSArray arrayWithObject:NSURLContentModificationDateKey]
                                           options:0
                                             error:&error];
}

#pragma mark - Memory dumping methods
 
- (unsigned long long int) diskCacheFolderSize {
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *cacheFilePath;
    unsigned long long int cacheFolderSize = 0;
    NSArray *cacheFileList = [manager subpathsAtPath:[self cacheDirectoryPath]];
    NSEnumerator *cacheEnumerator = [cacheFileList objectEnumerator];
  
    while (cacheFilePath = [cacheEnumerator nextObject]) {
        NSDictionary *cacheFileAttributes = [manager attributesOfItemAtPath:
                                            [[self cacheDirectoryPath]stringByAppendingPathComponent:cacheFilePath] error:&error];
        cacheFolderSize += [cacheFileAttributes fileSize];
    }
    return cacheFolderSize;
}

- (void)checkAndDumpDiskMemory {
  if ([self diskCacheFolderSize] > DISK_LIMIT) {
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSMutableDictionary *fileWithsize = [[NSMutableDictionary alloc] init];
    NSString *cacheFilePath;
    NSDate *fileModificationDate;
    unsigned long long int fileSize;
    
    NSArray *cacheFileList = [manager subpathsAtPath:[self cacheDirectoryPath]];
    NSEnumerator *cacheEnumerator = [cacheFileList objectEnumerator];
    
    while (cacheFilePath = [cacheEnumerator nextObject]) {
      NSMutableDictionary *cacheFileAttributes = (NSMutableDictionary *)[manager attributesOfItemAtPath:
                                           [[self cacheDirectoryPath]stringByAppendingPathComponent:cacheFilePath] error:&error];
      if (self.fileDeletionType == FileDeletionTypeTime) {
        fileModificationDate = [cacheFileAttributes fileModificationDate];
        [fileWithsize setValue:fileModificationDate forKey:cacheFilePath];
      }
      else {
        fileSize = [cacheFileAttributes fileSize];
        NSNumber *size = [NSNumber numberWithUnsignedLongLong:fileSize];
        [fileWithsize setValue:size forKey:cacheFilePath];
      }
    }
    NSArray * sortedKeys = [fileWithsize keysSortedByValueUsingSelector:@selector(compare:)];
    
    NSString *prefix = @"/";
    NSString *fileName;
    if (self.fileDeletionType == FileDeletionTypeTime) {
       fileName = [prefix stringByAppendingString:[sortedKeys objectAtIndex:1]];
    }
    else {
       fileName = [prefix stringByAppendingString:[sortedKeys objectAtIndex:[sortedKeys count] - 1]];
    }
    NSString *filePath = [[self cacheDirectoryPath] stringByAppendingString:fileName];
   [manager removeItemAtPath:filePath error:&error];
   [self checkAndDumpDiskMemory];
 }
 else {
    return;
  }
}

- (NSString *)cacheDirectoryPath {
   NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
   NSString *cacheDirectory = [[cachePaths objectAtIndex:0] stringByAppendingString:@"/Asyncable"];
   return cacheDirectory;
}

@end
