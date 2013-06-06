//
//  AsyncableImageLoader.m
//  ETAsyncableImageView
//
//  Created by sah-fueled on 06/06/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "AsyncableImageLoader.h"
#import "DiskCache.h"
#import "NSString+MD5.h"
#import "ImageDownloader.h"
#import "QueueManager.h"

#define kIMAGE_DOWNLOADED @"IMAGE_DOWNLOADED"
#define kIMAGE_DOWNLOAD_FAILED @"IMAGE_DOWNLOAD_FAILED"

typedef enum {
    AsyncableImageTypeUnknown = -1,
    AsyncableImageTypeJPEG,
    AsyncableImageTypePNG
} AsyncableImageType;

typedef enum {
    DataSourceTypeMemoryCache = 0,
    DataSourceTypeDiskCache,
    DataSourceTypeServer
} DataSourceType;

@interface AsyncableImageLoader()<ImageDownloaderDelegate>

@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, strong) DiskCache *diskCache;

@end

@implementation AsyncableImageLoader

+(AsyncableImageLoader *) sharedLoader{

    static dispatch_once_t predicate;
    __strong static AsyncableImageLoader *sharedLoader = nil;
    
    dispatch_once(&predicate, ^{
        sharedLoader = [[AsyncableImageLoader alloc] init];
    });
    
	return sharedLoader;

}

-(id)init
{
    self = [super init];
    if(self){
      
          self.memoryCache = [[NSCache alloc]init];
          self.downloadQueue = [[NSOperationQueue alloc] init];
            NSLog(@"memory cache = %@",self.memoryCache);
            NSLog(@"queue = %@",self.downloadQueue);
    
    }
    return self;
}

- (UIImage *)loadImageWithURL:(NSString *)URL ForImageView:(UIImageView *)imageView {
    for(int i = DataSourceTypeMemoryCache; i <= DataSourceTypeServer; i++ )
    {
        self.image = [self fetchImageFromDataSource:i withURL:URL ForImageView:imageView];
        if(self.image) break;
    }
    return self.image;
}

#pragma mark - Private methods

- (UIImage *)fetchImageFromDataSource:(DataSourceType)dataSource
                              withURL:(NSString*)url
                         ForImageView:(UIImageView *)imageView {
    
    UIImage *image;
    if (dataSource == DataSourceTypeMemoryCache) {
//        self.image = [UIImage imageWithData:[[MemoryCache sharedCache] getCacheForKey:[url MD5]]];
        image = [UIImage imageWithData:[self.memoryCache objectForKey:[url MD5]]];
    }
    else if(dataSource == DataSourceTypeDiskCache){
        
        NSData *data = [[DiskCache sharedCache] getCacheForKey:[url MD5]];
        image = [UIImage imageWithData:data];
        if (data) {
            [self.memoryCache setObject:data forKey:[url  MD5]];
        }

    }
    else {
        [self startImageDownloadingFromURL:url ForImageView:imageView];
//        image = [UIImage imageWithData:[self.memoryCache objectForKey:[url MD5]]];
    }
    return image;
}

-(AsyncableImageType)imageTypeForJTDynamicImageURL:(NSURL *)url {
    AsyncableImageType  imageType;
    NSError *error = nil;
    NSRegularExpression *jpegRegEx = [NSRegularExpression regularExpressionWithPattern:@".*\\.(jpg|jpeg)"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
    
    NSRegularExpression *pngRegEx = [NSRegularExpression regularExpressionWithPattern:@".*\\.png"
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:&error];
    
    NSString *absoluteUrlString = [url absoluteString];
    NSRange fullRange = NSRangeFromString([NSString stringWithFormat:@"0,%d", [absoluteUrlString length]]);
    
    if ([jpegRegEx numberOfMatchesInString:absoluteUrlString options:0 range:fullRange] > 0) {
        imageType = AsyncableImageTypeJPEG;
    }
    if ([pngRegEx numberOfMatchesInString:absoluteUrlString options:0 range:fullRange] > 0) {
        imageType = AsyncableImageTypePNG;
    }
    return imageType;
}
#pragma mark - NSOperation Methods
//
//- (NSOperationQueue *)downloadQueue {
//    QueueManager * queueManager = [QueueManager sharedInstance];
//    NSOperationQueue *globalQueue = queueManager.globalQueue;
//    return globalQueue;
//}

- (void)startImageDownloadingFromURL:(NSString *)url ForImageView:(UIImageView *)imageView {
    ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithURL:url
                                                                  imageView:imageView
                                                                   delegate:self];
    [self.downloadQueue addOperation:imageDownloader];
    NSLog(@"queue = %@",self.downloadQueue);
    NSLog(@"queue count:  %i",[self.downloadQueue operationCount]);
//    NSLog(@"url: %@",url);
}

#pragma mark - ImageDownloaderDelegate method

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    self.image = downloader.image;
    NSString * notificationName;
    if (self.image) {
        notificationName = kIMAGE_DOWNLOADED;
    }
    else {
        notificationName = kIMAGE_DOWNLOAD_FAILED;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
//    NSLog(@"self.image =  %@",self.image);
    [self storeImage:downloader.image withURL:downloader.url];
}

- (void)storeImage:(UIImage *)image withURL:(NSString *)url{
    
    NSData *imageData = nil;
    
    if ([self imageTypeForJTDynamicImageURL:[NSURL URLWithString:url]] == AsyncableImageTypeJPEG) {
        imageData = UIImageJPEGRepresentation(image, 1);
    } else {
        imageData = UIImagePNGRepresentation(image);
    }
    [[DiskCache sharedCache] setCache:imageData forKey:[url MD5]];
    if(imageData)
          [self.memoryCache setObject:imageData forKey:[url MD5]];

}


@end
