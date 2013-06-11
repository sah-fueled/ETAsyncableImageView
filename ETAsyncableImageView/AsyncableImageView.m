//
//  AsyncableImageView.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "AsyncableImageView.h"
#import "UIImageView+Asyncable.h"

#define kIMAGE_DOWNLOADED @"IMAGE_DOWNLOADED"
#define kIMAGE_DOWNLOAD_FAILED @"IMAGE_DOWNLOAD_FAILED"
#define kPlaceholder @"Placeholder.png"

@interface AsyncableImageView()

@property(nonatomic, strong) UIImage *placeHolderImage;
@property(nonatomic, strong) UIActivityIndicatorView *activity;

@end

@implementation AsyncableImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialization];
    }
    return self;
}

#pragma mark - public methods

- (void)showImageFromURL:(NSString *)url{
  
  [self showImageFromURL:url withPlaceHolderImage:nil];
}

- (void)showImageFromURL:(NSString *)url
    withPlaceHolderImage:(UIImage *)placeHolderImage{
  
  self.image = [UIImage imageWithContentsOfFile:url];
  if (self.image) {
    [self imageLoaded];
  }
  else {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageLoaded)
                                                 name:kIMAGE_DOWNLOADED
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageLoadingFailed)
                                                 name:kIMAGE_DOWNLOAD_FAILED
                                               object:self];
    UIImage *image = [self loadImageWithURL:url ForImageView:self WithLoadingImage:[UIImage imageNamed:kPlaceholder]];
    if (!image) {
      self.activity.hidden = NO;
      [self.activity startAnimating];
    }
 }
}

#pragma mark - private methods

- (void)initialization{
  
    self.activity = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect rect = self.activity.frame;
    rect.origin.x = (self.frame.size.width - rect.size.width)/2;
    rect.origin.y = (self.frame.size.height - rect.size.height)/2;
    self.activity.frame = rect;
    self.activity.hidden = YES;
    [self addSubview:self.activity];
}

- (void)imageLoaded{
   self.activity.hidden = YES;
    [self.activity stopAnimating];
  
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
