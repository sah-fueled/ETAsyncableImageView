//
//  UIImageView+Asyncable.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/11/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "UIImageView+Asyncable.h"
#import "ImageLoader.h"

#define kIMAGE_DOWNLOADED @"IMAGE_DOWNLOADED"
#define kIMAGE_DOWNLOAD_FAILED @"IMAGE_DOWNLOAD_FAILED"

@implementation UIImageView (Asyncable)

- (UIImage *)loadImageWithURL:(NSString *)URL ForImageView:(UIImageView *)imageView WithLoadingImage:(UIImage *)loadingImage {
  if (URL == nil) {
    [self refreshForAsyncableForFailedImage];
    [self setImage:loadingImage];
    return nil;
  }
  UIImage *fetchedImage = [[ImageLoader sharedInstance] fetchImageWithURL:URL ForImageView:self];
  if (fetchedImage) {
    [self refreshForAsyncable];
    return fetchedImage;
  }
  else if (loadingImage != nil) {
    [self setImage:loadingImage];
    return nil;
  }
  else {
    return nil;
  }
 
}

-(void)refreshForAsyncable {
	[[NSNotificationCenter defaultCenter] postNotificationName:kIMAGE_DOWNLOADED object:self];
}

-(void)refreshForAsyncableForFailedImage{
  [[NSNotificationCenter defaultCenter] postNotificationName:kIMAGE_DOWNLOAD_FAILED object:self];
}


@end
