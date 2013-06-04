//
//  UIImageView+Asyncable.h
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    DstaSourceTypeNSCache = 0,
    DstaSourceTypeDiskCache,
    DstaSourceTypeServer
    
} DatsSourceType;

@interface UIImageView (Asyncable)

- (void)loadImageWithURL:(NSString *)URL;

@end
