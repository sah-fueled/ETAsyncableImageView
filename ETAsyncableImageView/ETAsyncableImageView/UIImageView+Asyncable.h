//
//  UIImageView+Asyncable.h
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/11/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Asyncable)

- (UIImage *)loadImageWithURL:(NSString *)URL ForImageView:(UIImageView *)imageView WithLoadingImage:(UIImage *)loadingImage;
-(void)refreshForAsyncable;
-(void)refreshForAsyncableForFailedImage;

@end
