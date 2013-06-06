//
//  AsyncableImageLoader.h
//  ETAsyncableImageView
//
//  Created by sah-fueled on 06/06/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncableImageLoader : NSObject

@property (nonatomic, strong) UIImage *image;

- (UIImage *)loadImageWithURL:(NSString *)URL ForImageView:(UIImageView *)imageView;
+ (AsyncableImageLoader *) sharedLoader;

@end
