//
//  ImageDownloader.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()

//@property (nonatomic, strong) NSString *url;

@property (nonatomic, strong)NSData *responseData;

@end

@implementation ImageDownloader

- (id)initWithURL:(NSString *)url delegate:(id<ImageDownloaderDelegate>)delegate {
    
    if (self = [super init]) {
        self.url = url;
       self.delegate = delegate;
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
            return;
        }
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.image = downloadedImage;
        }
        imageData = nil;
        if (self.isCancelled)
            return;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
    }
}

@end
