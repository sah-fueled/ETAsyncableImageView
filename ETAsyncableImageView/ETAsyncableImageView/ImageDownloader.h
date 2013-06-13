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
typedef void (^imageLoadingCancelBlock)(void);

@interface ImageDownloader : NSOperation

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *url;

- (id)initWithURL:(NSString *)URL
 withSuccessBlock:(imageLoadingSuccessBlock)successBlock
 withFailureBlock:(imageLoadingFailureBlock)failureBlock
  withCancelBlock:(imageLoadingCancelBlock)cancelBlock;

@end

