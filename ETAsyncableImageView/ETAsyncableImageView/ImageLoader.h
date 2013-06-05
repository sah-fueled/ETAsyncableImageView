
//
//  ImageLoader.h
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageLoader : NSObject

@property (nonatomic, strong) UIImage *image;
- (UIImage *)loadImageWithURL:(NSString *)URL ForImageView:(UIImageView *)imageView;

@end
