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

@interface ImageDownloader : NSOperation

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *url;

- (id)initWithURL:(NSString *)url imageView:(UIImageView *)imageView
 withSuccessBlock:(imageLoadingSuccessBlock)successBlock
 withFailureBlock:(imageLoadingFailureBlock)failureBlock;

@end

