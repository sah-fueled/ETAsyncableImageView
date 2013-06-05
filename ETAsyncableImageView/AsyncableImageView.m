//
//  AsyncableImageView.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "AsyncableImageView.h"
#import "ImageLoader.h"

#define kIMAGE_DOWNLOADED @"IMAGE_DOWNLOADED"
#define kIMAGE_DOWNLOAD_FAILED @"IMAGE_DOWNLOAD_FAILED"

@interface AsyncableImageView()

@property(nonatomic, strong) UIImage *maskImage;
@property(nonatomic, strong) UIImage *placeHolderImage;
@property(nonatomic, strong) ImageLoader *imageLoader;
@property(nonatomic, strong) UIActivityIndicatorView *activity;

-(UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;

@end

@implementation AsyncableImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializtion];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initializtion];
    }
    return self;
}

#pragma mark - public methods

- (void)showImageFromURL:(NSString *)url{
    self.image = [UIImage imageWithContentsOfFile:url];
    if (self.image) {
        [self imageLoaded];
    }
    else {
      [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(imageLoaded)
                                                     name:kIMAGE_DOWNLOADED
                                                   object:self.imageLoader];
      
      [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(imageLoadingFailed)
                                                     name:kIMAGE_DOWNLOAD_FAILED
                                                   object:self.imageLoader];
      self.image = [self.imageLoader loadImageWithURL:url ForImageView:self];
      if (!self.image) {
        self.activity.hidden = NO;
        [self.activity startAnimating];
        if(self.placeHolderImage)
          self.image = self.placeHolderImage;
        }
        else {
          [self imageLoaded];
        }
    }
}

- (void)showImageFromURL:(NSString *)url withMaskImage:(UIImage *)maskImage{
    self.maskImage = maskImage;
    [self showImageFromURL:url];
    self.image = [self maskImage:self.image withMask:self.maskImage];
}

- (void)showImageFromURL:(NSString *)url
    withPlaceHolderImage:(UIImage *)placeHolderImage{
    self.placeHolderImage = placeHolderImage;
    [self showImageFromURL:url];
    
}

#pragma mark - private methods

- (void)initializtion{
    
    self.activity = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect rect = self.activity.frame;
    rect.origin.x = (self.frame.size.width - rect.size.width)/2;
    rect.origin.y = (self.frame.size.height - rect.size.height)/2;
    self.activity.frame = rect;
    self.activity.hidden = YES;
    [self addSubview:self.activity];
    _imageLoader = [[ImageLoader alloc]init];
}

-(UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
	CGImageRef maskRef = maskImage.CGImage;
	CGImageRef imageRef = image.CGImage;
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, true);
    
	CGImageRef masked = CGImageCreateWithMask(imageRef, mask);
    UIImage *img = [UIImage imageWithCGImage:masked];
    
    CFRelease(masked);
    CFRelease(mask);
    
	return img;
    
}

- (void)imageLoaded{
    
    self.activity.hidden = YES;
    [self.activity stopAnimating];
    self.image = self.imageLoader.image;
    
    if ([self.delegate respondsToSelector:@selector(imageLoadingFinished)]) {
        [self.delegate imageLoadingFinished];
    }
    
}

-(void)imageLoadingFailed{
    
    self.activity.hidden = YES;
    [self.activity stopAnimating];
    self.image = [UIImage imageNamed:@"Failed.png"];
    NSLog(@"Error in loading image");
    if ([self.delegate respondsToSelector:@selector(imageLoadingFinished)]) {
        [self.delegate imageLoadingFinished];
    }
    
    
}

@end
