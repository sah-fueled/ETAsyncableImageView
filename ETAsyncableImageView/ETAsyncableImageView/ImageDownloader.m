//
//  ImageDownloader.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "ImageDownloader.h"
#import "DiskCache.h"

@interface ImageDownloader ()

@property (nonatomic, strong)NSData *responseData;
@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, copy) imageLoadingSuccessBlock successBlock;
@property (nonatomic, copy) imageLoadingFailureBlock failureBlock;

@end

@implementation ImageDownloader

- (id)initWithURL:(NSString *)url imageView:(UIImageView *)imageView delegate:(id<ImageDownloaderDelegate>)delegate {
    
    if (self = [super init]) {
        self.url = url;
        self.imageView = imageView;
        self.delegate = delegate;
    }
    return self;
}
- (id) initWithURL:(NSString *)url imageView:(UIImageView *)imageView withSuccessBlock:(imageLoadingSuccessBlock)successBlock withFailureBlock:(imageLoadingFailureBlock)failureBlock
{
    if (self = [super init]) {
        self.url = url;
        self.imageView = imageView;
        self.successBlock = successBlock;
        self.failureBlock = failureBlock;
    }
    return self;
}
- (void)main {
    
    @autoreleasepool {
        if (self.isCancelled)
            return;
        
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.url]];
        if (self.isCancelled) {
            imageData = nil;
            dispatch_async( dispatch_get_main_queue(), ^{
                if(self.failureBlock)
                    self.failureBlock();
            });
            return;
        }
        if (!self.imageView.window) {
            [self cancel];
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidCancel:)
                                                        withObject:self
                                                      waitUntilDone:NO];
       }
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.image = downloadedImage;
            dispatch_async( dispatch_get_main_queue(), ^{
                if(self.successBlock)
                    self.successBlock(downloadedImage, self.url);
                    });
        }
        else {
            dispatch_async( dispatch_get_main_queue(), ^{
                if(self.failureBlock)
                    self.failureBlock();
            });

        }
        imageData = nil;
        if (self.isCancelled)
            return;
        
      
        
//        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:)
//                                                    withObject:self
//                                                 waitUntilDone:NO];
    }
}

@end
