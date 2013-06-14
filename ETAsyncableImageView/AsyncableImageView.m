//
//  AsyncableImageView.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved. 
//

#import "AsyncableImageView.h"
#import "AsyncableImageLoader.h"
#import "DiskCache.h"
#import "NSString+MD5.h"

#define kIMAGE_DOWNLOADED @"IMAGE_DOWNLOADED"
#define kIMAGE_DOWNLOAD_FAILED @"IMAGE_DOWNLOAD_FAILED"
#define kIMAGE_DOWNLOAD_CANCELLED @"IMAGE_DOWNLOAD_CANCELLED"

@interface AsyncableImageView()

@property (nonatomic, strong) UIImageView *placeHolderView;
@property (nonatomic, strong) AsyncableImageLoader *imageLoader;
@property (nonatomic, strong) UIActivityIndicatorView *activity;
@property (nonatomic, strong) NSString *url;

@end

@implementation AsyncableImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
    
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withPlaceHolderImage:(UIImage *)defaultImage
{
    self = [super initWithFrame:frame];
    if(self){
        self.activity = [[UIActivityIndicatorView alloc]
                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect rect = self.activity.frame;
        rect.origin.x = (self.frame.size.width - rect.size.width)/2;
        rect.origin.y = (self.frame.size.height - rect.size.height)/2;
        self.activity.frame = rect;
        self.activity.hidden = YES;
        self.placeHolderView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self.placeHolderView setBackgroundColor:[UIColor whiteColor]];
        self.placeHolderView.image = defaultImage;
        
        [self addSubview:self.placeHolderView];
        [self addSubview:self.activity];
        self.imageLoader = [AsyncableImageLoader sharedLoader];
        
        
    }
    return self;
}
#pragma mark - public methods

- (void)showImageFromURL:(NSString *)URL{
    self.url = URL;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageLoaded:)
                                                 name:kIMAGE_DOWNLOADED
                                               object:self.imageLoader];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageLoadingFailed:)
                                                 name:kIMAGE_DOWNLOAD_FAILED
                                               object:self.imageLoader];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageLoadingCancelled:)
                                                 name:kIMAGE_DOWNLOAD_CANCELLED
                                               object:self.imageLoader];

    self.image = [self.imageLoader getImageFromCacheForURL:URL];
    if(self.image)
    {
        [self.placeHolderView setHidden:YES];
        return;
    }
    else
    {
        [self.placeHolderView setHidden:NO];
        self.activity.hidden = NO;
        [self.activity startAnimating];
        if(self.imageLoader)
            [self.imageLoader startImageDownloadingFromURL:self.url];
    }
}

- (void)stopImageLoadingFromURL:(NSString *)URL{
    
    [self.imageLoader stopImageDownloadingFromURL:URL];
}
- (void)stopAllImageLoading
{
    [self.imageLoader stopAllDownloading];
}

#pragma mark - private methods

- (void)imageLoaded:(NSNotification *)notification{
    NSString *obtainedURL = [notification.userInfo objectForKey:@"URL"];
    if (obtainedURL == self.url) {
       [self.activity stopAnimating];
        self.activity.hidden = YES;
        self.image = [notification.userInfo objectForKey:@"IMAGE"];
         [self.placeHolderView setHidden:YES];
        if ([self.delegate respondsToSelector:@selector(imageLoadingFinished)]) {
            [self.delegate imageLoadingFinished];
        }
    }
}
-(void)imageLoadingFailed:(NSNotification *)notification{
    
    NSString *obtainedURL = [notification.userInfo objectForKey:@"URL"];
    if (obtainedURL == self.url){
        self.activity.hidden = YES;
        [self.activity stopAnimating];
        [self.placeHolderView setHidden:YES];
        self.image = [UIImage imageNamed:@"Failed.png"];
        NSLog(@"Error in loading image");
        if ([self.delegate respondsToSelector:@selector(imageLoadingFinished)]) {
        [self.delegate imageLoadingFailed];
        }
    }
}
-(void)imageLoadingCancelled:(NSNotification *)notification{
    
    NSString *obtainedURL = [notification.userInfo objectForKey:@"URL"];
    if (obtainedURL == self.url){
        self.activity.hidden = YES;
        [self.activity stopAnimating];
        [self.placeHolderView setHidden:NO];
        NSLog(@"loading image cancelled");
        if ([self.delegate respondsToSelector:@selector(imageLoadingCancelled)]) {
            [self.delegate imageLoadingFailed];
        }
    }
}
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)didMoveToWindow
{
//    NSLog(@"hidden");
    if(!self.image) {
        self.image = [self.imageLoader getImageFromCacheForURL:self.url];
        if(self.image){ //The image has successfully loaded
            [self.activity stopAnimating];
            self.activity.hidden = YES;
            [self.placeHolderView setHidden:YES];
            if ([self.delegate respondsToSelector:@selector(imageLoadingFinished)]) {
                [self.delegate imageLoadingFinished];
            }
        }
    } 
}
@end
