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

- (id)initWithFrame:(CGRect)frame withPlaceHolderImage:(UIImage *)defaultImage;
- (void)showImageFromURL:(NSString *)URL;
- (void)stopImageLoadingFromURL:(NSString*)URL;

@end

@protocol AsyncableImageViewdelegate <NSObject>
@optional

- (void)imageLoadingFinished;
- (void)imageLoadingFailed;
- (void)imageLoadingCancelled;

@end
