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
- (void)startImageDownloadingFromURL:(NSString *)url forImageView:(UIImageView *)imageView;
- (void)stopImageDownloadingFromURL:(NSString *)url forImageView:(UIImageView *)imageView;

@end
