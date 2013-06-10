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

typedef void (^imageLoadingCompletionBlock)(void);

@interface AsyncableImageLoader()<ImageDownloaderDelegate>

@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, strong) DiskCache *diskCache;
@property (nonatomic, strong) NSMutableArray *operationsList;
@property (nonatomic, assign) imageLoadingCompletionBlock successBlock;
@property (nonatomic, assign) imageLoadingCompletionBlock failureBlock;
@property (nonatomic, strong) UIImageView *imageView;

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
            self.diskCache = [DiskCache sharedCache];
    
    }
    return self;
}

- (UIImage *)loadImageWithURL:(NSString *)URL ForImageView:(UIImageView *)imageView {
     UIImage *image;
   
    for(int i = DataSourceTypeMemoryCache; i <= DataSourceTypeServer; i++ )
    {
        image = [self fetchImageFromDataSource:i withURL:URL ForImageView:imageView];
        if(image) break;
    }
    return image;
}
- (UIImage *)loadImageWithURL:(NSString *)URL
            forImageView:(UIImageView *)imageView
        withSuccessBlock:(void (^)(void))successBlock
        withFailureBlock:(void (^)(void))failureBlock{
    UIImage *image;
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    self.imageView = imageView;
    for(int i = DataSourceTypeMemoryCache; i <= DataSourceTypeServer; i++ )
    {
        image = [self fetchImageFromDataSource:i withURL:URL ForImageView:imageView];
        if(image) break;
    }
    return image;
}

#pragma mark - Private methods

- (UIImage *)fetchImageFromDataSource:(DataSourceType)dataSource
                              withURL:(NSString*)url
                         ForImageView:(UIImageView *)imageView

{
    
    UIImage *image;
    if (dataSource == DataSourceTypeMemoryCache) {
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
        image = [UIImage imageWithData:[self.memoryCache objectForKey:[url MD5]]];
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

- (NSOperationQueue *)downloadQueue {
    QueueManager * queueManager = [QueueManager sharedInstance];
    NSOperationQueue *globalQueue = queueManager.globalQueue;
    return globalQueue;
}

- (void)startImageDownloadingFromURL:(NSString *)url ForImageView:(UIImageView *)imageView {
    ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithURL:url
                                                                  imageView:imageView
                                                                   delegate:self];
    [self.downloadQueue addOperation:imageDownloader];
    NSLog(@"queue = %@",self.downloadQueue);
    NSLog(@"queue count:  %i",[self.downloadQueue operationCount]);
}

#pragma mark - ImageDownloaderDelegate method

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    if (downloader.image) {
           NSLog(@"download image = %@",downloader.image);
        [self storeImage:downloader.image withURL:downloader.url];
   
//        if (self.successBlock)
//            self.successBlock();
        if([self.delegate respondsToSelector:@selector(imageLoadingSuccessfulForURL:withImage:)])
        {
//            [self.delegate imageLoadingSuccessfulForURL:downloader.url withImage: [UIImage imageWithData:[[DiskCache sharedCache] getCacheForKey:[downloader.url MD5]]]];
             [self.delegate imageLoadingSuccessfulForURL:downloader.url withImage:downloader.image];
//
        }
       
    
    }
    else {
        if([self.delegate respondsToSelector:@selector(imageLoadingFailedForURL:)])
           [self.delegate imageLoadingFailedForURL:downloader.url];
    }
}
-(void)imageDownloaderDidCancel:(ImageDownloader *)downloader {

}
- (void)storeImage:(UIImage *)image withURL:(NSString *)url{
    
    NSData *imageData = nil;
    
    if ([self imageTypeForJTDynamicImageURL:[NSURL URLWithString:url]] == AsyncableImageTypeJPEG) {
        imageData = UIImageJPEGRepresentation(image, 1);
    } else {
        imageData = UIImagePNGRepresentation(image);
    }

    if(imageData){
        [[DiskCache sharedCache] setCache:imageData forKey:[url MD5]];
        [self.memoryCache setObject:imageData forKey:[url MD5]];
    }
}
- (UIImage*)getFromMemoryForURL:(NSString *)URL
{
    return [UIImage imageWithData:[[DiskCache sharedCache] getCacheForKey:[URL MD5]]];
}


@end
