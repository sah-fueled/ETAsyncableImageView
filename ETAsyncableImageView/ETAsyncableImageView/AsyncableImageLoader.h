//
//  AsyncableImageLoader.h
//  ETAsyncableImageView
//
//  Created by sah-fueled on 06/06/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AsyncableImageLoaderProtocol;

@interface AsyncableImageLoader : NSObject

@property (nonatomic,weak) id<AsyncableImageLoaderProtocol> delegate;
- (UIImage *)loadImageWithURL:(NSString *)URL ForImageView:(UIImageView *)imageView;
+ (AsyncableImageLoader *) sharedLoader;
- (UIImage*)getFromMemoryForURL:(NSString*)URL;

@end
@protocol AsyncableImageLoaderProtocol <NSObject>

-(void) imageLoadingFailedForURL:(NSString*)URL;
-(void) imageLoadingSuccessfulForURL:(NSString *)URL withImage:(UIImage*)image;
-(void) imageLoadingCancelledForURL:(NSString *)URL;

@end