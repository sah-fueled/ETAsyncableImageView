//
//  ImageDownloader.h
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^imageLoadingSuccessBlock)(UIImage *image, NSString *url);
typedef void (^imageLoadingFailureBlock)(void);

@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSOperation

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) id <ImageDownloaderDelegate> delegate;
- (id)initWithURL:(NSString *)url imageView:(UIImageView *)imageView delegate:(id<ImageDownloaderDelegate>)delegate;
- (id)initWithURL:(NSString *)url imageView:(UIImageView *)imageView
 withSuccessBlock:(imageLoadingSuccessBlock)successBlock
 withFailureBlock:(imageLoadingFailureBlock)failureBlock;

@end

@protocol ImageDownloaderDelegate <NSObject>

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader;
- (void)imageDownloaderDidCancel:(ImageDownloader *)downloader;
@end
