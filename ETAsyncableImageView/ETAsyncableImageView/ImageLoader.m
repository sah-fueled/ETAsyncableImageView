
//
//  ImageLoader.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "ImageLoader.h"
#import "DiskCache.h"
#import "MemoryCache.h"
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


@interface ImageLoader () <ImageDownloaderDelegate>

@property (nonatomic, strong) NSOperationQueue *downloadQueue;

- (UIImage *)fetchImageFromDataSource:(DataSourceType) dataSource withURL:(NSString*)url
                                                             ForImageView:(UIImageView *)imageView;
- (void)storeImage:(UIImage*)image withURL:(NSString*)url;
- (void)startImageDownloadingFromURL:(NSString *)url ForImageView:(UIImageView *)imageView;


@end

@implementation ImageLoader

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
  
    if (dataSource == DataSourceTypeMemoryCache) {
        self.image = [UIImage imageWithData:[[MemoryCache sharedCache] getCacheForKey:[url MD5]]];
    }
    else if(dataSource == DataSourceTypeDiskCache){
        self.image = [UIImage imageWithData:[[DiskCache sharedCache] getCacheForKey:[url MD5]]];
    }
    else {
        [self startImageDownloadingFromURL:url ForImageView:imageView];
    }
    return self.image;
}

-(AsyncableImageType)imageTypeForJTDynamicImageURL:(NSURL *)url {
    AsyncableImageType * imageType;
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

- (void)storeImage:(UIImage *)image withURL:(NSString *)url{
    
    NSData *imageData = nil;
  
    if ([self imageTypeForJTDynamicImageURL:[NSURL URLWithString:url]] == AsyncableImageTypeJPEG) {
        imageData = UIImageJPEGRepresentation(image, 1);
    } else {
        imageData = UIImagePNGRepresentation(image);
    }
    [[DiskCache sharedCache] setCache:imageData forKey:[url MD5]];
}

#pragma mark - NSOperation Methods

- (NSOperationQueue *)downloadQueue {
    QueueManager * queueManager = [QueueManager sharedInstance];
    NSOperationQueue *globalQueue = queueManager.globalQueue;
    return globalQueue;
}

- (void)startImageDownloadingFromURL:(NSString *)url ForImageView:(UIImageView *)imageView {
    ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithURL:url
                                                                   delegate:self];
    [self.downloadQueue addOperation:imageDownloader];
  NSLog(@"queue count ==> %i", [self.downloadQueue operationCount]);
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
   [self storeImage:self.image withURL:downloader.url];
}

@end
