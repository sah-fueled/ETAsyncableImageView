//
//  DiskCache.m
//  ETAsyncableImageView
//
//  Created by sah-fueled on 04/06/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "DiskCache.h"

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
    NSString *directoryName = @"Caches";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,NSUserDomainMask, YES);
    
    NSString *applicationDirectory = [paths objectAtIndex:0];
    NSString *filePathAndDirectory = [applicationDirectory stringByAppendingPathComponent:directoryName];
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error])
    {
        NSLog(@"Create directory error: %@", error);
    }
}

-(void)setCache:(id)obj forKey:(NSString *)key {
    
        
}

-(id)getCacheForKey:(NSString *)key {
    
        
}

@end
