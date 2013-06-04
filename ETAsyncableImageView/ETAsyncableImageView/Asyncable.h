//
//  Asyncable.h
//  ETAsyncableImageView
//
//  Created by plb-fueled on 6/4/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Asyncable : NSObject

-(UIImage *)imageForView:(UIImageView *)imageView fromURL:(NSString *)url;

@end
