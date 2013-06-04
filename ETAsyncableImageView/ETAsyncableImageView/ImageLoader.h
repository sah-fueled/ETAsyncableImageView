
//
//  ImageLoader.h
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DataSourceTypeNSCache = 0,
    DataSourceTypeDiskCache,
    DataSourceTypeServer
} DataSourceType;

@interface ImageLoader : NSObject

- (UIImage *)loadImageWithURL:(NSString *)URL;

@end
