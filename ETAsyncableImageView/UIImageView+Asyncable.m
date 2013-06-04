//
//  UIImageView+Asyncable.m
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import "UIImageView+Asyncable.h"
#import "DiskCache.h"
#import "MemoryCache.h"

@implementation UIImageView (Asyncable)

- (UIImage *)loadImageWithURL:(NSString *)URL {
    UIImage *image;
    image = [self fetchImageWithURL:URL FromDataSource:DataSourceTypeNSCache];
    return image;
    
    image = [self fetchImageWithURL:URL FromDataSource:DataSourceTypeDiskCache];
    return image;
    
    image = [self fetchImageWithURL:URL FromDataSource:DataSourceTypeServer];
    return image;
}

- (UIImage *)fetchImageWithURL:(NSString *)url FromDataSource:(DataSourceType)dataSourceType {
    UIImage *image;
    if (dataSourceType == DataSourceTypeNSCache) {
        [MemoryCache sharedCache].
    }
    
    else if (dataSourceType == DataSourceTypeDiskCache) {
        
    }
    
    else {
        
    }
    
    return image;
}

@end
