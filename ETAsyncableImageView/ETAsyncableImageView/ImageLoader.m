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


@interface ImageLoader ()

- (UIImage *)fetchImageFromServerWithURL:(NSString *)url;
- (UIImage *)fetchImageFromDataSource:(DataSourceType) dataSource withURL:(NSString*)url;
- (void)storeImage:(UIImage*)image withURL:(NSString*)url;

@end

@implementation ImageLoader

- (UIImage *)fetchImageFromDataSource:(DataSourceType)dataSource
                              withURL:(NSString*)url{
    
    UIImage *image;
    switch (dataSource) {
        case DataSourceTypeMemoryCache:
            image = [UIImage imageWithData:[[MemoryCache sharedCache] getCacheForKey:url]];
            break;
        case DataSourceTypeDiskCache:
            image = [UIImage imageWithData:[[DiskCache sharedCache] getCacheForKey:url]];
            break;
        case DataSourceTypeServer:
            image = [self fetchImageFromServerWithURL:url];
            break;
            
        default:
            break;
    }
    
    return image;
}
- (UIImage *)loadImageWithURL:(NSString *)URL {
    UIImage *image;
    
    for(int i = DataSourceTypeMemoryCache; i <= DataSourceTypeServer; i++ )
    {
        image = [self fetchImageFromDataSource:i withURL:URL];
        if(image) break;
    }
    return image;
    
 }

- (UIImage *)fetchImageFromServerWithURL:(NSString *)url {
    UIImage *image;
    
    return image;
}

#pragma mark - Private methods

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

- (void)storeImage:(UIImage *)image withURL:(NSString *)url
{
    
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

@end
