
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
#import "UIImageView+Asyncable.h"

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
@property (nonatomic, strong) DiskCache *diskCache;
@property (nonatomic, strong) MemoryCache *memoryCache;

- (void)fetchImageFromDataSource:(DataSourceType) dataSource withURL:(NSString*)url
                                                             ForImageView:(UIImageView *)imageView;
- (void)storeImage:(UIImage*)image withURL:(NSString*)url;
- (void)startImageDownloadingFromURL:(NSString *)url ForImageView:(UIImageView *)imageView;


@end

@implementation ImageLoader

+(ImageLoader *)sharedInstance {
  static dispatch_once_t predicate;
  __strong static ImageLoader *sharedInstance = nil;
  
  dispatch_once(&predicate, ^{
    sharedInstance = [[ImageLoader alloc] init];
  });
  
	return sharedInstance;
}

- (id)init {
  self = [super init];
  if (self) {
    _diskCache = [[DiskCache alloc]init];
    _memoryCache = [[MemoryCache alloc] init];
    _diskCache.memoryCache = _memoryCache;
    _downloadQueue = [[NSOperationQueue alloc]init];
  }
  return  self;
}

- (UIImage *)fetchImageWithURL:(NSString *)URL ForImageView:(UIImageView *)imageView {
    for(int i = DataSourceTypeMemoryCache; i <= DataSourceTypeServer; i++ )
    {
        [self fetchImageFromDataSource:i withURL:URL ForImageView:imageView];
        if(imageView.image){
          self.image = imageView.image;
          break;
        }
    }
  return self.image;
}

#pragma mark - Private methods

- (void)fetchImageFromDataSource:(DataSourceType)dataSource
                              withURL:(NSString*)url
                         ForImageView:(UIImageView *)imageView {
  
    if (dataSource == DataSourceTypeMemoryCache) {
      [self.memoryCache getImageForKey:[url MD5] forView:imageView];
    }
    else if(dataSource == DataSourceTypeDiskCache){
      [self.diskCache setFileDeletionType:FileDeletionTypeSize];
      [self.diskCache getImageForKey:[url MD5] forView:imageView];
    }
    else {
        [self startImageDownloadingFromURL:url ForImageView:imageView];
    }
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
    [self.diskCache setCache:imageData forKey:[url MD5]];
}

#pragma mark - NSOperation Methods

- (void)startImageDownloadingFromURL:(NSString *)url ForImageView:(UIImageView *)imageView {
    ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithURL:url
                                                                   delegate:self imageView:imageView];
    [self.downloadQueue addOperation:imageDownloader];
  NSLog(@"queue count ==> %i", [self.downloadQueue operationCount]);
}

#pragma mark - ImageDownloaderDelegate method

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
  if (downloader.image) {
      [downloader.imageView refreshForAsyncable];
    }
    else {
      [downloader.imageView refreshForAsyncableForFailedImage];
    }
   [self storeImage:downloader.image withURL:downloader.url];
}

@end
