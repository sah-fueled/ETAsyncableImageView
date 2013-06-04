//
//  ImageLoader.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "ImageLoader.h"

@interface ImageLoader ()

- (UIImage *)fetchImageFromCacheWithURL:(NSString *)url;
- (UIImage *)fetchImageFromDiskWithURL:(NSString *)url;
- (UIImage *)fetchImageFromServerWithURL:(NSString *)url;

@end

@implementation ImageLoader

- (UIImage *)loadImageWithURL:(NSString *)URL {
    UIImage *image;
    image = [self fetchImageFromCacheWithURL:URL];
    if (!image) {
        return image;
    }
    image = [self fetchImageFromDiskWithURL:URL];
    if (!image) {
        return image;
    }
    image = [self fetchImageFromServerWithURL:URL];
    return image;
}

- (UIImage *)fetchImageFromCacheWithURL:(NSString *)url {
    UIImage *image;
    
    return image;
}

- (UIImage *)fetchImageFromDiskWithURL:(NSString *)url {
    UIImage *image;
    
    return image;
}

- (UIImage *)fetchImageFromServerWithURL:(NSString *)url {
    UIImage *image;
    
    return image;
}

@end
