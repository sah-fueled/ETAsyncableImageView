
//
//  UIImageView+Asyncable.h
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DataSourceTypeNSCache = 0,
    DataSourceTypeDiskCache,
    DataSourceTypeServer
} DataSourceType;

@interface UIImageView (Asyncable)

- (UIImage *)loadImageWithURL:(NSString *)URL;
- (UIImage *)fetchImageWithURL:(NSString *)url FromDataSource:(DataSourceType)dataSourceType;

@end
