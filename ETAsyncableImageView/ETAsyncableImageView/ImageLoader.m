
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

typedef enum {
    AsyncableImageTypeUnknown = -1,
    AsyncableImageTypeJPEG = 0,
    AsyncableImageTypePNG
} AsyncableImageType;

typedef enum {
    DataSourceTypeMemoryCache = 0,
    DataSourceTypeDiskCache,
    DataSourceTypeServer
} DataSourceType;


@interface ImageLoader () <ImageDownloaderDelegate>

@property (nonatomic, strong) NSOperationQueue *downloadQueue;


- (UIImage *)fetchImageFromDataSource:(DataSourceType) dataSource withURL:(NSString*)url ForImageView:(UIImageView *)imageView;
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
 
    switch (dataSource) {
        case DataSourceTypeMemoryCache:
            self.image = [UIImage imageWithData:[[MemoryCache sharedCache] getCacheForKey:url]];
            break;
        case DataSourceTypeDiskCache:
            self.image = [UIImage imageWithData:[[DiskCache sharedCache] getCacheForKey:url]];
            break;
        case DataSourceTypeServer:
            [self startImageDownloadingFromURL:url ForImageView:imageView];
            break;
            
        default:
            break;
    }
    
    return self.image;
}

-(AsyncableImageType)imageTypeForJTDynamicImageURL:(NSURL *)url {
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
        return AsyncableImageTypeJPEG;
    }
    if ([pngRegEx numberOfMatchesInString:absoluteUrlString options:0 range:fullRange] > 0) {
        return AsyncableImageTypePNG;
    }
    
    return AsyncableImageTypeUnknown;
    
    
}

- (void)storeImage:(UIImage *)image withURL:(NSString *)url{
    
    NSData *imageData = nil;
    
    switch ([self imageTypeForJTDynamicImageURL:[NSURL URLWithString:url]]) {
        case AsyncableImageTypeJPEG:
            imageData = UIImageJPEGRepresentation(image, 1);
            break;
        case AsyncableImageTypePNG:
            imageData = UIImagePNGRepresentation(image);
            break;
        default:
        	imageData = UIImagePNGRepresentation(image);
            break;
    }
    
    [[DiskCache sharedCache] setCache:imageData forKey:url];
}

#pragma mark - NSOperation Methods

- (NSOperationQueue *)downloadQueue {
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.name = @"Image Downloader";
        _downloadQueue.maxConcurrentOperationCount = 1;
    }
    return _downloadQueue;
}

- (void)startImageDownloadingFromURL:(NSString *)url ForImageView:(UIImageView *)imageView {
    ImageDownloader *imageDownloader = [[ImageDownloader alloc]initWithURL:url ImageView:imageView delegate:self];
    [self.downloadQueue addOperation:imageDownloader];
}

#pragma mark - ImageDownloaderDelegate method

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    self.image = downloader.image;
    NSLog(@"image = %@ %@",self.image,downloader.image);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IMAGE_DOWNLOADED" object:self];
     
}

@end
