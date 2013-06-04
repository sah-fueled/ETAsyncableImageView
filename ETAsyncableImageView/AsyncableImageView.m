//
//  AsyncableImageView.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "AsyncableImageView.h"
#import "UIImageView+Asyncable.h"

@interface AsyncableImageView()
@property(nonatomic, strong) UIImage *maskImage;

-(UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
@end

@implementation AsyncableImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect rect = activity.frame;
        rect.origin.x = (self.frame.size.width - rect.size.width)/2;
        rect.origin.y = (self.frame.size.height - rect.size.height)/2;
        activity.frame = rect;
        activity.hidden = YES;
        [self addSubview:activity];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect rect = activity.frame;
        rect.origin.x = (self.frame.size.width - rect.size.width)/2;
        rect.origin.y = (self.frame.size.height - rect.size.height)/2;
        activity.frame = rect;
        activity.hidden = YES;
        [self addSubview:activity];
    }
    return self;
}

-(void)showImageFromURL:(NSString *)url{
    [self showImageFromURL:url withMaskImage:nil];
}

-(void)showImageFromURL:(NSString *)url withMaskImage:(UIImage *)maskImage{
    self.maskImage = maskImage;
    [self loadImageWithURL:url];
    
}

-(void)imageLoaded{
    
    activity.hidden = YES;
    [activity stopAnimating];
    
     if (self.maskImage) {
        self.image = [self maskImage:self.image withMask:self.maskImage];
        self.maskImage = nil;
    }
    
    if ([delegate respondsToSelector:@selector(imageLoadingFinished)]) {
        [delegate imageLoadingFinished];
    }
    
}

-(void)imageLoadingFailed{
    
    activity.hidden = YES;
    [activity stopAnimating];
    
    //self.image = [UIImage imageNamed:@"broken-image.png"];
    
    if ([delegate respondsToSelector:@selector(imageLoadingFinished)]) {
        [delegate imageLoadingFinished];
    }
    
    
}



@end
