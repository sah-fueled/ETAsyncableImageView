//
//  ImageLoader.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "ImageLoader.h"
#import "MemoryCache.h"
#import "DiskCache.h"
#import "ImageDownloader.h"

@interface ImageLoader () <ImageDownloaderDelegate>

@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) UIImage *image;

- (void)fetchImageFromCacheWithURL:(NSString *)url ForView:(UIImageView *)imageView;
- (void)fetchImageFromDiskWithURL:(NSString *)url ForView:(UIImageView *)imageView;
- (void)fetchImageFromServerWithURL:(NSString *)url ForView:(UIImageView *)imageView;

- (void)startImageDownloadingFromURL:(NSString *)url ForView:(UIImageView *)imageView;

@end

@implementation ImageLoader

- (NSOperationQueue *)downloadQueue {
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.name = @"Image Downloader";
        _downloadQueue.maxConcurrentOperationCount = 10;
    }
    return _downloadQueue;
}

- (UIImage *)loadImageWithURL:(NSString *)URL forView:(UIImageView *)imageView {
    [self fetchImageFromCacheWithURL:URL ForView:imageView];
    if (self.image) {
        return self.image;
    }
    [self fetchImageFromDiskWithURL:URL ForView:imageView];
    if (self.image ) {
        return self.image ;
    }
    [self fetchImageFromServerWithURL:URL forView:imageView];
    return self.image ;
}

- (void)fetchImageFromCacheWithURL:(NSString *)url ForView:(UIImageView *)imageView {
    
}

- (void)fetchImageFromDiskWithURL:(NSString *)url ForView:(UIImageView *)imageView {
    
}

- (void)fetchImageFromServerWithURL:(NSString *)url forView:(UIImageView *)imageView {
    
    [self startImageDownloadingFromURL:url ForView:imageView];
    
    
}

- (void)startImageDownloadingFromURL:(NSString *)url ForView:(UIImageView *)imageView {
    ImageDownloader *imageDownloader = [[ImageDownloader alloc]initWithURL:url delegate:self];
    [self.downloadQueue addOperation:imageDownloader];
}

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    self.image = downloader.image;
     
}

@end
