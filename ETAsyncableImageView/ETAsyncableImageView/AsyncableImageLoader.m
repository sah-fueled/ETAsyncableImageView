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

#define kIMAGE_DOWNLOADED @"IMAGE_DOWNLOADED"
#define kIMAGE_DOWNLOAD_FAILED @"IMAGE_DOWNLOAD_FAILED"
#define kIMAGE_DOWNLOAD_CANCELLED @"IMAGE_DOWNLOAD_CANCELLED"

typedef enum {
    AsyncableImageTypeUnknown = -1,
    AsyncableImageTypeJPEG,
    AsyncableImageTypePNG
} AsyncableImageType;

@interface AsyncableImageLoader()

@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, strong) DiskCache *diskCache;
@property (nonatomic, strong) NSMutableArray *operationsList;
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
            self.diskCache = [DiskCache sharedCache];
    
    }
    return self;
}

#pragma mark - Private methods

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

- (void)startImageDownloadingFromURL:(NSString *)URL {
    ImageDownloader *imageDownloader =
    [[ImageDownloader alloc]initWithURL:URL
                       withSuccessBlock:^(UIImage *image, NSString *url){
                           if (image) {
                            NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:image, @"IMAGE", url, @"URL", nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kIMAGE_DOWNLOADED
                                                                                object:self
                                                                              userInfo:userInfo];
                            [self storeImage:image withURL:URL];
                                  }
                                }
                       withFailureBlock:^{
                            NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:URL, @"URL", nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kIMAGE_DOWNLOAD_FAILED     object:self userInfo:userInfo];
                              }
                        withCancelBlock:^{
                            NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:URL, @"URL", nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kIMAGE_DOWNLOAD_CANCELLED object:self userInfo:userInfo];}];
    
    [self.downloadQueue addOperation:imageDownloader];
//    NSLog(@"queue = %@",self.downloadQueue);
//    NSLog(@"queue count:  %i",[self.downloadQueue operationCount]);
}

- (void)stopImageDownloadingFromURL:(NSString *)URL
{
    for(ImageDownloader *downloader in self.downloadQueue.operations){
        if([downloader.url isEqualToString:URL]){
            [downloader cancel];
            return;
        }
    }
}
- (void)stopAllDownloading{
    for(ImageDownloader *downloader in self.downloadQueue.operations){
        [downloader cancel];
    }

}
- (void)storeImage:(UIImage *)image withURL:(NSString *)URL{
    
    NSData *imageData = nil;
    
    if ([self imageTypeForJTDynamicImageURL:[NSURL URLWithString:URL]] == AsyncableImageTypeJPEG) {
        imageData = UIImageJPEGRepresentation(image, 1);
    } else {
        imageData = UIImagePNGRepresentation(image);
    }

    if(imageData){
        [[DiskCache sharedCache] setCache:imageData forKey:[URL MD5]];
        [self.memoryCache setObject:imageData forKey:[URL MD5]];
    }
}
- (UIImage*)getImageFromCacheForURL:(NSString *)URL
{
    UIImage *image = [UIImage imageWithData:[self.memoryCache objectForKey:[URL MD5]]];//Fetch from NSCache
    
    if(!image){ //Fetch from disk if not present in NSCache
        NSData *data = [[DiskCache sharedCache] getCacheForKey:[URL MD5]];
        image = [UIImage imageWithData:data];
        if (data) {
            [self.memoryCache setObject:data forKey:[URL  MD5]]; //Save the image to cache from disk
        }
    }
    return image;
}


@end
