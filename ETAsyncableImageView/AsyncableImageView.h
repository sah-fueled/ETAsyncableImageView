//
//  AsyncableImageView.h
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AsyncableImageViewdelegate;

@interface AsyncableImageView : UIImageView

@property(nonatomic, weak)id<AsyncableImageViewdelegate> delegate;

-(void)showImageFromURL:(NSString *)url;
-(void)showImageFromURL:(NSString *)url withMaskImage:(UIImage *)maskImage;
-(void)showImageFromURL:(NSString *)url withPlaceHolderImage:(UIImage *) placeHolderImage;

@end

@protocol AsyncableImageViewdelegate <NSObject>
@optional

-(void)imageLoadingFinished;

@end
