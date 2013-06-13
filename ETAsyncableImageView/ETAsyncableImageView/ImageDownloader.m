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

@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, copy) imageLoadingSuccessBlock successBlock;
@property (nonatomic, copy) imageLoadingFailureBlock failureBlock;
@property (nonatomic, copy) imageLoadingCancelBlock cancelBlock;

@end

@implementation ImageDownloader

- (id) initWithURL:(NSString *)url imageView:(UIImageView *)imageView
  withSuccessBlock:(imageLoadingSuccessBlock)successBlock
  withFailureBlock:(imageLoadingFailureBlock)failureBlock
   withCancelBlock:(imageLoadingCancelBlock)cancelBlock
{
    if (self = [super init]) {
        self.url = url;
        self.imageView = imageView;
        self.successBlock = successBlock;
        self.failureBlock = failureBlock;
        self.cancelBlock = cancelBlock;
    }
    return self;
}
- (void)main {
    
    @autoreleasepool {
        if (self.isCancelled){
            [self cancel];
            dispatch_async( dispatch_get_main_queue(), ^{
                if(self.cancelBlock)
                    self.cancelBlock();
            });
            return;

        }
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.url]];
        if (self.isCancelled) {
            [self cancel];
            dispatch_async( dispatch_get_main_queue(), ^{
                if(self.cancelBlock)
                    self.cancelBlock();
            });
            return;

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
        if (self.isCancelled){
            
            [self cancel];
            dispatch_async( dispatch_get_main_queue(), ^{
                if(self.cancelBlock)
                    self.cancelBlock();
            });
            return;

        }
    }
}

@end
