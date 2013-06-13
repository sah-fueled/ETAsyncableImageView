//
//  AsyncableImageLoader.h
//  ETAsyncableImageView
//
//  Created by sah-fueled on 06/06/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncableImageLoader : NSObject

+ (AsyncableImageLoader *) sharedLoader;

- (UIImage*)getImageFromCacheForURL:(NSString*)URL;
- (void)startImageDownloadingFromURL:(NSString *)URL forImageView:(UIImageView *)imageView;
- (void)stopImageDownloadingFromURL:(NSString *)URL forImageView:(UIImageView *)imageView;
- (void)stopAllDownloading;

@end
