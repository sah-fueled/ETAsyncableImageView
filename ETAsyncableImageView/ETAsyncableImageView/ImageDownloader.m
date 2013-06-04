//
//  ImageDownloader.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong)NSData *responseData;

@end

@implementation ImageDownloader

- (id)initWithURL:(NSString *)url ImageView:(UIImageView *)imageView delegate:(id<ImageDownloaderDelegate>)delegate {
    
    if (self = [super init]) {
        self.url = url;
        self.imageView = imageView;
        self.delegate = delegate;
    }
    return self;
}

- (void)main {
    
    @autoreleasepool {
        if (self.isCancelled)
            return;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:15];
        [NSURLConnection connectionWithRequest:request delegate:self];
//        if (self.isCancelled) {
//            imageData = nil;
//            return;
//        }
//        if (imageData) {
//            UIImage *downloadedImage = [UIImage imageWithData:imageData];
//            self.imageView.image = downloadedImage;
//        }
//        imageData = nil;
//        if (self.isCancelled)
//            return;
//        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.responseData = [NSData data];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	self.responseData  = data;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage *downloadedImage = [UIImage imageWithData:self.responseData];
    self.imageView.image = downloadedImage;
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}

@end
