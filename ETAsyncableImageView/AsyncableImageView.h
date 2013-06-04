//
//  AsyncableImageView.h
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <UIKit/UIKit.h>




@protocol AsyncableImageViewdelegate;

@interface AsyncableImageView : UIImageView {
    
    UIActivityIndicatorView *activity;
    id<AsyncableImageViewdelegate> delegate;
    
}

@property(nonatomic, weak)id<AsyncableImageViewdelegate> delegate;
@property(nonatomic, strong)UIActivityIndicatorView *activity;

-(void)showImageFromURL:(NSString *)url;
-(void)showImageFromURL:(NSString *)url withMaskImage:(UIImage *)maskImage;

@end

@protocol AsyncableImageViewdelegate <NSObject>
@optional

-(void)imageLoadingFinished;

@end
