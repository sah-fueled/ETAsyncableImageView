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

@interface AsyncableImageView()<AsyncableImageLoaderProtocol>

@property(nonatomic, strong) UIImage *maskImage;
@property(nonatomic, strong) UIImage *placeHolderImage;
@property(nonatomic, strong) UIImageView *placeHolderView;
@property(nonatomic, strong) AsyncableImageLoader *imageLoader;
@property(nonatomic, strong) UIActivityIndicatorView *activity;
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
        self.placeHolderView.image = defaultImage;
        
        [self addSubview:self.placeHolderView];
        [self addSubview:self.activity];
        self.imageLoader = [AsyncableImageLoader sharedLoader];
        
        
    }
    return self;
}
//#pragma mark - public methods

- (void)showImageFromURL:(NSString *)url{
    self.url = url;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageLoaded:)
                                                 name:kIMAGE_DOWNLOADED
                                               object:self.imageLoader];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageLoadingFailed:)
                                                 name:kIMAGE_DOWNLOAD_FAILED
                                               object:self.imageLoader];

    self.image = [self.imageLoader getFromMemoryForURL:url];
    if(self.image)
    {
        [self.placeHolderView setHidden:YES];
        return;
    }
    else
    {
        self.image = self.placeHolderImage;
        [self.placeHolderView setHidden:NO];
        self.activity.hidden = NO;
        [self.activity startAnimating];
        if(self.imageLoader)
            self.image = [self.imageLoader loadImageWithURL:url ForImageView:self];
    }
}

#pragma mark - private methods

- (void)imageLoaded:(NSNotification *)notification{
    NSString *obtainedURL = [notification.userInfo objectForKey:@"URL"];
    if (obtainedURL == self.url) {
       [self.activity stopAnimating];
        self.activity.hidden = YES;
        self.image = [notification.userInfo objectForKey:@"IMAGE"];
         [self.placeHolderView setHidden:YES];
    }
   if ([self.delegate respondsToSelector:@selector(imageLoadingFinished)]) {
        [self.delegate imageLoadingFinished];
    }
    
}

-(void)imageLoadingFailed:(NSNotification *)notification{
    
    self.activity.hidden = YES;
    [self.activity stopAnimating];
    self.image = [UIImage imageNamed:@"Failed.png"];
    NSLog(@"Error in loading image");
    if ([self.delegate respondsToSelector:@selector(imageLoadingFinished)]) {
        [self.delegate imageLoadingFinished];
    }
    
    
}
-(void)imageLoadingCancelled{
    self.activity.hidden = YES;
    [self.activity stopAnimating];
     NSLog(@"Loading image cancelled");

}
-(void)imageLoadingFailedForURL:(NSString *)URL
{
    self.activity.hidden = YES;
    [self.activity stopAnimating];
    self.image = [UIImage imageNamed:@"Failed.png"];
    NSLog(@"Error in loading image");
}

-(void)imageLoadingSuccessfulForURL:(NSString *)URL withImage:(UIImage *)image
{
    if([self.url isEqualToString:URL])
    {
        NSLog(@"successful");
        [self.activity stopAnimating];
        self.activity.hidden = YES;
        self.image = [self.imageLoader getFromMemoryForURL:self.url];
//        self.image =image;
        NSLog(@"self image =  %@",self.image);
        if ([self.delegate respondsToSelector:@selector(imageLoadingFinished)]) 
            [self.delegate imageLoadingFinished];

    }
}
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
  }
- (void)viewDidMoveToSuperview{

}
-(void)viewDidMoveToWindow
{
    NSLog(@"hidden");
}
@end
